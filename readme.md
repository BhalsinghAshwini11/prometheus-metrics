# Getting Started
Please note this is gradle project and latest java and spring boot!!
There are many ways you can configure your app to expose metrics, see Excalidraw in the project linked. 

# Disclaimer
The POC is purely for learning/exploration purpose locally and can have bugs or misconfigurations for diff env or machines. Needed proper testing correct optimizations.

Few options have been explored as POC in this project
## Option 1, App(prometheus metrics)-> Prometheus server
Instrumenting our Java code for prometheus metrics only with Springboot micrometer library https://spring.io/blog/2022/10/12/observability-with-spring-boot-3
* Expose via lib spring micrometer prometheus (micrometer-registry-prometheus) automatically in prometheus format under actuator endpoint
* Set up prometheus server locally with scrape configurations towards app. see prometheus.yml
* That's it nothing in between, pure app to Prometheus server and then to Grafana to visualize Dashboards and more

## Option 2, App(OTLP metrics)-> Otel collector ->  Prometheus server
Instrumenting our Java code for prometheus metrics only with Springboot micrometer and OTEL library
* Expose via spring lib (micrometer-registry-otlp) in OTLP format towards collector exposed endpoint
* Set up Collector service locally with otel configurations, see otel-config.yml
* Set up prometheus server locally with scrape configurations from Otel collector, see prometheus.yml
* Twist here is, we are exporting now OTLP formatted metrics via collector to Prometheus server then to Grafana to visualize Dashboards
* Optional Step connect the backed to metrics to Visualization tool grafana, config in docker compose

## Option 3, App(Prometheus metrics) -> OtelCollector -> (LOGs or new APM?)
Instrumenting our Java code for prometheus metrics only with Springboot micrometer library (similar to option 1 but..)
* Expose via spring lib automatically in prometheus format under actuator endpoint
* Set up prometheus server locally with scape configurations from app
* Twist here is, that now I configure OTEL collector in between to receive (see below 2 ways to receive it) the prometheus formatted metrics, export it to OTLP format and then later can be sent to different metrics backend or APM tools. 
* But for demo purpose I am just logging that final resulted prom-OTLP formatted metrics.
* Complicated,but doable depends on use case what we want to achieve.
* Optional Step connect the backed to metrics to Visualization tool grafana, config in docker compose

### Option 3.1 using prometheus receiver 
* Developed and supported by OTEL, in early dev phase. Do recommend extensive testing and corner use case exploration. 
* No Prometheus server in between, actually Otel Collector will do scrape work and some more work on top of it.
* The Prometheus receiver is meant to minimally be a drop-in replacement for Prometheus. However, there are advanced features of Prometheus that this receive will don't support.(Please check latest https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/receiver/prometheusreceiver/README.m)
* Dynamic collector configuration needed to be tuned and learned yet,
* Optional Step connect the backed to metrics to Visualization tool grafana, config in docker compose

### Option 3.2 With prometheus_simple receiver
* The Simple Prometheus is a wrapper around the Prometheus receiver
* Benefit of using Simple Prometheus receiver is that it requires less configuration than the Prometheus receiver
* Just work as Proxy, that scraps metrics from prometheus server /9090/metrics port and export to OTLP format
* Have been used by SPLUNK or other infra services, as an option in between for metrics monitoring.  
* Optional Step connect the backed to metrics to Visualization tool grafana, config in docker compose

## How to run
We will use docker compose easy
* gradle assemble or bootJar from terminal (needed specific java config and gradle version) or do it via IDE
* docker-compose up --build (check all the services in container is ready)

## Optional, Generate noise
Do call some api end points towards respective apis.
### Test Example 
*  http://localhost:6543/ping 
* http://localhost:6543/random
* http://localhost:6543/health

## Prometheus local url
To play around for metrics, explore in service discovery & config tabs that correct jobs are configured 
* http://localhost:9090/

## Grafana local url
It will ask you to login use admin/admin, and on prompt use create new password
* http://localhost:3000/login

## Extra information for visualization configuration
* Add the respective data sources to Grafana.
* We can add prometheus metrics here
* Play around with PromQL and building some dashboards https://prometheus.io/docs/prometheus/latest/querying/basics/

### How to clean up
docker-compose down -v

### Troubleshooting
WINDOWS specific only! If 8080 or any needed port is taken or not cleaned properly, Find it first.
* netstat -ano | findstr :<PORT>

Replace <PORT> with 8080 then kill the process
* taskkill /PID 21260 /F