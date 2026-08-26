# ===================================================================
# ESTÁGIO 1: Build da Aplicação com Maven e Java 21 (Eclipse Temurin)
# ===================================================================
FROM maven:3.9.8-eclipse-temurin-21-alpine AS builder
WORKDIR /build

# Cache de dependências do Maven
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Cópia do código-fonte e compilação do JAR executável
COPY src ./src
RUN mvn clean package -DskipTests

# ===================================================================
# ESTÁGIO 2: Imagem Final de Execução Minimalista e Segura (Non-Root)
# ===================================================================
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Segurança: Criar grupo e usuário NÃO-ROOT (Regra obrigatória do Checkpoint)
RUN addgroup -g 10001 -S appgroup && \
    adduser -u 10001 -S appuser -G appgroup

# Copiar o artefato compilado do estágio anterior e ajustar permissões
COPY --from=builder --chown=appuser:appgroup /build/target/dimdim-api-*.jar app.jar

# Trocar para o usuário NÃO-ROOT (Sem privilégios de root/admin)
USER appuser:appgroup

# Exposição da porta da aplicação
EXPOSE 8080

# Configuração de variáveis de JVM e inicialização
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
