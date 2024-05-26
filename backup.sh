#!/bin/bash

# Load environment variables
DAILY_BACKUPS_RETAIN_COUNT=${DAILY_BACKUPS_RETAIN_COUNT:-7}
MONTHLY_BACKUPS_RETAIN_COUNT=${MONTHLY_BACKUPS_RETAIN_COUNT:-12}
YEARLY_BACKUPS_RETAIN_COUNT=${YEARLY_BACKUPS_RETAIN_COUNT:-3}

BACKUP_DIR=${BACKUP_DIR:-/backups}
TODAY=$(date +'%Y-%m-%d')
MONTH=$(date +'%Y-%m')
YEAR=$(date +'%Y')

# Create a backup
echo "Creating backup for ${TODAY}"
mkdir -p "$BACKUP_DIR"
pg_dump -U "$PGUSER" -h "$PGHOST" "$PGDB" --format=p | gzip > "${BACKUP_DIR}/backup-${TODAY}.sql.gz"


## check monthly backup exists
if [ ! -f "${BACKUP_DIR}/backup-${MONTH}-01.sql.gz" ]; then
  echo "Creating monthly backup for ${MONTH}"
  cp "${BACKUP_DIR}/backup-${TODAY}.sql.gz" "${BACKUP_DIR}/backup-${MONTH}.sql.gz"
fi

## check yearly backup exists
if [ ! -f "${BACKUP_DIR}/backup-${YEAR}-01-01.sql.gz" ]; then
  echo "Creating yearly backup for ${YEAR}"
  cp "${BACKUP_DIR}/backup-${TODAY}.sql.gz" "${BACKUP_DIR}/backup-${YEAR}.sql.gz"
fi

echo "Backup created successfully."
# Sleep for 10 seconds to ensure that the backup is completed
sleep 10

echo "Backup directory size:"

ls -lh "$BACKUP_DIR"


# Clean up old backups
echo "Cleaning up old backups..."

# Remove old daily backups
find "$BACKUP_DIR" -type f -regextype posix-extended -regex '.*backup-[0-9]{4}-[0-9]{2}-[0-9]{2}\.sql\.gz' -printf '%T@ %p\n' | sort -n | head -n -$DAILY_BACKUPS_RETAIN_COUNT | cut -d' ' -f2- | xargs rm;

# Remove old monthly backups but keep the ones created on the first day of each month
find "$BACKUP_DIR" -type f -regextype posix-extended -regex '.*backup-[0-9]{4}-[0-9]{2}\.sql\.gz' -printf '%T@ %p\n' | sort -n | head -n -$MONTHLY_BACKUPS_RETAIN_COUNT | cut -d' ' -f2- | xargs rm;

# Remove old yearly backups but keep the ones created on the first day of each year
find "$BACKUP_DIR" -type f -regextype posix-extended -regex '.*backup-[0-9]{4}\.sql\.gz' -printf '%T@ %p\n' | sort -n | head -n -$YEARLY_BACKUPS_RETAIN_COUNT | cut -d' ' -f2- | xargs rm;

echo "Old backups cleaned up successfully."

echo "Backup and cleanup process completed."

echo "sleeping for 5min"
sleep 300

echo "Backup process stopped."