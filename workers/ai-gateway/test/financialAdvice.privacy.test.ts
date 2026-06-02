import { describe, expect, test } from "vitest";
import { handleFinancialAdvice } from "../src/handlers/financialAdvice";
import { InMemoryUsageLogService } from "../src/quota/usageLogService";
import {
  FakeProvider,
  jsonRequest,
  quotaService,
  readJson,
  testEnv,
  validVerifier,
} from "./helpers";

describe("/aiAdvice privacy boundaries", () => {
  test("rejects raw merchant and expense rows before provider call", async () => {
    const provider = new FakeProvider();
    const response = await handleFinancialAdvice(
      jsonRequest("/aiAdvice", {
        period: "month",
        now: "2026-06-01T12:00:00.000Z",
        summary: {
          totalSpent: 500,
          recentExpenses: [{ merchant: "Private Pharmacy", amount: 100 }],
        },
      }),
      testEnv(),
      undefined,
      { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
    );
    const body = await readJson(response);

    expect(response.status).toBe(400);
    expect(body.errorCode).toBe("invalid_request");
    expect(body.errorMessage).not.toContain("Private Pharmacy");
    expect(provider.adviceCalls).toBe(0);
  });

  test("rejects receipt text and does not log raw content", async () => {
    const provider = new FakeProvider();
    const logs = new InMemoryUsageLogService();
    const secret = "SECRET RECEIPT TEXT";
    const response = await handleFinancialAdvice(
      jsonRequest("/aiAdvice", {
        period: "month",
        now: "2026-06-01T12:00:00.000Z",
        summary: {
          totalSpent: 500,
          receiptRawText: secret,
        },
      }),
      testEnv(),
      undefined,
      {
        provider,
        quotaService: quotaService(),
        usageLogService: logs,
        tokenVerifier: validVerifier,
      },
    );

    expect(response.status).toBe(400);
    expect(provider.adviceCalls).toBe(0);
    expect(JSON.stringify(logs.entries)).not.toContain(secret);
  });

  test("rejects oversized compact summaries before provider call", async () => {
    const provider = new FakeProvider();
    const response = await handleFinancialAdvice(
      jsonRequest("/aiAdvice", {
        period: "month",
        now: "2026-06-01T12:00:00.000Z",
        summary: {
          riskFlags: Array.from({ length: 7000 }, () => "large"),
        },
      }),
      testEnv(),
      undefined,
      { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
    );

    expect(response.status).toBe(413);
    expect(provider.adviceCalls).toBe(0);
  });
});
