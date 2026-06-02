import { describe, expect, test } from "vitest";
import { handleFinancialAdvice } from "../src/handlers/financialAdvice";
import {
  FakeProvider,
  jsonRequest,
  quotaService,
  readJson,
  testEnv,
  validVerifier,
} from "./helpers";

describe("/aiAdvice", () => {
  test("valid monthly summary returns short advice payload", async () => {
    const response = await handleFinancialAdvice(
      jsonRequest("/aiAdvice", {
        period: "month",
        now: "2026-05-16T12:00:00.000Z",
        summary: { total: 500, currency: "EGP" },
      }),
      testEnv(),
      undefined,
      {
        provider: new FakeProvider(),
        quotaService: quotaService(),
        tokenVerifier: validVerifier,
      },
    );
    const body = await readJson(response);
    expect(response.status).toBe(200);
    expect(body.structuredJson).toMatchObject({
      period: "month",
      advice: "حدد ميزانية مطاعم أقل هذا الشهر.",
    });
  });

  test("missing summary returns invalid_request", async () => {
    const provider = new FakeProvider();
    const response = await handleFinancialAdvice(
      jsonRequest("/aiAdvice", {
        period: "month",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
    );
    expect((await readJson(response)).errorCode).toBe("invalid_request");
    expect(provider.adviceCalls).toBe(0);
  });

  test("oversized summary returns invalid_request before provider call", async () => {
    const provider = new FakeProvider();
    const response = await handleFinancialAdvice(
      jsonRequest("/aiAdvice", {
        period: "month",
        now: "2026-05-16T12:00:00.000Z",
        summary: { riskFlags: Array.from({ length: 6000 }, () => "large") },
      }),
      testEnv(),
      undefined,
      { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
    );
    const body = await readJson(response);
    expect(response.status).toBe(413);
    expect(body.errorCode).toBe("invalid_request");
    expect(provider.adviceCalls).toBe(0);
  });

  test("raw-row-looking summary keys return invalid_request", async () => {
    const provider = new FakeProvider();
    const response = await handleFinancialAdvice(
      jsonRequest("/aiAdvice", {
        period: "month",
        now: "2026-05-16T12:00:00.000Z",
        summary: {
          totalSpent: 500,
          transactions: [{ merchant: "Private shop", amount: 100 }],
        },
      }),
      testEnv(),
      undefined,
      { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
    );
    const body = await readJson(response);
    expect(response.status).toBe(400);
    expect(body.errorCode).toBe("invalid_request");
    expect(body.errorMessage).not.toContain("Private shop");
    expect(provider.adviceCalls).toBe(0);
  });

  test("invalid period returns invalid_request", async () => {
    const provider = new FakeProvider();
    const response = await handleFinancialAdvice(
      jsonRequest("/aiAdvice", {
        period: "year",
        now: "2026-05-16T12:00:00.000Z",
        summary: { total: 500 },
      }),
      testEnv(),
      undefined,
      { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
    );
    expect((await readJson(response)).errorCode).toBe("invalid_request");
    expect(provider.adviceCalls).toBe(0);
  });

  test("quota exhausted prevents provider call", async () => {
    const provider = new FakeProvider();
    const quota = quotaService();
    const deps = { provider, quotaService: quota, tokenVerifier: validVerifier };
    const body = {
      period: "week",
      now: "2026-05-16T12:00:00.000Z",
      summary: { total: 500 },
    };
    await handleFinancialAdvice(
      jsonRequest("/aiAdvice", body),
      testEnv({ AI_ADVICE_DAILY_USER_LIMIT: "1" }),
      undefined,
      deps,
    );
    const second = await handleFinancialAdvice(
      jsonRequest("/aiAdvice", body),
      testEnv({ AI_ADVICE_DAILY_USER_LIMIT: "1" }),
      undefined,
      deps,
    );
    const errorBody = await readJson(second);
    expect(errorBody.errorCode).toBe("quota_exceeded");
    expect(errorBody.quota).toMatchObject({
      requestType: "financial_advice",
      allowed: false,
      limit: 1,
      used: 1,
      remaining: 0,
    });
    expect(provider.adviceCalls).toBe(1);
  });

  test("provider output is grounded in supplied summary fixture", async () => {
    const response = await handleFinancialAdvice(
      jsonRequest("/aiAdvice", {
        period: "month",
        now: "2026-05-16T12:00:00.000Z",
        summary: { categoryTotals: [{ category: "Food", amount: 500 }] },
      }),
      testEnv(),
      undefined,
      {
        provider: new FakeProvider(),
        quotaService: quotaService(),
        tokenVerifier: validVerifier,
      },
    );
    const body = await readJson(response);
    expect(JSON.stringify(body.structuredJson)).not.toContain("invented");
    expect(body.ok).toBe(true);
  });
});
