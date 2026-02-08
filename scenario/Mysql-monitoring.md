# MySQL Monitoring with Prometheus & mysqld_exporter

[![Prometheus](https://img.shields.io/badge/Prometheus-2.5+-brightgreen)](https://prometheus.io/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue)](https://www.mysql.com/)

This repository demonstrates a **complete, production-ready example** of monitoring a MySQL database using:

- **Prometheus** — time-series database & monitoring system
- **mysqld_exporter** — official Prometheus exporter for MySQL server metrics
- **Docker Compose** — for easy local setup and testing
- **Grafana** (optional but included) — for beautiful dashboards and alerting

The setup exposes hundreds of useful MySQL metrics such as:

- Query performance & slow queries
- Connections, threads, buffer pool usage
- InnoDB I/O, locks, transactions
- Replication status (when applicable)
- Command counters, table locks, temporary tables, etc.

## Features

- Ready-to-run Docker Compose stack (MySQL + mysqld_exporter + Prometheus + Grafana)
- Secure credential handling using environment variables / `.env` file
- Minimal MySQL user privileges for exporter
- Example Prometheus scrape configuration
- Pre-configured Grafana data source & example dashboard import
- Multi-target exporter support notes (advanced)

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- Git

## Quick Start (Local Development / Testing)

1. Clone the repository

2. ```bash
   cp .env.example .env
   ```

   Edit .env and set secure passwords:env

```bash

MYSQL_ROOT_PASSWORD=your_root_password_here
MYSQL_DATABASE=monitoring_demo
MYSQL_USER=app_user
MYSQL_PASSWORD=app_user_password

# Exporter user (minimal privileges)
MYSQL_EXPORTER_USER=exporter
MYSQL_EXPORTER_PASSWORD=very_secure_exporter_pass_2026
```

3. Start the stack

```bash
docker compose up -d
```

Check that everything is running:
MySQL: http://localhost:3306 (use client tool)
mysqld_exporter metrics: http://localhost:9104/metrics
Prometheus: http://localhost:9090
Grafana: http://localhost:3000 (admin/admin → change password)

In Grafana:
Add Prometheus data source → http://prometheus:9090
Import dashboard (ID 14262 or use the one in ./grafana/dashboards/)
   

