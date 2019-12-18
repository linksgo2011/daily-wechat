FROM openjdk:8-jdk-slim
COPY build/libs/daily-wechat-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT java -Duser.timezone=Asia/Shanghai \


