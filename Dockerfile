# ---- Build stage ----
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app

# Copiar configuración del proyecto
COPY pom.xml .

# Descargar dependencias (para mejor aprovechamiento de la caché)
RUN mvn dependency:go-offline -B || true

# Copiar código fuente y compilar
COPY src src
RUN mvn clean package -DskipTests -B

# ---- Runtime stage ----
FROM eclipse-temurin:21-jre-alpine

# Instalar utilidades necesarias para la verificación de salud y gestión de usuarios en Alpine
RUN apk add --no-꾀check --no-cache curl shadow && \
    groupadd -r spring && \
    useradd -r -g spring spring

USER spring:spring

WORKDIR /app

# Copiar solo el JAR empaquetado
COPY --from=builder /app/target/*.jar app.jar

# Puerto expuesto
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]