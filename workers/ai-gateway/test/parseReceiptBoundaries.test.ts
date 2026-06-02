import { describe, expect, test } from "vitest";
import { handleParseExpense } from "../src/handlers/parseExpense";
import { handleReceiptExtraction } from "../src/handlers/receiptExtraction";
import { InMemoryUsageLogService } from "../src/quota/usageLogService";
import {
  FakeProvider,
  jsonRequest,
  quotaService,
  readJson,
  testEnv,
  validVerifier,
} from "./helpers";

const validImageBase64 = "a".repeat(40);

describe("parse and receipt request boundaries", () => {
  test("parse rejects oversized text before provider call and does not log it", async () => {
    const provider = new FakeProvider();
    const logs = new InMemoryUsageLogService();
    const rawInput = "spent ".repeat(500);
    const response = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: rawInput,
        now: "2026-06-01T12:00:00.000Z",
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
    const body = await readJson(response);

    expect(response.status).toBe(413);
    expect(body.errorCode).toBe("invalid_request");
    expect(provider.parseCalls).toBe(0);
    expect(JSON.stringify(logs.entries)).not.toContain(rawInput);
  });

  test("parse accepts normal Arabic input", async () => {
    const provider = new FakeProvider();
    const response = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "صرفت 250 جنيه على أكل",
        now: "2026-06-01T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
    );

    expect(response.status).toBe(200);
    expect(provider.parseCalls).toBe(1);
  });

  test("receipt rejects disallowed image mime types", async () => {
    const provider = new FakeProvider();
    const response = await handleReceiptExtraction(
      jsonRequest("/aiReceipt", {
        imageBase64: validImageBase64,
        mimeType: "image/svg+xml",
        now: "2026-06-01T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
    );
    const body = await readJson(response);

    expect(response.status).toBe(400);
    expect(body.errorCode).toBe("invalid_request");
    expect(provider.receiptCalls).toBe(0);
  });

  test("receipt rejects oversized images before provider call", async () => {
    const provider = new FakeProvider();
    const response = await handleReceiptExtraction(
      jsonRequest("/aiReceipt", {
        imageBase64: "a".repeat(6 * 1024 * 1024 + 1),
        mimeType: "image/png",
        now: "2026-06-01T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
    );

    expect(response.status).toBe(413);
    expect(provider.receiptCalls).toBe(0);
  });

  test("receipt accepts jpeg png and webp inputs", async () => {
    for (const mimeType of ["image/jpeg", "image/png", "image/webp"]) {
      const provider = new FakeProvider();
      const response = await handleReceiptExtraction(
        jsonRequest("/aiReceipt", {
          imageBase64: validImageBase64,
          mimeType,
          now: "2026-06-01T12:00:00.000Z",
        }),
        testEnv(),
        undefined,
        { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
      );

      expect(response.status).toBe(200);
      expect(provider.receiptCalls).toBe(1);
    }
  });
});
