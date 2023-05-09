DROP TABLE IF EXISTS fs_vendedor_cliente;
CREATE TABLE fs_vendedor_cliente AS

WITH tb_join AS (

    SELECT DISTINCT
        t1.idPedido,
        t1.idCliente,
        t2.idVendedor,
        t3.descUF

    FROM pedido AS t1

    LEFT JOIN item_pedido AS t2
    ON t1.idPedido = t2.idPedido

    LEFT JOIN cliente as t3
    ON t1.idCliente = t3.idCliente

    WHERE dtPedido < '2018-01-01'
    AND dtPedido >= julianday('2018-01-01', '-6 months')
    AND idVendedor IS NOT NULL

),

tb_group AS (
    SELECT 

    idVendedor,
    count(distinct descUF) as qtdUFsPedidos,

    cast(count(distinct case when descUF = 'AC' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoAC,
    cast(count(distinct case when descUF = 'AL' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoAL,
    cast(count(distinct case when descUF = 'AM' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoAM,
    cast(count(distinct case when descUF = 'AP' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoAP,
    cast(count(distinct case when descUF = 'BA' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoBA,
    cast(count(distinct case when descUF = 'CE' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoCE,
    cast(count(distinct case when descUF = 'DF' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoDF,
    cast(count(distinct case when descUF = 'ES' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoES,
    cast(count(distinct case when descUF = 'GO' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoGO,
    cast(count(distinct case when descUF = 'MA' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoMA,
    cast(count(distinct case when descUF = 'MG' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoMG,
    cast(count(distinct case when descUF = 'MS' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoMS,
    cast(count(distinct case when descUF = 'MT' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoMT,
    cast(count(distinct case when descUF = 'PA' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoPA,
    cast(count(distinct case when descUF = 'PB' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoPB,
    cast(count(distinct case when descUF = 'PE' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoPE,
    cast(count(distinct case when descUF = 'PI' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoPI,
    cast(count(distinct case when descUF = 'PR' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoPR,
    cast(count(distinct case when descUF = 'RJ' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoRJ,
    cast(count(distinct case when descUF = 'RN' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoRN,
    cast(count(distinct case when descUF = 'RO' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoRO,
    cast(count(distinct case when descUF = 'RR' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoRR,
    cast(count(distinct case when descUF = 'RS' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoRS,
    cast(count(distinct case when descUF = 'SC' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoSC,
    cast(count(distinct case when descUF = 'SE' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoSE,
    cast(count(distinct case when descUF = 'SP' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoSP,
    cast(count(distinct case when descUF = 'TO' then idPedido end) AS real) / cast(count(distinct idPedido) as real) as pctPedidoTO

    FROM tb_join

    GROUP BY idVendedor
)

SELECT 
    '2018-01-01' AS dtReference,
    * 

FROM tb_group