Вот пример файла `README.md` для этого скрипта:

```markdown
# Backup to Yandex Cloud S3

Этот скрипт предназначен для резервного копирования архивов (.tar) из локальной директории на сервере в объектное хранилище Yandex Cloud S3. Перед загрузкой каждого файла проверяется его наличие в хранилище, чтобы избежать дублирования. Логи всех операций записываются в файл `/var/log/backup_yandex.log`.

## Требования

- Установленная утилита `s3cmd`
- Настроенная конфигурация `s3cmd` для доступа к Yandex Cloud S3
- Права на запись в файл `/var/log/backup_yandex.log`

## Установка

1. Установите `s3cmd` на сервер:

   ```bash
   sudo apt update
   sudo apt install s3cmd
   ```

2. Настройте `s3cmd`, указав доступы к Yandex Cloud S3:

   ```bash
   s3cmd --configure
   ```

   Вам будут предложены ключи доступа, секретные ключи и регион. Используйте следующие параметры:
   - **Access Key**: ваш Yandex Cloud Access Key
   - **Secret Key**: ваш Yandex Cloud Secret Key
   - **Default Region**: `ru-central1`
   - **Endpoint**: `storage.yandexcloud.net`
   - **Use HTTPS**: `yes`

3. Создайте файл логов и дайте права на запись:

   ```bash
   sudo touch /var/log/backup_yandex.log
   sudo chmod 666 /var/log/backup_yandex.log
   ```

4. Поместите скрипт в удобную директорию и сделайте его исполняемым:

   ```bash
   chmod +x /path/to/backup-script.sh
   ```

## Настройка

В скрипте задаются следующие переменные:

- **SOURCE_DIR** — директория, в которой хранятся архивы для резервного копирования. По умолчанию это `/backup`.
- **LOG_FILE** — путь к файлу логов. По умолчанию это `/var/log/backup_yandex.log`.

## Использование

Запустите скрипт для резервного копирования:

```bash
sudo /path/to/backup-script.sh
```

Скрипт будет выполнять следующие шаги:
1. Проверка каждого файла с расширением `.tar` в директории `/backup`.
2. Если файл уже существует в хранилище Yandex Cloud, загрузка пропускается.
3. Если файл не найден, он загружается в указанный бакет в Yandex Cloud S3.
4. Все действия логируются в файл `/var/log/backup_yandex.log`.

## Автоматизация с помощью Cron

Чтобы автоматизировать процесс резервного копирования, можно добавить этот скрипт в расписание Cron:

1. Откройте редактор cron:

   ```bash
   crontab -e
   ```

2. Добавьте строку для ежедневного запуска, например, в 2 часа ночи:

   ```bash
   0 2 * * * sudo /path/to/backup-script.sh
   ```

Теперь скрипт будет запускаться автоматически каждый день в 2 часа ночи.

## Логи

Все события, включая проверки, загрузки и ошибки, записываются в файл `/var/log/backup_yandex.log`. Пример содержимого файла логов:

```
2024-10-10 14:00:00 - Backup process started.
2024-10-10 14:00:01 - Checking if backup-2024-10-10.tar exists in Yandex Cloud S3...
2024-10-10 14:00:02 - Backup backup-2024-10-10.tar already exists in Yandex Cloud S3. Skipping upload.
2024-10-10 14:00:03 - Backup process completed.
```

## Лицензия

Этот проект распространяется под лицензией MIT. 
```

### Описание файла `README.md`:
- **Требования** описывают необходимые компоненты для работы скрипта.
- **Установка** пошагово объясняет, как настроить и подготовить окружение.
- **Настройка** и **Использование** описывают работу скрипта и его параметры.
- **Автоматизация с помощью Cron** объясняет, как настроить автоматический запуск.
- **Логи** предоставляют информацию о файле логов.