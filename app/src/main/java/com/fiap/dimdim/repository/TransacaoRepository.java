package com.fiap.dimdim.repository;

import com.fiap.dimdim.model.TipoTransacao;
import com.fiap.dimdim.model.Transacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface TransacaoRepository extends JpaRepository<Transacao, Long> {

    List<Transacao> findByTipo(TipoTransacao tipo);

    List<Transacao> findByCategoriaIgnoreCase(String categoria);

    @Query("SELECT COALESCE(SUM(t.valor), 0) FROM Transacao t WHERE t.tipo = :tipo")
    BigDecimal sumValorByTipo(TipoTransacao tipo);
}
