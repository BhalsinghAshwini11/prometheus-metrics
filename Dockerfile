FROM openjdk:21

ADD build/libs/metrics-0.0.1-SNAPSHOT.jar /metrics-0.0.1-SNAPSHOT.jar

ENTRYPOINT java -jar /metrics-0.0.1-SNAPSHOT.jar