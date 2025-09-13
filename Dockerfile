# Stage 1: Build
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app

# 1. Maven wrapper ve pom.xml kopyalanır (bağımlılık cache için)
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# 2. Bağımlılıklar indirilir (cache’lenir)
RUN ./mvnw dependency:go-offline -B

# 3. Kaynak kod kopyalanır
COPY src ./src

# 4. Package alınır (testler skip edilebilir)
RUN ./mvnw package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Sadece jar dosyası alınır
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
