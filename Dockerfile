# Dockerfile для продакшена Nuxt.js приложения

# Этап 1: Базовый образ с pnpm
FROM node:20-alpine AS base
RUN corepack enable && corepack prepare pnpm@10.18.0 --activate
ENV PNPM_HOME=/pnpm
ENV PATH="$PNPM_HOME:$PATH"

# Этап 2: Установка зависимостей
FROM base AS deps
WORKDIR /app
COPY Frontend/package.json Frontend/pnpm-lock.yaml Frontend/pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile --prod=false

# Этап 3: Сборка приложения
FROM base AS builder
WORKDIR /app
COPY Frontend/ ./
COPY --from=deps /app/node_modules ./node_modules
RUN pnpm run build

# Этап 4: Production образ
FROM base AS runner
WORKDIR /app

# Создаем пользователя без прав root для безопасности
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nuxtjs

# Копируем необходимые файлы
COPY --from=builder --chown=nuxtjs:nodejs /app/.output /app/.output
COPY --from=builder --chown=nuxtjs:nodejs /app/package.json /app/package.json

# Переключаемся на непривилегированного пользователя
USER nuxtjs

# Открываем порт
EXPOSE 3000

# Переменные окружения
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

# Запускаем приложение
CMD ["node", ".output/server/index.mjs"]

