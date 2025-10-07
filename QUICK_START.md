# 🚀 Быстрый старт Docker

## ⚡ Основные команды

### Первый запуск:
```bash
# Сборка и запуск
docker-compose up -d --build

# Проверка статуса
docker-compose ps

# Просмотр логов
docker-compose logs -f app
```

### Если была ошибка с tailwindcss:
```bash
# Windows (PowerShell):
.\rebuild.ps1

# Linux/Mac:
chmod +x rebuild.sh
./rebuild.sh
```

Затем:
```bash
docker-compose up -d
```

## 🌐 Доступ к приложению

После успешного запуска:
- **Через Nginx:** http://localhost
- **Напрямую:** http://localhost:3000

## 📋 Полезные команды

```bash
# Остановить контейнеры
docker-compose stop

# Запустить остановленные контейнеры
docker-compose start

# Перезапустить
docker-compose restart

# Остановить и удалить контейнеры
docker-compose down

# Полная очистка (включая volumes)
docker-compose down -v

# Просмотр логов
docker-compose logs -f        # Все сервисы
docker-compose logs -f app    # Только приложение
docker-compose logs -f nginx  # Только nginx

# Проверка ресурсов
docker stats

# Войти в контейнер
docker-compose exec app sh
```

## 🔧 Режимы работы

### Production (Продакшен):
```bash
docker-compose up -d
```

### Development (Разработка):
```bash
docker-compose -f docker-compose.dev.yml up -d
```

## ❓ Решение проблем

### Порт занят:
```bash
# Изменить порт в docker-compose.yml:
ports:
  - "3001:3000"  # Изменить первое число
```

### Контейнер не запускается:
```bash
# Проверить логи
docker-compose logs app

# Пересобрать без кэша
docker-compose build --no-cache app
docker-compose up -d
```

### Проблемы с правами (Linux):
```bash
sudo chown -R $USER:$USER .
```

## 📚 Дополнительная документация

- **README.Docker.md** - Полная документация по Docker
- **DOCKER_FIX.md** - Решение проблемы с tailwindcss и другие исправления
- **deploy.sh** - Скрипт автоматического деплоя

## 🎯 Чек-лист готовности к продакшену

- [ ] Проверить переменные окружения (.env)
- [ ] Настроить SSL сертификаты (nginx/ssl/)
- [ ] Раскомментировать HTTPS в nginx.conf
- [ ] Настроить домен
- [ ] Настроить мониторинг
- [ ] Настроить бэкапы
- [ ] Проверить health checks
- [ ] Настроить CI/CD

## 💡 Советы

1. **BuildKit ускоряет сборку:**
   ```bash
   DOCKER_BUILDKIT=1 docker-compose build
   ```

2. **Следите за размером образов:**
   ```bash
   docker images | grep shedule_smtu
   ```

3. **Регулярно чистите неиспользуемые ресурсы:**
   ```bash
   docker system prune -a
   ```

4. **Используйте watch для автоматического перезапуска:**
   ```bash
   watch -n 5 docker-compose ps
   ```

## 🆘 Нужна помощь?

1. Проверьте логи: `docker-compose logs -f`
2. Прочитайте DOCKER_FIX.md
3. Проверьте статус: `docker-compose ps`
4. Проверьте ресурсы: `docker stats`

---

**Успешного деплоя! 🚀**

