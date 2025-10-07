# PowerShell скрипт для чистой пересборки Docker образа (Windows)

Write-Host "🧹 Очистка старых контейнеров и образов..." -ForegroundColor Yellow
docker-compose down -v

Write-Host "🗑️  Удаление старых образов shedule_smtu..." -ForegroundColor Yellow
docker images | Select-String "shedule_smtu" | ForEach-Object {
    $imageId = ($_ -split '\s+')[2]
    docker rmi -f $imageId
}

Write-Host "🔨 Пересборка образа без кэша..." -ForegroundColor Yellow
docker-compose build --no-cache

Write-Host "✅ Сборка завершена!" -ForegroundColor Green
Write-Host ""
Write-Host "Для запуска используйте:" -ForegroundColor Cyan
Write-Host "  docker-compose up -d     # Запуск в фоне"
Write-Host "  docker-compose up        # Запуск с логами"
Write-Host "  docker-compose logs -f   # Просмотр логов"

