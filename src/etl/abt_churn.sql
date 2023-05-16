WITH tb_activate AS (

    -- sale days
    SELECT idVendedor,
           min(date(dtPedido)) as dtAtivacao

    FROM pedido as t1

    LEFT JOIN item_pedido as t2
    ON t1.idPedido = t2.idPedido

    WHERE t1.dtPedido >= '{date}'
    AND t1.dtPedido <= date('{date}', '+45 days')
    AND idVendedor IS NOT NULL

    GROUP BY idVendedor

)

SELECT t1.*,
       t2.*,
       t3.*,
       t4.*,
       t5.*,
       t5.*,
       CASE WHEN t7.idVendedor IS NULL THEN 1 ELSE 0 END AS flChurn

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

LEFT JOIN tb_activate AS t7
ON t1.idVendedor = t7.idVendedor
AND julianday(t7.dtAtivacao) - julianday(t1.dtReference) <= 45 - t1.qtRecencia
WHERE t1.qtRecencia <= 45