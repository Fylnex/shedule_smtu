# Docker Development & Production Guide

## 📋 Требования

- Docker Engine 20.10+
- Docker Compose 2.0+
- Минимум 2GB свободного места на диске

## 🚀 Быстрый старт

### Production (Продакшен)

```bash
# Сборка и запуск
docker-compose up -d

# Приложение будет доступно на:
# - http://localhost - через Nginx
# - http://localhost:3000 - напрямую Nuxt

# Просмотр логов
docker-compose logs -f

# Остановка
docker-compose down

# Полная очистка (включая volumes)
docker-compose down -v
```

### Development (Разработка)

```bash
# Запуск в режиме разработки
docker-compose -f docker-compose.dev.yml up -d

# Приложение будет доступно на http://localhost:3000
# Hot reload включен

# Просмотр логов
docker-compose -f docker-compose.dev.yml logs -f

# Остановка
docker-compose -f docker-compose.dev.yml down
```

## 📁 Структура файлов

```
.
├── Dockerfile                  # Multi-stage production build
├── docker-compose.yml         # Production configuration
├── docker-compose.dev.yml     # Development configuration
├── .dockerignore              # Игнорируемые файлы при сборке
├── .env.example               # Пример переменных окружения
├── nginx/
│   ├── nginx.conf            # Конфигурация Nginx
│   └── ssl/                  # SSL сертификаты (создать при необходимости)
└── Frontend/                  # Исходный код приложения
```

## 🔧 Конфигурация

### Переменные окружения

1. Скопируйте `.env.example` в `.env`:
```bash
cp .env.example .env
```

2. Отредактируйте `.env` под свои нужды

### Nginx и SSL

Для включения HTTPS:

1. Поместите SSL сертификаты в `nginx/ssl/`:
   - `cert.pem` - сертификат
   - `key.pem` - приватный ключ

2. Раскомментируйте HTTPS блок в `nginx/nginx.conf`

## 🛠️ Полезные команды

### Сборка

```bash
# Пересборка образов
docker-compose build

# Пересборка без кэша
docker-compose build --no-cache

# Сборка только app сервиса
docker-compose build app
```

### Управление

```bash
# Запуск в фоне
docker-compose up -d

# Запуск с пересборкой
docker-compose up -d --build

# Остановка всех сервисов
docker-compose stop

# Перезапуск сервиса
docker-compose restart app

# Масштабирование (только для app без nginx)
docker-compose up -d --scale app=3
```

### Логи и мониторинг

```bash
# Все логи
docker-compose logs

# Логи конкретного сервиса
docker-compose logs app
docker-compose logs nginx

# Логи в реальном времени
docker-compose logs -f

# Последние 100 строк
docker-compose logs --tail=100
```

### Отладка

```bash
# Запуск bash в контейнере
docker-compose exec app sh

# Проверка состояния контейнеров
docker-compose ps

# Проверка использования ресурсов
docker stats

# Проверка health check
docker-compose ps
```

### Очистка

```bash
# Удаление контейнеров
docker-compose down

# Удаление контейнеров и volumes
docker-compose down -v

# Удаление всего (включая images)
docker-compose down --rmi all -v

# Очистка неиспользуемых Docker ресурсов
docker system prune -a
```

## 🔍 Проверка работоспособности

```bash
# Health check приложения
curl http://localhost:3000

# Health check Nginx
curl http://localhost/health

# Проверка всех контейнеров
docker-compose ps
```

## 📊 Мониторинг

```bash
# Использование ресурсов в реальном времени
docker stats

# Детальная информация о контейнере
docker inspect shedule_smtu_app

# Логи с фильтрацией
docker-compose logs app | grep ERROR
```

## 🔐 Безопасность

1. **Не комитьте `.env` файл** - он в `.gitignore`
2. **Используйте secrets** для чувствительных данных:
```yaml
secrets:
  db_password:
    file: ./secrets/db_password.txt
```
3. **Регулярно обновляйте образы**:
```bash
docker-compose pull
docker-compose up -d
```

## 🚢 Деплой на сервер

### 1. Подготовка сервера

```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Деплой приложения

```bash
# Клонирование репозитория
git clone <your-repo-url>
cd shedule_smtu

# Настройка окружения
cp .env.example .env
nano .env

# Запуск
docker-compose up -d

# Проверка
docker-compose ps
```

### 3. Автоматические обновления

Создайте скрипт `deploy.sh`:

```bash
#!/bin/bash
git pull
docker-compose down
docker-compose build
docker-compose up -d
docker-compose logs -f
```

## 🐛 Решение проблем

### Порт уже используется

```bash
# Найти процесс на порту 3000
netstat -ano | findstr :3000  # Windows
lsof -i :3000                 # Linux/Mac

# Изменить порт в docker-compose.yml
ports:
  - "3001:3000"
```

### Проблемы с правами доступа

```bash
# Пересоздать с правильными правами
docker-compose down -v
docker-compose up -d --build
```

### Контейнер постоянно перезапускается

```bash
# Проверить логи
docker-compose logs app

# Проверить health check
docker inspect shedule_smtu_app | grep Health
```

## 📚 Дополнительные ресурсы

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Nuxt.js Deployment](https://nuxt.com/docs/getting-started/deployment)
- [Nginx Documentation](https://nginx.org/en/docs/)

## 📝 Примечания

- Production образ использует multi-stage build для минимального размера
- Приложение запускается от непривилегированного пользователя (nuxtjs)
- Nginx настроен с gzip сжатием и кэшированием
- Health checks настроены для мониторинга состояния
- Volumes используются для персистентности данных Nginx cache

