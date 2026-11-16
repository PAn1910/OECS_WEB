
# Build WAR using Maven and Java 17
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn -B clean package -DskipTests

# Run the WAR on Tomcat 10.1
FROM tomcat:10.1-jdk17-temurin

COPY --from=build /app/target/OECS-1.0-SNAPSHOT.war \
    /usr/local/tomcat/webapps/OECS.war

EXPOSE 10000

# Use the port assigned by Render
CMD sh -c 'sed -i "s/port=\"8080\"/port=\"${PORT:-10000}\"/" "$CATALINA_HOME/conf/server.xml" && exec catalina.sh run'
