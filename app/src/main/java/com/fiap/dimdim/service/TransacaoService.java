package com.fiap.dimdim.service;

import com.fiap.dimdim.dto.ResumoFinanceiroDto;
import com.fiap.dimdim.dto.TransacaoRequestDto;
import com.fiap.dimdim.dto.TransacaoResponseDto;
import com.fiap.dimdim.model.TipoTransacao;
import com.fiap.dimdim.model.Transacao;
import com.fiap.dimdim.repository.TransacaoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TransacaoService {

    private final TransacaoRepository repository;

    @Transactional(readOnly = true)
    public List<TransacaoResponseDto> findAll(TipoTransacao tipo) {
        List<Transacao> list = (tipo != null) ? repository.findByTipo(tipo) : repository.findAll();
        return list.stream().map(TransacaoResponseDto::fromEntity).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public TransacaoResponseDto findById(Long id) {
        Transacao entity = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Transação não encontrada com ID: " + id));
        return TransacaoResponseDto.fromEntity(entity);
    }

    @Transactional
    public TransacaoResponseDto create(TransacaoRequestDto dto) {
        Transacao entity = Transacao.builder()
                .descricao(dto.getDescricao())
                .valor(dto.getValor())
                .tipo(dto.getTipo())
                .categoria(dto.getCategoria())
                .build();

        Transacao saved = repository.save(entity);
        return TransacaoResponseDto.fromEntity(saved);
    }

    @Transactional
    public TransacaoResponseDto update(Long id, TransacaoRequestDto dto) {
        Transacao entity = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Transação não encontrada com ID: " + id));

        entity.setDescricao(dto.getDescricao());
        entity.setValor(dto.getValor());
        entity.setTipo(dto.getTipo());
        entity.setCategoria(dto.getCategoria());

        Transacao updated = repository.save(entity);
        return TransacaoResponseDto.fromEntity(updated);
    }

    @Transactional
    public void delete(Long id) {
        Transacao entity = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Transação não encontrada com ID: " + id));
        repository.delete(entity);
    }

    @Transactional(readOnly = true)
    public ResumoFinanceiroDto getResumo() {
        BigDecimal totalEntradas = repository.sumValorByTipo(TipoTransacao.ENTRADA);
        BigDecimal totalSaidas = repository.sumValorByTipo(TipoTransacao.SAIDA);
        if (totalEntradas == null) totalEntradas = BigDecimal.ZERO;
        if (totalSaidas == null) totalSaidas = BigDecimal.ZERO;

        BigDecimal saldo = totalEntradas.subtract(totalSaidas);
        long count = repository.count();

        return ResumoFinanceiroDto.builder()
                .totalEntradas(totalEntradas)
                .totalSaidas(totalSaidas)
                .saldoAtual(saldo)
                .quantidadeTransacoes(count)
                .build();
    }
}
