# Dockerfile для продакшена Nuxt.js приложения

# Этап 1: Базовый образ с pnpm
FROM node:20-alpine AS base

# Установка необходимых инструментов для сборки
RUN apk add --no-cache libc6-compat python3 make g++

# Настройка pnpm
RUN corepack enable && corepack prepare pnpm@10.18.0 --activate
ENV PNPM_HOME=/pnpm
ENV PATH="$PNPM_HOME:$PATH"

# Этап 2: Установка зависимостей
FROM base AS deps
WORKDIR /app

# Копируем файлы для установки зависимостей
COPY Frontend/package.json Frontend/pnpm-lock.yaml ./

# Создаем временный pnpm-workspace.yaml без игнорирования @tailwindcss/oxide
RUN echo "# Пустой workspace для Docker сборки" > pnpm-workspace.yaml

# Устанавливаем все зависимости (включая dev для сборки)
# Используем --no-frozen-lockfile чтобы pnpm мог разрешить зависимости без workspace ограничений
RUN pnpm install --no-frozen-lockfile

# Устанавливаем tailwindcss явно, если его нет
RUN pnpm add -D tailwindcss@latest || true

# Этап 3: Сборка приложения
FROM base AS builder
WORKDIR /app

# Копируем все файлы проекта, кроме node_modules
COPY Frontend/package.json Frontend/pnpm-lock.yaml ./
COPY Frontend/nuxt.config.ts Frontend/tsconfig.json ./
COPY Frontend/eslint.config.mjs ./
COPY Frontend/app ./app
COPY Frontend/server ./server
COPY Frontend/public ./public

# Копируем установленные зависимости
COPY --from=deps /app/node_modules ./node_modules

# Создаем пустой pnpm-workspace.yaml для сборки
RUN echo "# Пустой workspace для Docker сборки" > pnpm-workspace.yaml

# Собираем приложение
RUN pnpm run build

# Этап 4: Production образ (минимальный)
FROM node:20-alpine AS runner
WORKDIR /app

# Устанавливаем только runtime зависимости (без build tools)
RUN apk add --no-cache libc6-compat

# Создаем пользователя без прав root для безопасности
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nuxtjs

# Копируем собранное приложение
COPY --from=builder --chown=nuxtjs:nodejs /app/.output /app/.output

# Переключаемся на непривилегированного пользователя
USER nuxtjs

# Открываем порт
EXPOSE 3000

# Переменные окружения
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000
ENV NITRO_HOST=0.0.0.0
ENV NITRO_PORT=3000

# Запускаем приложение
CMD ["node", ".output/server/index.mjs"]

