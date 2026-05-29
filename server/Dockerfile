# ── Build Stage ──────────────────────────────────────────────
FROM node:20-alpine AS build

WORKDIR /app

# Install build dependencies (TypeScript compilation)
COPY package.json package-lock.json* ./
RUN npm ci

# Copy source and compile
COPY tsconfig.json ./
COPY src/ ./src/
RUN npm run build

# Prune devDependencies for production
RUN npm ci --omit=dev && npm cache clean --force

# ── Production Stage ─────────────────────────────────────────
FROM node:20-alpine AS production

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy production node_modules from build
COPY --from=build /app/node_modules ./node_modules
# Copy compiled output
COPY --from=build /app/dist ./dist
# Copy package.json for metadata
COPY --from=build /app/package.json ./

# Copy migration files (needed for db:migrate at runtime)
COPY --from=build /app/src/db/migrations ./src/db/migrations

USER appuser

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=8080

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:8080/health || exit 1

CMD ["node", "dist/src/main.js"]
