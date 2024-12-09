#!/bin/bash

# Путь к конфигурационному файлу
CONFIG_FILE="/home/nikchester/backup_yandex_objective_storage/backup_config.txt"

# Файл для логов
LOG_FILE="/var/log/backup_yandex.log"

# Функция для записи в лог
log_message() {
  local MESSAGE="$1"
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $MESSAGE" >> $LOG_FILE
}

log_message "Backup process started."

# Читаем конфигурационный файл построчно
while read -r SOURCE_DIR S3_BUCKET ARCHIVE_FLAG; do
  if [ -d "$SOURCE_DIR" ]; then
    log_message "Processing directory: $SOURCE_DIR"

    # Если архивирование включено
    if [ "$ARCHIVE_FLAG" == "true" ]; then
      # Создаем архив
      ARCHIVE_NAME="$(basename "$SOURCE_DIR")-$(date +'%Y-%m-%d').tar"
      ARCHIVE_PATH="./tmp/$ARCHIVE_NAME"
      
      log_message "Archiving $SOURCE_DIR to $ARCHIVE_PATH..."
      tar -cf "$ARCHIVE_PATH" -C "$SOURCE_DIR" .
      
      if [ $? -eq 0 ]; then
        log_message "Archive created: $ARCHIVE_NAME"
        BACKUP_FILE="$ARCHIVE_PATH"
      else
        log_message "Failed to create archive for $SOURCE_DIR"
        continue
      fi
    else
      # Если архивирование не нужно, просто загружаем директорию
      BACKUP_FILE="$SOURCE_DIR"
    fi

    # Загружаем файлы в S3
    if [ -f "$BACKUP_FILE" ] || [ -d "$BACKUP_FILE" ]; then
      log_message "Checking if $BACKUP_FILE exists in Yandex Cloud S3..."

      # Проверка наличия файла/директории в S3
      s3cmd ls "$S3_BUCKET/$(basename "$BACKUP_FILE")" | grep "$(basename "$BACKUP_FILE")" > /dev/null 2>&1

      if [ $? -eq 0 ]; then
        log_message "Backup $(basename "$BACKUP_FILE") already exists in Yandex Cloud S3. Skipping upload."
      else
        log_message "Uploading $(basename "$BACKUP_FILE") to Yandex Cloud S3..."
        if [ -f "$BACKUP_FILE" ]; then
          s3cmd put "$BACKUP_FILE" "$S3_BUCKET/"
        else
          s3cmd put --recursive "$BACKUP_FILE" "$S3_BUCKET/"
        fi
        
        if [ $? -eq 0 ]; then
          log_message "Successfully uploaded: $(basename "$BACKUP_FILE")"
        else
          log_message "Failed to upload: $(basename "$BACKUP_FILE")"
        fi
      fi
    else
      log_message "No backup files found for $SOURCE_DIR"
    fi

    # Удаление временного архива, если он был создан
    if [ "$ARCHIVE_FLAG" == "true" ]; then
      rm -f "$ARCHIVE_PATH"
      log_message "Temporary archive $ARCHIVE_PATH removed."
    fi
  else
    log_message "Directory $SOURCE_DIR does not exist. Skipping."
  fi
done < "$CONFIG_FILE"

log_message "Backup process completed."
