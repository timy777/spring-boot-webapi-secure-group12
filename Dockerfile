# Usa una imagen base ligera de Java 21
FROM eclipse-temurin:21-jre-alpine

# Establece el directorio de trabajo
WORKDIR /app

# Copia el archivo .jar generado por el paso previo de Maven en el pipeline
COPY target/*.jar app.jar

# Expone el puerto de Spring Boot
EXPOSE 8080

# Comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]