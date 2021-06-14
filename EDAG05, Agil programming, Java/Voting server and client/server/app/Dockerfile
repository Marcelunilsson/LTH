FROM openjdk:15

EXPOSE 4242

COPY build/libs/shadow-all.jar server.jar

ENTRYPOINT ["java", "-jar", "server.jar"]