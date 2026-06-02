import { describe, expect, test } from "vitest";
import { AiGatewayError } from "../src/ai/providerTypes";
import {
  ConsumeQuotaInput,
  InMemoryUsageCounterStore,
  QuotaService,
} from "../src/quota/quotaService";
import { handleParseExpense } from "../src/handlers/parseExpense";
import {
  FakeProvider,
  jsonRequest,
  quotaService as handlerQuotaService,
  readJson,
  testEnv,
  validPayload,
} from "./helpers";

function service() {
  return new QuotaService(new InMemoryUsageCounterStore());
}

class RecordingQuotaService extends QuotaService {
  readonly inputs: ConsumeQuotaInput[] = [];

  constructor() {
    super(new InMemoryUsageCounterStore());
  }

  override async consume(input: ConsumeQuotaInput) {
    this.inputs.push(input);
    return super.consume(input);
  }
}

describe("QuotaService", () => {
  test("first parse request with limit 5 returns remaining 4", async () => {
    const quota = await service().consume({
      uid: "user-a",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 5,
    });
    expect(quota.remaining).toBe(4);
  });

  test("5th parse request returns remaining 0 and 6th throws", async () => {
    const quota = service();
    let lastRemaining = -1;
    for (let i = 0; i < 5; i += 1) {
      lastRemaining = (
        await quota.consume({
          uid: "user-a",
          dateKey: "2026-05-16",
          requestType: "parse_text",
          provider: "gemini",
          model: "gemini-2.5-flash",
          userLimit: 5,
        })
      ).remaining;
    }
    expect(lastRemaining).toBe(0);
    await expect(
      quota.consume({
        uid: "user-a",
        dateKey: "2026-05-16",
        requestType: "parse_text",
        provider: "gemini",
        model: "gemini-2.5-flash",
        userLimit: 5,
      }),
    ).rejects.toMatchObject({ code: "quota_exceeded" } as AiGatewayError);
  });

  test("user B is unaffected by user A quota", async () => {
    const quota = service();
    await quota.consume({
      uid: "user-a",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 1,
    });
    const userB = await quota.consume({
      uid: "user-b",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 1,
    });
    expect(userB.used).toBe(1);
  });

  test("request type counters are independent", async () => {
    const quota = service();
    await quota.consume({
      uid: "user-a",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 1,
    });
    const receipt = await quota.consume({
      uid: "user-a",
      dateKey: "2026-05-16",
      requestType: "receipt_extraction",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 3,
    });
    expect(receipt.remaining).toBe(2);
  });

  test("new UTC date resets quota", async () => {
    const quota = service();
    const base = {
      uid: "user-a",
      requestType: "financial_advice" as const,
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 1,
    };
    await quota.consume({ ...base, dateKey: "2026-05-16" });
    const nextDay = await quota.consume({ ...base, dateKey: "2026-05-17" });
    expect(nextDay.used).toBe(1);
  });

  test("no global limit applies when absent", async () => {
    const quota = service();
    await quota.consume({
      uid: "user-a",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 5,
    });
    const userB = await quota.consume({
      uid: "user-b",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 5,
    });
    expect(userB.remaining).toBe(4);
  });

  test("optional global limit works only when explicitly provided", async () => {
    const quota = service();
    await quota.consume({
      uid: "user-a",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 5,
      globalLimit: 1,
    });
    await expect(
      quota.consume({
        uid: "user-b",
        dateKey: "2026-05-16",
        requestType: "parse_text",
        provider: "gemini",
        model: "gemini-2.5-flash",
        userLimit: 5,
        globalLimit: 1,
      }),
    ).rejects.toMatchObject({ code: "quota_exceeded" } as AiGatewayError);
  });

  test("parse handler keeps quota per user end to end", async () => {
    const provider = new FakeProvider();
    const quota = handlerQuotaService();
    for (let i = 0; i < 5; i += 1) {
      const response = await handleParseExpense(
        jsonRequest("/aiParse", {
          input: `spent ${i}`,
          now: "2026-05-16T12:00:00.000Z",
        }),
        testEnv(),
        undefined,
        {
          provider,
          quotaService: quota,
          tokenVerifier: async () => validPayload("user-a"),
        },
      );
      expect(response.status).toBe(200);
    }
    const blocked = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "spent 6",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      {
        provider,
        quotaService: quota,
        tokenVerifier: async () => validPayload("user-a"),
      },
    );
    expect(blocked.status).toBe(429);

    const userB = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "spent 1",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      {
        provider,
        quotaService: quota,
        tokenVerifier: async () => validPayload("user-b"),
      },
    );
    expect(userB.status).toBe(200);
    expect(provider.parseCalls).toBe(6);
  });

  test("parse quota decision uses gateway identity only, not local save quota state", async () => {
    const provider = new FakeProvider();
    const quota = new RecordingQuotaService();
    const response = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "spent 250 on groceries",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      {
        provider,
        quotaService: quota,
        tokenVerifier: async () => validPayload("user-a"),
        now: () => new Date("2026-05-16T12:00:00.000Z"),
      },
    );

    expect(response.status).toBe(200);
    expect(quota.inputs).toEqual([
      {
        uid: "user-a",
        dateKey: "2026-05-16",
        requestType: "parse_text",
        provider: "gemini",
        model: "gemini-2.5-flash",
        userLimit: 5,
        globalLimit: undefined,
      },
    ]);
    expect(provider.parseCalls).toBe(1);
  });

  test("parse quota block returns safe gateway quota status and reset time", async () => {
    const provider = new FakeProvider();
    const quota = handlerQuotaService();
    const deps = {
      provider,
      quotaService: quota,
      tokenVerifier: async () => validPayload("user-a"),
      now: () => new Date("2026-05-16T12:00:00.000Z"),
    };

    const first = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "spent 250",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv({ AI_PARSE_DAILY_USER_LIMIT: "1" }),
      undefined,
      deps,
    );
    expect(first.status).toBe(200);

    const blocked = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "spent 300",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv({ AI_PARSE_DAILY_USER_LIMIT: "1" }),
      undefined,
      deps,
    );
    const body = await readJson(blocked);

    expect(blocked.status).toBe(429);
    expect(body).toMatchObject({
      ok: false,
      errorCode: "quota_exceeded",
      errorMessage: "Daily AI limit reached for this request type.",
      quota: {
        requestType: "parse_text",
        allowed: false,
        limit: 1,
        used: 1,
        remaining: 0,
        resetAt: "2026-05-17T00:00:00.000Z",
      },
    });
    expect(body).not.toHaveProperty("localQuota");
    expect(body).not.toHaveProperty("rewardedAd");
    expect(provider.parseCalls).toBe(1);
  });
});
