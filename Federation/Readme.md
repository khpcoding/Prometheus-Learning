# Prometheus Federation Guide

## 📖 Table of Contents
- [Overview](#overview)
- [What is Federation in Prometheus?](#what-is-federation-in-prometheus)
- [Why Use Federation?](#why-use-federation)
- [Federation Example](#federation-example)
  - [Setup](#setup)
  - [Federation Configuration](#federation-configuration)
- [Use Cases](#use-cases)
- [Further Reading](#further-reading)

---

## 🧾 Overview

Prometheus is a powerful monitoring and alerting toolkit. As your infrastructure grows, so do your metrics. This can lead to challenges in managing, storing, and querying metrics across many Prometheus instances. This is where **federation** comes into play.

---

## 🌐 What is Federation in Prometheus?

**Federation** is a technique in Prometheus that allows one Prometheus server (called the *federation server*) to scrape selected metrics from another Prometheus server (called a *source server*).

It works just like regular scraping: Prometheus pulls metrics from `/federate` endpoint of another Prometheus server.

Federation is useful when you want to:

- Aggregate metrics from multiple Prometheus servers.
- Reduce storage usage on central servers.
- Divide responsibilities between different teams or regions.

---

## ❓ Why Use Federation?

Here are some key reasons for using federation:

- **Scalability**: Helps divide the load between multiple Prometheus instances.
- **Isolation**: Different teams or regions can maintain their own Prometheus instances.
- **Data Aggregation**: Central Prometheus can scrape summarized or high-level metrics from multiple source Prometheus instances.
- **Reduced Retention Requirements**: Local Prometheus servers can keep short retention, and the federated server can keep long-term data.

---

## 🧪 Federation Example

### 🔧 Setup

Imagine the following setup:

- **prometheus-source**: Scrapes metrics from node exporters, app metrics, etc.
- **prometheus-federation**: Scrapes specific metrics from prometheus-source.

### 📄 Federation Configuration

Here is a sample federation config on the *federation* Prometheus server:

```yaml
# prometheus-federation.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'federate'
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
        - '{__name__=~"node_cpu_seconds_total|node_memory_MemAvailable_bytes"}'
        - 'up'
    static_configs:
      - targets:
          - 'prometheus-source:9090'
