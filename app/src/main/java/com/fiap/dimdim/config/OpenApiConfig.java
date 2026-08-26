package com.fiap.dimdim.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("DimDim Finanças API — FIAP Checkpoint 1 (2º Semestre)")
                        .version("1.0.0")
                        .description("API RESTful conteinerizada em nuvem (Azure Container Instances / Azure Container Registry) com PostgreSQL em PaaS.")
                        .contact(new Contact()
                                .name("Equipe DimDim - RM562795")
                                .email("rm562795@fiap.com.br")));
    }
}
