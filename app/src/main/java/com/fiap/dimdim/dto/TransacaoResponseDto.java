package com.fiap.dimdim.dto;

import com.fiap.dimdim.model.TipoTransacao;
import com.fiap.dimdim.model.Transacao;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransacaoResponseDto {

    private Long id;
    private String descricao;
    private BigDecimal valor;
    private TipoTransacao tipo;
    private String categoria;
    private LocalDateTime dataTransacao;

    public static TransacaoResponseDto fromEntity(Transacao transacao) {
        return TransacaoResponseDto.builder()
                .id(transacao.getId())
                .descricao(transacao.getDescricao())
                .valor(transacao.getValor())
                .tipo(transacao.getTipo())
                .categoria(transacao.getCategoria())
                .dataTransacao(transacao.getDataTransacao())
                .build();
    }
}
