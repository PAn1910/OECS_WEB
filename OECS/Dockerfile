
# Build OECS WAR
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn -B clean package -DskipTests

# Tomcat 10.1
FROM tomcat:10.1-jdk17-temurin

# Install Tailscale and TCP forwarding utility
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl ca-certificates socat \
    && curl -fsSL https://tailscale.com/install.sh | sh \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build \
    /app/target/OECS-1.0-SNAPSHOT.war \
    /usr/local/tomcat/webapps/OECS.war

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 10000

CMD ["/usr/local/bin/start.sh"]
