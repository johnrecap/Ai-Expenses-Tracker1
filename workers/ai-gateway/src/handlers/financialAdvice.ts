import { FirebaseJwtVerifier, requireFirebaseUser } from "../auth/firebaseTokenVerifier";
import { GeminiProvider } from "../ai/geminiProvider";
import {
  AiFinancialAdviceRequestBody,
  AiGatewayError,
  AiProvider,
  AiRequestType,
  isAiGatewayError,
} from "../ai/providerTypes";
import { getGatewayConfig, WorkerEnv } from "../config";
import { errorResponse, successResponse } from "../http/response";
import {
  dateKeyFromDate,
  D1UsageCounterStore,
  quotaStatusForBlocked,
  QuotaService,
} from "../quota/quotaService";
import {
  D1UsageLogService,
  safeLogUsage,
  UsageLogService,
} from "../quota/usageLogService";

export interface FinancialAdviceDependencies {
  provider?: AiProvider;
  quotaService?: QuotaService;
  usageLogService?: UsageLogService;
  tokenVerifier?: FirebaseJwtVerifier;
  now?: () => Date;
}

const requestType: AiRequestType = "financial_advice";
const maxAdvicePayloadBytes = 25 * 1024;
const forbiddenRawKeyFragments = [
  "transaction",
  "transactions",
  "expense",
  "expenses",
  "merchant",
  "description",
  "receipt",
  "rawtext",
  "raw_text",
  "ocr",
  "email",
  "phone",
];

export async function handleFinancialAdvice(
  request: Request,
  env: WorkerEnv,
  ctx?: ExecutionContext,
  deps: FinancialAdviceDependencies = {},
): Promise<Response> {
  const requestId = crypto.randomUUID();
  let uid = "unknown";
  let dateKey = dateKeyFromDate(deps.now?.() ?? new Date());

  try {
    if (request.method !== "POST") {
      throw new AiGatewayError("invalid_request", "Only POST is supported.", 405);
    }
    const config = getGatewayConfig(env);
    const providerName = deps.provider?.provider ?? config.provider;
    const model = deps.provider?.model ?? config.model;
    const quotaService =
      deps.quotaService ?? new QuotaService(new D1UsageCounterStore(config.db));
    const usageLogService =
      deps.usageLogService ?? new D1UsageLogService(config.db);
    const body = validateAdviceRequestBody(await parseJsonBody(request));
    const user = await requireFirebaseUser(
      request.headers.get("authorization"),
      config.firebaseProjectId,
      deps.tokenVerifier,
    );
    uid = user.uid;
    dateKey = dateKeyFromDate(deps.now?.() ?? new Date());

    const quota = await quotaService.consume({
      uid,
      dateKey,
      requestType,
      provider: providerName,
      model,
      userLimit: config.userLimits.financial_advice,
      globalLimit: config.globalLimits.financial_advice,
    });

    const provider = deps.provider ?? new GeminiProvider(config);
    const providerResult = await provider.financialAdvice(body);
    await logUsage(ctx, usageLogService, {
      uid,
      dateKey,
      requestType,
      status: "success",
      provider: provider.provider,
      model: provider.model,
      requestId,
      inputTokens: providerResult.usage?.inputTokens,
      outputTokens: providerResult.usage?.outputTokens,
      createdAt: new Date().toISOString(),
    });

    return successResponse({
      provider: provider.provider,
      model: provider.model,
      requestId,
      usage: providerResult.usage,
      quota,
      structuredJson: providerResult.structuredJson,
    });
  } catch (error) {
    const config = tryConfig(env);
    const usageLogService =
      deps.usageLogService ??
      (config ? new D1UsageLogService(config.db) : undefined);
    const providerName = deps.provider?.provider ?? config?.provider ?? "gemini";
    const model = deps.provider?.model ?? config?.model ?? "gemini-2.5-flash";
    if (usageLogService) {
      await logUsage(ctx, usageLogService, {
        uid,
        dateKey,
        requestType,
        status:
          isAiGatewayError(error) && error.code === "quota_exceeded"
            ? "quota_blocked"
            : "failure",
        provider: providerName,
        model,
        requestId,
        errorCode: isAiGatewayError(error) ? error.code : undefined,
        createdAt: new Date().toISOString(),
      });
    }
    return errorResponse({
      error,
      provider: providerName,
      model,
      requestId,
      quota:
        isAiGatewayError(error) &&
        error.code === "quota_exceeded" &&
        error.message.includes("request type") &&
        uid !== "unknown"
          ? quotaStatusForBlocked(
              requestType,
              config?.userLimits.financial_advice ?? 3,
              dateKey,
            )
          : undefined,
    });
  }
}

