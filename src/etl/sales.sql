WITH tb_pedido_item AS (

    SELECT t2.*,
           t1.dtPedido

    FROM pedido AS t1

    LEFT JOIN item_pedido as t2
    ON t1.idPedido = t2.idPedido

    WHERE t1.dtPedido < '{date}'
    AND t1.idPedido >= julianday('{date}', '-6 months')
    AND t2.idVendedor IS NOT NULL

),

tb_summary AS (

    SELECT idVendedor,
        count(DISTINCT idPedido) as qtdePedidos,
        count(DISTINCT date(dtPedido)) qtdeDias,
        count(idProduto) as qtItems,
        --    the min difference means that dtPedido it's the highest date
        min((strftime('%s', '{date}') - strftime('%s', dtPedido)) / 86400) as qtRecencia,
        sum(vlPreco) / count(DISTINCT idPedido) AS avgTicket,
        avg(vlPreco) AS avgValorProduto,
        max(vlPreco) AS maxValorProduto,
        min(vlPreco) AS minValorProduto,
        CAST(count(idProduto) as REAL) / CAST(count(DISTINCT idPedido) as REAL) AS avgProdutoPedido

    FROM tb_pedido_item

    GROUP BY idVendedor

),

tb_pedido_summary AS (

    SELECT idVendedor,
        idPedido,
        sum(vlPreco) as vlPreco

    FROM tb_pedido_item

    GROUP BY idVendedor, idPedido

),

tb_min_max AS (

    SELECT idVendedor,
        min(vlPreco) AS minVlPedido,
        max(vlPreco) AS maxVlPedido

    FROM tb_pedido_summary

    GROUP BY idVendedor

),

tb_life AS (

    SELECT t2.idVendedor,
        sum(vlPreco) AS LTV,
        max((strftime('%s', '{date}') - strftime('%s', dtPedido)) / 86400) AS qtdeDiasBase

    FROM pedido AS t1

    LEFT JOIN item_pedido as t2
    ON t1.idPedido = t2.idPedido

    WHERE t1.dtPedido < '{date}'
    AND t2.idVendedor IS NOT NULL

    GROUP BY t2.idVendedor

),

tb_tdPedido AS (

    SELECT DISTINCT
        idVendedor,
        date(dtPedido) as dtPedido

    FROM tb_pedido_item

    GROUP BY 1,2

),

tb_lag AS (

    SELECT *,
        LAG(dtPedido) OVER (PARTITION BY idVendedor ORDER BY dtPedido) as lag1

    FROM tb_tdPedido

),

tb_interval AS (

    SELECT idVendedor,
        AVG((strftime('%s', dtPedido) - strftime('%s', lag1)) / 86400) AS avgIntervaloVendas

    FROM tb_lag

    GROUP BY idVendedor

)

SELECT '{date}' AS dtReference,
       datetime('now') as dtInjestion,
       t1.*,
       t2.minVlPedido,
       t2.maxVlPedido,
       t3.LTV,
       t3.qtdeDiasBase,
       t4.avgIntervaloVendas


FROM tb_summary AS t1

LEFT JOIN tb_min_max AS t2
ON t1.idVendedor = t2.idVendedor

LEFT JOIN tb_life AS t3
ON t1.idVendedor = t3.idVendedor

LEFT JOIN tb_interval AS t4
ON t1.idVendedor = t4.idVendedor