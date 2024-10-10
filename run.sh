#!/bin/bash

# Директория с архивами бэкапов
SOURCE_DIR="/backup"

# Файл для логов
LOG_FILE="/var/log/backup_yandex.log"

# Функция для записи в лог
log_message() {
  local MESSAGE="$1"
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $MESSAGE" >> $LOG_FILE
}

log_message "Backup process started."

# Перебираем все файлы с расширением .tar в директории
for BACKUP_FILE in $SOURCE_DIR/*.tar; do
  if [ -f "$BACKUP_FILE" ]; then
    # Получаем только имя файла (без пути)
    FILE_NAME=$(basename "$BACKUP_FILE")
    
    log_message "Checking if $FILE_NAME exists in Yandex Cloud S3..."
    
    # Точная проверка наличия файла в S3
    s3cmd ls s3://backup-storage1/web-server/"$FILE_NAME" | grep "$FILE_NAME" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
      log_message "Backup $FILE_NAME already exists in Yandex Cloud S3. Skipping upload."
    else
      log_message "Uploading $FILE_NAME to Yandex Cloud S3..."
      s3cmd put "$BACKUP_FILE" s3://backup-storage1/web-server/
      
      if [ $? -eq 0 ]; then
        log_message "Successfully uploaded: $FILE_NAME"
      else
        log_message "Failed to upload: $FILE_NAME"
      fi
    fi
  else
    log_message "No backup files found in $SOURCE_DIR"
  fi
done

log_message "Backup process completed."
