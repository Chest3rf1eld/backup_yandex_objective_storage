#!/bin/bash

# Директория с архивами бэкапов
SOURCE_DIR="/backup"

# Перебираем все файлы с расширением .tar в директории
for BACKUP_FILE in $SOURCE_DIR/*.tar; do
  if [ -f "$BACKUP_FILE" ]; then
    # Получаем только имя файла (без пути)
    FILE_NAME=$(basename "$BACKUP_FILE")
    
    echo "Checking if $FILE_NAME exists in Yandex Cloud S3..."
    
    # Точная проверка наличия файла в S3
    s3cmd ls s3://backup-storage1/web-server/"$FILE_NAME" | grep "$FILE_NAME" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
      echo "Backup $FILE_NAME already exists in Yandex Cloud S3. Skipping upload."
    else
      echo "Uploading $FILE_NAME to Yandex Cloud S3..."
      s3cmd put "$BACKUP_FILE" s3://backup-storage1/web-server/
      
      if [ $? -eq 0 ]; then
        echo "Successfully uploaded: $FILE_NAME"
      else
        echo "Failed to upload: $FILE_NAME"
      fi
    fi
  else
    echo "No backup files found in $SOURCE_DIR"
  fi
done
