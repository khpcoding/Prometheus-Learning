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

   ```bash
   git clone https://github.com/YOUR_USERNAME/mysql-prometheus-monitoring.git
   cd mysql-prometheus-monitoring
