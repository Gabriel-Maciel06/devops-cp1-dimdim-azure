package com.fiap.dimdim.dto;

import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ResumoFinanceiroDto {

    private BigDecimal totalEntradas;
    private BigDecimal totalSaidas;
    private BigDecimal saldoAtual;
    private long quantidadeTransacoes;
}
