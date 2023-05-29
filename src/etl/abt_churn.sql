DROP TABLE IF EXISTS abt_olist_churn;
CREATE TABLE abt_olist_churn AS

WITH tb_features AS (

    SELECT  t1.dtReference,
            t1.idVendedor,
            t1.qtdePedidos,
            t1.qtdeDias,
            t1.qtItems,
            t1.qtRecencia,
            t1.avgTicket,
            t1.avgValorProduto,
            t1.maxValorProduto,
            t1.minValorProduto,
            t1.avgProdutoPedido,
            t1.minVlPedido,
            t1.maxVlPedido,
            t1.LTV,

            t1.qtdeDiasBase,
            t1.avgIntervaloVendas,
            t2.avgNota,
            t2.minNota,
            t2.maxNota,

            t2.pctAvaliacao,
            t3.qtdUFsPedidos,
            t3.pctPedidoAC,
            t3.pctPedidoAL,
            t3.pctPedidoAM,
            t3.pctPedidoAP,
            t3.pctPedidoBA,
            t3.pctPedidoCE,
            t3.pctPedidoDF,
            t3.pctPedidoES,
            t3.pctPedidoGO,
            t3.pctPedidoMA,
            t3.pctPedidoMG,
            t3.pctPedidoMS,
            t3.pctPedidoMT,
            t3.pctPedidoPA,
            t3.pctPedidoPB,
            t3.pctPedidoPE,
            t3.pctPedidoPI,
            t3.pctPedidoPR,
            t3.pctPedidoRJ,
            t3.pctPedidoRN,
            t3.pctPedidoRO,
            t3.pctPedidoRR,
            t3.pctPedidoRS,
            t3.pctPedidoSC,
            t3.pctPedidoSE,
            t3.pctPedidoSP,
            t3.pctPedidoTO,

            t4.pctPedidoAtraso,
            t4.pctPedidoCancelado,
            t4.avgFrete,
            t4.maxFrete,
            t4.minFrete,
            t4.qtdeDiasAprovadoEntrega,
            t4.qtdeDiasPedidoEntrega,
            t4.qtdeDiasEntregaPromessa,

            t5.qtde_boleto_pedido,
            t5.qtde_credit_card_pedido,
            t5.qtde_voucher_pedido,
            t5.qtde_debit_card_pedido,
            t5.valor_boleto_pedido,
            t5.valor_credit_card_pedido,
            t5.valor_voucher_pedido,
            t5.valor_debit_card_pedido,
            t5.pct_qtd_boleto_pedido,
            t5.pct_qtd_credit_card_pedido,
            t5.pct_qtd_voucher_pedido,
            t5.pct_qtd_debit_card_pedido,
            t5.pct_valor_boleto_pedido,
            t5.pct_valor_credit_card_pedido,
            t5.pct_valor_voucher_pedido,
            t5.pct_valor_debit_card_pedido,
            t5.avgQtdeParcelas,
            t5.maxQtdeParcelas,
            t5.minQtdeParcelas,
            t6.avgFotos,
            t6.avgVolumeProduto,
            t6.minVolumeProduto,
            t6.maxVolumeProduto,
            t6.pctCategoriacama_mesa_banho,
            t6.pctCategoriabeleza_saude,
            t6.pctCategoriaesporte_lazer,
            t6.pctCategoriainformatica_acessorios,
            t6.pctCategoriamoveis_decoracao,
            t6.pctCategoriautilidades_domesticas,
            t6.pctCategoriarelogios_presentes,
            t6.pctCategoriatelefonia,
            t6.pctCategoriaautomotivo,
            t6.pctCategoriabrinquedos,
            t6.pctCategoriacool_stuff,
            t6.pctCategoriaferramentas_jardim,
            t6.pctCategoriaperfumaria,
            t6.pctCategoriabebes,
            t6.pctCategoriaeletronicos

    FROM fs_vendedor_vendas AS t1

    LEFT JOIN fs_vendedor_avaliacao AS t2
    ON t1.idVendedor = t2.idVendedor
    AND t1.dtReference = t2.dtReference

    LEFT JOIN fs_vendedor_cliente AS t3
    ON t1.idVendedor = t3.idVendedor
    AND t1.dtReference = t3.dtReference

    LEFT JOIN fs_vendedor_entrega AS t4
    ON t1.idVendedor = t4.idVendedor
    AND t1.dtReference = t4.dtReference

    LEFT JOIN fs_vendedor_pagamentos AS t5
    ON t1.idVendedor = t5.idVendedor
    AND t1.dtReference = t5.dtReference

    LEFT JOIN fs_vendedor_produto AS t6
    ON t1.idVendedor = t6.idVendedor
    AND t1.dtReference = t6.dtReference

    WHERE t1.qtRecencia <= 45

),

tb_event AS (

    SELECT DISTINCT idVendedor,
    DATE(dtPedido) as dtPedido

    FROM item_pedido as t1
    LEFT JOIN pedido as t2
    ON t1.idPedido = t2.idPedido

    WHERE idVendedor IS NOT NULL

),

tb_flag AS (

    SELECT t1.dtReference,
           t1.IdVendedor,
           min(t2.dtPedido) AS dtProxPedido

    from tb_features AS t1
    LEFT JOIN tb_event AS t2
    ON t1.idVendedor = t2.idVendedor
    AND t1.dtReference <= t2.dtPedido
    AND julianday(dtPedido) - julianday(dtReference) <= 45 - qtRecencia

    GROUP BY t1.dtReference, t1.IdVendedor

)

SELECT t1.*,
       CASE WHEN dtProxPedido IS NULL THEN 1 ELSE 0 END AS flChurn

FROM tb_features AS t1

LEFT JOIN tb_flag AS t2
ON t1.idVendedor = t2.idVendedor
AND t1.dtReference = t2.dtReference

ORDER BY idVendedor, dtReference