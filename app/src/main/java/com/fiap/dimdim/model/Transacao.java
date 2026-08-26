package com.fiap.dimdim.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "TB_DIMDIM_TRANSACOES")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Transacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "DESCRICAO", nullable = false, length = 150)
    private String descricao;

    @Column(name = "VALOR", nullable = false, precision = 12, scale = 2)
    private BigDecimal valor;

    @Enumerated(EnumType.STRING)
    @Column(name = "TIPO", nullable = false, length = 10)
    private TipoTransacao tipo;

    @Column(name = "CATEGORIA", nullable = false, length = 50)
    private String categoria;

    @Column(name = "DATA_TRANSACAO", nullable = false)
    private LocalDateTime dataTransacao;

    @PrePersist
    public void prePersist() {
        if (this.dataTransacao == null) {
            this.dataTransacao = LocalDateTime.now();
        }
    }
}
