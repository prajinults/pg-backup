# Use the Bitnami PostgreSQL image as the base image
FROM bitnami/postgresql:16.1.0-debian-11-r17

USER root
# Install necessary tools
RUN apt-get update && apt-get install -y gzip

# Set the environment variables for backup retention
ENV DAILY_BACKUPS_RETAIN_COUNT=3
ENV MONTHLY_BACKUPS_RETAIN_COUNT=3
ENV YEARLY_BACKUPS_RETAIN_COUNT=3
ENV PGUSER=postgres
ENV PGHOST=postgres
ENV PGPORT=5432
ENV PGDB=postgres
ENV PGPASSWORD=postgres
ENV BACKUP_DIR=/backups

# Create directories for backups and scripts
RUN mkdir -p /backups /scripts

# Copy the backup script into the container
COPY backup.sh /scripts/backup.sh

# Make the backup script executable
RUN chmod +x /scripts/backup.sh

# Set the entrypoint to the backup script
ENTRYPOINT ["/scripts/backup.sh"]
