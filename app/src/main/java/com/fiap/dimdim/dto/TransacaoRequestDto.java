package com.fiap.dimdim.dto;

import com.fiap.dimdim.model.TipoTransacao;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransacaoRequestDto {

    @NotBlank(message = "A descrição é obrigatória")
    @Size(max = 150, message = "A descrição deve ter no máximo 150 caracteres")
    private String descricao;

    @NotNull(message = "O valor é obrigatório")
    @Positive(message = "O valor deve ser maior que zero")
    private BigDecimal valor;

    @NotNull(message = "O tipo da transação é obrigatório (ENTRADA ou SAIDA)")
    private TipoTransacao tipo;

    @NotBlank(message = "A categoria é obrigatória")
    @Size(max = 50, message = "A categoria deve ter no máximo 50 caracteres")
    private String categoria;
}
