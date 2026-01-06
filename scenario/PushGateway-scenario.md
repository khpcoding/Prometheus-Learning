# Prometheus Push Gateway Scenario: Monitoring MySQL Database Backup Status

## Introduction

This scenario shows how to use the Prometheus Push Gateway to monitor the success or failure of periodic MySQL database backups.

A bash script will run every minute (via cron), attempt to back up a MySQL database named `backup_demo`, and push a simple metric called `backup_status` to the Push Gateway:
- Value `1` → backup succeeded
- Value `0` → backup failed

Prometheus can then scrape the Push Gateway and allow you to query, graph, and alert on the backup status.


## Step 1: Install MySQL Server on Ubuntu 24.04

1. Update package lists:
   ```bash
   sudo apt update
   ```

2. Install MySQL server and client:
   ```bash
   sudo apt install mysql-server mysql-client -y
   ```

3. Start and enable MySQL service:
   ```bash
   sudo systemctl start mysql
   sudo systemctl enable mysql
   ```

4. Verify MySQL is running:
   ```bash
   sudo systemctl status mysql
   ```

5. Log in to MySQL as root (in a fresh Ubuntu 24.04 installation, the root user typically uses the `auth_socket` plugin, so use sudo):
   ```bash
   sudo mysql
   ```

   If you have set a password for the root user, use:
   ```bash
   mysql -u root -p
   ```

## Step 2: Create a Sample Database and Tables

Run the following commands inside the MySQL shell:

```sql
CREATE DATABASE backup_demo;
USE backup_demo;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Insert sample data
INSERT INTO users (username, email) VALUES ('john_doe', 'john@example.com');
INSERT INTO users (username, email) VALUES ('jane_smith', 'jane@example.com');

INSERT INTO orders (user_id, product, amount) VALUES (1, 'Laptop', 999.99);
INSERT INTO orders (user_id, product, amount) VALUES (2, 'Phone', 499.99);

-- Verify data
SELECT * FROM users;
SELECT * FROM orders;

EXIT;
```

## Step 3: Create the Backup Script

Create the script file:

```bash
vim backup_mysql.sh
```

Paste the **complete** script below:

```bash
#!/bin/bash
DB_NAME="backup_demo"
BACKUP_DIR="/opt/pushgw/bk"
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}-$(date +%Y%m%d-%H%M%S).sql"
MYSQL_USER="root"
MYSQL_PASS="push@123"                  # Correct password

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Attempt backup and determine status
if mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASS" --single-transaction --quick "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null; then
    STATUS=1
    echo "Backup successful (status: 1)"
else
    STATUS=0
    echo "Backup failed (status: 0)"
fi

# Push metric to Pushgateway
PUSH_GATEWAY_URL="http://127.0.0.1:9091"
METRIC_NAME="backup_status"
JOB_NAME="mysql_backup"
INSTANCE="prometheus-server"           

cat <<EOF | curl --data-binary @- "$PUSH_GATEWAY_URL/metrics/job/$JOB_NAME/instance/$INSTANCE"
# TYPE $METRIC_NAME gauge
# HELP $METRIC_NAME Status of the last MySQL backup attempt (1 = success, 0 = failure)
$METRIC_NAME $STATUS
EOF

echo "Metric pushed: $METRIC_NAME = $STATUS"
```

Make the script executable:

```bash
chmod +x backup_mysql.sh
```

**Important notes:**
- Replace `/path/to/backup/folder` with an actual writable directory (e.g., `/home/youruser/mysql_backups`).
- In production, avoid hardcoding passwords. Use a `.my.cnf` file with restricted permissions or a dedicated MySQL backup user.
- The `2>/dev/null` suppresses mysqldump error output to keep the script clean.

Test the script manually:

```bash
./backup_mysql.sh
```

A new `.sql` backup file should appear in your backup directory if successful.

## Step 4: Schedule the Script to Run Every Minute

Edit your crontab:

```bash
crontab -e
```

Add the following line (replace with the full path to your script):

```cron
* * * * * /opt/pushgw/backup_mysql.sh
```


## Step 5: Run the Prometheus Push Gateway

Start the Push Gateway using Docker Compose:

```bash
services:
  pushgateway:
    image: prom/pushgateway:latest
    container_name: pushgateway
    restart: unless-stopped
    ports:
      - "9091:9091"
    volumes:
      - pushgateway-data:/pushgateway
    command:
      - '--persistence.file=/pushgateway/pushgateway.data'
      - '--persistence.interval=5m'
      - '--log.level=info'
    networks:
      - monitoring

volumes:
  pushgateway-data:

networks:
  monitoring:
    name: monitoring
```

Verify it is accessible at:

`http://localhost:9091`

After running the backup script a few times, you should see the `backup_status` metric listed.

## Step 6: Verify Metrics in Prometheus

1. Run the backup script several times manually or wait for the cron job.
2. Open your Prometheus UI (typically `http://your-server:9090`).
3. Go to the **Graph** tab and execute the query:

   ```
   backup_status{job="mysql_backup"}
   ```

   - Value `1` indicates the last backup succeeded.
   - Value `0` indicates the last backup failed.

You can now build graphs, dashboards, or alerting rules based on this metric (e.g., alert when `backup_status == 0`).


