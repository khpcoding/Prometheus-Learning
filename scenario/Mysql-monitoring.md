## Installation & Usage Guide – MySQL Exporter (mysqld_exporter)

```markdown
### Important Notes (2026)
- Latest version: **prom/mysqld-exporter:v0.18.0** (released Sep 2025)
- The old `DATA_SOURCE_NAME` environment variable is **no longer supported** → it is silently ignored.
- Use either:
  - `--mysqld.address=...` + `--mysqld.username=...` (easiest for docker-compose)
  - Or a mounted `.my.cnf` file with `--config.my-cnf=...`
- This guide uses the **flag method** (no extra files needed).

### 1. Recommended docker-compose.yml (minimal & secure)

```yaml
version: "3.9"

services:
  mysql:
    image: mysql:8.4
    container_name: mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ""                    # empty = no root password
      MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
      # MYSQL_DATABASE: monitoring               # optional
    volumes:
      - mysql-data:/var/lib/mysql
    # Important: Do NOT publish port 3306 → prevents "address already in use"
    # ports:
    #   - "3306:3306"

  mysqld-exporter:
    image: prom/mysqld-exporter:v0.18.0
    container_name: mysqld-exporter
    restart: unless-stopped
    ports:
      - "9104:9104"                              # Prometheus scrapes here
    command:
      - --mysqld.address=mysql:3306              # container name:port
      - --mysqld.username=root                   # or your dedicated user
      # If password exists → use: --mysqld.password=yourpass  (or env var)
      # Collectors (enable only what you need – reduces overhead)
      - --collect.global_status
      - --collect.global_variables
      - --collect.info_schema.processlist
      - --collect.info_schema.tables
      - --collect.engine_innodb_status           # useful for InnoDB
      # - --collect.perf_schema.eventswaits     # more detailed (higher overhead)
      # - --no-collect.slow_queries              # disable if not using slow log
    depends_on:
      - mysql
    # Optional: healthcheck
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "localhost:9104/metrics"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  mysql-data:
```

### 2. Quick Start Commands

```bash
# 1. (Optional) Create .env file for passwords (better security)
# .env
MYSQL_ROOT_PASSWORD=super_secure_root_pass_2026
MYSQL_EXPORTER_USER=exporter
MYSQL_EXPORTER_PASSWORD=exporter_secure_2026!

# 2. Start everything
docker compose up -d

# 3. Check status
docker compose ps
docker logs mysqld-exporter --tail 50

# 4. Verify metrics endpoint works
curl -s http://localhost:9104/metrics | head -n 30
# You should see: mysql_up 1, mysql_global_status_*, etc.

# 5. Stop & clean up (if needed)
docker compose down -v
```

### 3. Creating a Minimal Privileged Exporter User (Recommended in Production)

Run this once MySQL is running:

```sql
-- Connect to MySQL (docker exec or mysql client)
CREATE USER 'exporter'@'%' IDENTIFIED BY 'exporter_secure_2026!';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
FLUSH PRIVILEGES;
```

Then update the exporter command:

```yaml
    command:
      - --mysqld.address=mysql:3306
      - --mysqld.username=exporter
      # Two options for password:
      # Option A: plain text (simple, but visible in docker inspect)
      - --mysqld.password=exporter_secure_2026!
      # Option B: use environment variable (cleaner)
      # environment:
      #   MYSQLD_EXPORTER_PASSWORD: ${MYSQL_EXPORTER_PASSWORD}
      # command: ... --mysqld.password=${MYSQLD_EXPORTER_PASSWORD} ...
```

### 4. Common Errors & Fixes

| Error / Symptom                              | Cause                                      | Fix |
|----------------------------------------------|--------------------------------------------|-----|
| `no user specified in section or parent`     | Missing user in config / using old DSN     | Use `--mysqld.username=root` or dedicated user |
| `Error parsing host config ... no configuration found` | `--config.my-cnf` flag but file missing   | Remove `--config.my-cnf` flag or mount valid file |
| `failed to bind ... address already in use`  | Port 3306 already used on host             | **Remove** `ports: - "3306:3306"` from mysql service |
| `mysql_up 0` in metrics                      | Connection refused / wrong credentials     | Check logs, verify user/pass/address |
| No metrics / empty page                      | Exporter crashed or wrong collectors       | `docker logs mysqld-exporter` → add missing collectors |

### 5. Next Steps – Integrate with Prometheus & Grafana

Add this scrape config to your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: mysql
    static_configs:
      - targets: ['mysqld-exporter:9104']
```

Recommended Grafana dashboards (import via ID):
- **14262** – MySQL Overview (very complete)
- **7362**  – Percona MySQL Server
- **14004** – MySQL InnoDB Details

Login to Grafana → http://localhost:3000 (default: admin/admin)  
→ Connections → Add new data source → Prometheus → URL: `http://prometheus:9090`

### 6. Advanced Tips

- Want to monitor **multiple** MySQL instances?  
  → Run multiple exporter containers with different `--mysqld.address` + different ports (9104, 9105, …)  
  or use the newer **multi-target** mode (see exporter docs).

- Want lower CPU/memory?  
  → Disable heavy collectors: `--no-collect.perf_schema.*` `--no-collect.info_schema.innodb_metrics`

- Security: Never expose 9104 publicly → use `127.0.0.1:9104:9104` or internal network only.
