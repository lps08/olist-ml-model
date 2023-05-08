WITH dt_pedido AS (

    SELECT t1.idPedido,
        t1.descSituacao,
        t2.idVendedor,
        t1.dtPedido,
        t1.dtAprovado,
        t1.dtEntregue,
        t1.dtEstimativaEntrega,
        sum(vlFrete) as totalFrete

    FROM pedido as t1

    LEFT JOIN item_pedido as t2
    ON t1.idPedido = t2.idPedido

    WHERE dtPedido < '2018-01-01'
    AND dtPedido > julianday('2018-01-01', '-6 months')
    AND idVendedor IS NOT NULL

    GROUP BY t1.idPedido,
            t1.descSituacao,
            t2.idVendedor,
            t1.dtPedido,
            t1.dtAprovado,
            t1.dtEntregue,
            t1.dtEstimativaEntrega

)

SELECT '2018-01-01' as dtReference,
       idVendedor,
       CAST(count(DISTINCT CASE WHEN date(coalesce(dtEntregue, '2018-01-01')) > date(dtEstimativaEntrega) THEN idPedido END) AS REAL) / CAST(count(DISTINCT CASE WHEN descSituacao = 'delivered' THEN idPedido END) AS REAL) AS pctPedidoAtraso,
       CAST(count(DISTINCT CASE WHEN descSituacao = 'canceled' THEN idPedido END) AS REAL) / CAST(count(DISTINCT idPedido) AS REAL) as pctPedidoCancelado,
       AVG(totalFrete) as avgFrete,
       min(totalFrete) as minFrete,
       max(totalFrete) as maxFrete,
       avg((strftime('%s', coalesce(dtEntregue, '2018-01-01')) - strftime('%s', dtAprovado)) / 86400) AS qtdeDiasAprovadoEntrega,
       avg((strftime('%s', coalesce(dtEntregue, '2018-01-01')) - strftime('%s', dtPedido)) / 86400) AS qtdeDiasPedidoEntrega,
       avg((strftime('%s', dtEstimativaEntrega) - strftime('%s', coalesce(dtEntregue, '2018-01-01'))) / 86400) AS qtdeDiasEntregaPromessa

FROM dt_pedido

GROUP BY idVendedor