package com.fiap.dimdim.controller;

import com.fiap.dimdim.dto.ResumoFinanceiroDto;
import com.fiap.dimdim.dto.TransacaoRequestDto;
import com.fiap.dimdim.dto.TransacaoResponseDto;
import com.fiap.dimdim.model.TipoTransacao;
import com.fiap.dimdim.service.TransacaoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transacoes")
@RequiredArgsConstructor
@Tag(name = "DimDim Transações", description = "Endpoints de CRUD para o sistema de gestão financeira DimDim")
public class TransacaoController {

    private final TransacaoService service;

    @GetMapping
    @Operation(summary = "Listar todas as transações", description = "Retorna a lista de transações com filtro opcional por tipo (ENTRADA ou SAIDA)")
    public ResponseEntity<List<TransacaoResponseDto>> findAll(@RequestParam(required = false) TipoTransacao tipo) {
        return ResponseEntity.ok(service.findAll(tipo));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Buscar transação por ID")
    public ResponseEntity<TransacaoResponseDto> findById(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }

    @PostMapping
    @Operation(summary = "Cadastrar nova transação")
    public ResponseEntity<TransacaoResponseDto> create(@Valid @RequestBody TransacaoRequestDto dto) {
        TransacaoResponseDto created = service.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Atualizar transação por ID")
    public ResponseEntity<TransacaoResponseDto> update(@PathVariable Long id, @Valid @RequestBody TransacaoRequestDto dto) {
        return ResponseEntity.ok(service.update(id, dto));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Excluir transação por ID")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/resumo")
    @Operation(summary = "Obter resumo financeiro (Saldo, Total Entradas, Total Saídas)")
    public ResponseEntity<ResumoFinanceiroDto> getResumo() {
        return ResponseEntity.ok(service.getResumo());
    }
}
