#!/bin/bash

# Скрипт для чистой пересборки Docker образа

echo "🧹 Очистка старых контейнеров и образов..."
docker-compose down -v

echo "🗑️  Удаление старых образов shedule_smtu..."
docker images | grep shedule_smtu | awk '{print $3}' | xargs -r docker rmi -f

echo "🔨 Пересборка образа без кэша..."
docker-compose build --no-cache

echo "✅ Сборка завершена!"
echo ""
echo "Для запуска используйте:"
echo "  docker-compose up -d     # Запуск в фоне"
echo "  docker-compose up        # Запуск с логами"
echo "  docker-compose logs -f   # Просмотр логов"

