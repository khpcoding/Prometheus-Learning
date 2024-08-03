# ALERTMANAGER Installation 

export VERSION=0.26.0
wget https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/alertmanager-${VERSION}.linux-amd64.tar.gz
tar -xvf alertmanager-${VERSION}.linux-amd64.tar.gz
cp alertmanager-${VERSION}.linux-amd64/alertmanager /usr/local/bin/
cp alertmanager-${VERSION}.linux-amd64/amtool /usr/local/bin/
mkdir /etc/alertmanager
chown alertmanager:alertmanager  /etc/alertmanager
useradd --no-create-home --shell /bin/false alertmanager
chown alertmanager:alertmanager /usr/local/bin/alertmanager
chown alertmanager:alertmanager /usr/local/bin/amtool


echo -n " global:
  resolve_timeout: 1m
  slack_api_url: 'https://hooks.slack.com/services/XXXXXXXXXXXXXXXXX'
route:
  receiver: 'telegram'
  routes:
    - match:
        severity: critical
      receiver: 'slack-notifications'
receivers:
- name: 'telegram'
  webhook_configs:
  - send_resolved: true
    url: 'http://127.0.0.1:8080'
- name: 'slack-notifications'
  slack_configs:
  - send_resolved: true
    http_config: {}
    api_url: 'https://hooks.slack.com/services/XXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    channel: '#monitoring'
    username: '{{ template "slack.default.username" . }}'
    color: '{{ if eq .Status "firing" }}danger{{ else }}good{{ end }}'
    title: '{{ template "slack.default.title" . }}'
    title_link: '{{ template "slack.default.titlelink" . }}'
    pretext: '{{ template "slack.default.pretext" . }}'
    text: |-
      {{ range .Alerts }}
         *Alert:* {{ .Annotations.summary }} - `{{ .Labels.severity }}`
         *Message:* {{ .Annotations.message }}
      {{ end }}
    footer: '{{ template "slack.default.footer" . }}'
    fallback: '{{ template "slack.default.fallback" . }}'
    callback_id: '{{ template "slack.default.callbackid" . }}'
    icon_emoji: '{{ template "slack.default.iconemoji" . }}'
    icon_url: '{{ template "slack.default.iconurl" . }}' " > /etc/alertmanager/alertmanager.yml

echo -n "[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target
[Service]
User=alertmanager
Group=alertmanager
Type=simple
WorkingDirectory=/etc/alertmanager/
ExecStart=/usr/local/bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml --web.external-url http://0.0.0.0:9093
[Install]
WantedBy=multi-user.target " >  /etc/systemd/system/alertmanager.service