export function validateAdviceRequestBody(
  body: unknown,
): AiFinancialAdviceRequestBody {
  if (!body || typeof body !== "object" || Array.isArray(body)) {
    throw new AiGatewayError("invalid_request", "Request body is required.", 400);
  }
  const candidate = body as Record<string, unknown>;
  const payloadBytes = new TextEncoder().encode(JSON.stringify(candidate)).length;
  if (payloadBytes > maxAdvicePayloadBytes) {
    throw new AiGatewayError("invalid_request", "Advice payload is too large.", 413);
  }
  if (candidate.period !== "week" && candidate.period !== "month") {
    throw new AiGatewayError("invalid_request", "Supported period is required.", 400);
  }
  const now = readTrimmedString(candidate.now);
  if (!now || Number.isNaN(Date.parse(now))) {
    throw new AiGatewayError("invalid_request", "Valid now value is required.", 400);
  }
  if (
    !candidate.summary ||
    typeof candidate.summary !== "object" ||
    Array.isArray(candidate.summary)
  ) {
    throw new AiGatewayError("invalid_request", "Spending summary is required.", 400);
  }
  const forbiddenKey = findForbiddenRawKey(candidate.summary);
  if (forbiddenKey) {
    throw new AiGatewayError(
      "invalid_request",
      "Advice requests must contain summary-only data.",
      400,
    );
  }

  return {
    period: candidate.period,
    now,
    locale: readTrimmedString(candidate.locale) ?? "ar-EG",
    defaultCurrency: readTrimmedString(candidate.defaultCurrency) ?? "EGP",
    clientRequestId: readTrimmedString(candidate.clientRequestId),
    summary: candidate.summary as Record<string, unknown>,
  };
}

function findForbiddenRawKey(value: unknown): string | undefined {
  if (!value || typeof value !== "object") return undefined;
  if (Array.isArray(value)) {
    if (value.length > 25) return "largeArray";
    for (const item of value) {
      const forbidden = findForbiddenRawKey(item);
      if (forbidden) return forbidden;
    }
    return undefined;
  }

  for (const [key, item] of Object.entries(value as Record<string, unknown>)) {
    const normalized = key.toLowerCase().replace(/[^a-z0-9]/g, "");
    if (
      forbiddenRawKeyFragments.some((fragment) =>
        normalized.includes(fragment.replace(/[^a-z0-9]/g, "")),
      )
    ) {
      return key;
    }
    const forbidden = findForbiddenRawKey(item);
    if (forbidden) return forbidden;
  }
  return undefined;
}

async function parseJsonBody(request: Request): Promise<unknown> {
  try {
    return await request.json();
  } catch {
    throw new AiGatewayError("invalid_request", "Request body must be valid JSON.", 400);
  }
}

function readTrimmedString(value: unknown) {
  return typeof value === "string" && value.trim().length > 0
    ? value.trim()
    : undefined;
}

async function logUsage(
  ctx: ExecutionContext | undefined,
  service: UsageLogService,
  entry: Parameters<typeof safeLogUsage>[1],
) {
  const promise = safeLogUsage(service, entry);
  if (ctx) {
    ctx.waitUntil(promise);
    return;
  }
  await promise;
}

function tryConfig(env: WorkerEnv) {
  try {
    return getGatewayConfig(env);
  } catch {
    return undefined;
  }
}
