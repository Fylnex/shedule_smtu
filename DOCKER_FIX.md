# 🔧 Решение проблемы сборки Docker

## ❌ Проблема

При сборке Docker образа возникала ошибка:
```
ERROR  ✗ Build failed in 828ms
[nuxi]  ERROR  Nuxt Build Error: [@tailwindcss/vite:generate:build] Can't resolve 'tailwindcss' in '/app/app/assets/css'
```

## ✅ Решение

Проблема была в том, что:
1. Не устанавливались build tools для компиляции нативных зависимостей (например, `@tailwindcss/oxide`)
2. Использовался флаг `--prod=false` вместо просто установки всех зависимостей
3. Не хватало необходимых системных библиотек

## 🚀 Исправленный Dockerfile

### Основные изменения:

1. **Добавлены build tools:**
```dockerfile
RUN apk add --no-cache libc6-compat python3 make g++
```

2. **Исправлена установка зависимостей:**
```dockerfile
# Было:
RUN pnpm install --frozen-lockfile --prod=false

# Стало:
RUN pnpm install --frozen-lockfile
```

3. **Оптимизирован финальный образ:**
- Используется чистый alpine образ без build tools
- Только runtime зависимости (libc6-compat)
- Копируется только собранное приложение (.output)

## 📦 Доступные версии Dockerfile

### 1. `Dockerfile` - Стандартная версия
Рекомендуется для использования:
```bash
docker-compose build
```

### 2. `Dockerfile.optimized` - Оптимизированная версия
Использует pnpm fetch для лучшего кэширования:
```bash
docker build -f Dockerfile.optimized -t shedule_smtu:optimized .
```

## 🔨 Команды для сборки

### Чистая пересборка:
```bash
# Остановить и удалить контейнеры
docker-compose down

# Пересобрать без кэша
docker-compose build --no-cache

# Запустить
docker-compose up -d
```

### Быстрая пересборка:
```bash
docker-compose up -d --build
```

### Проверка логов во время сборки:
```bash
docker-compose up --build
```

## 🐛 Если проблема все еще есть

### 1. Очистить весь Docker кэш:
```bash
docker system prune -a --volumes
docker-compose build --no-cache
```

### 2. Проверить версии:
```bash
docker --version
docker-compose --version
node --version
```

### 3. Проверить package.json и зависимости:
```bash
cd Frontend
pnpm install
pnpm run build
```

Если локально сборка проходит успешно, то Docker тоже должен работать.

### 4. Увеличить ресурсы Docker:
Убедитесь, что Docker имеет достаточно ресурсов:
- RAM: минимум 4GB
- Disk: минимум 20GB свободного места

## 📊 Размеры образов

После оптимизации:
- Base image (node:20-alpine): ~170MB
- С зависимостями для сборки: ~800MB (builder stage)
- Финальный production образ: ~200-300MB

## 🔍 Отладка

### Проверить какой этап падает:
```bash
docker build -f Dockerfile --target deps -t test-deps .
docker build -f Dockerfile --target builder -t test-builder .
docker build -f Dockerfile --target runner -t test-runner .
```

### Войти в контейнер для отладки:
```bash
docker run -it --rm test-builder sh
```

### Проверить установленные зависимости:
```bash
docker run -it --rm test-deps sh -c "ls -la node_modules/@nuxt"
```

## ✨ Дополнительные оптимизации

### BuildKit для более быстрой сборки:
```bash
DOCKER_BUILDKIT=1 docker-compose build
```

### Использование .dockerignore:
Убедитесь, что `.dockerignore` правильно настроен для исключения ненужных файлов.

### Кэширование слоев:
Порядок команд в Dockerfile оптимизирован для максимального использования кэша Docker.

## 📚 Полезные ссылки

- [Nuxt Deployment Guide](https://nuxt.com/docs/getting-started/deployment)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [PNPM in Docker](https://pnpm.io/docker)
- [Alpine Linux Packages](https://pkgs.alpinelinux.org/packages)

## 💡 Рекомендации

1. **Используйте BuildKit** для более быстрой сборки
2. **Регулярно чистите** Docker кэш для освобождения места
3. **Мониторьте размер** финального образа
4. **Используйте .dockerignore** для исключения ненужных файлов
5. **Тестируйте локально** перед деплоем на сервер

