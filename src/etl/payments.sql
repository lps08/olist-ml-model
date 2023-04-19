WITH tb_pedidos AS (

    SELECT 
        DISTINCT
        t1.idPedido,
        t2.idVendedor

    FROM pedido as t1

    LEFT JOIN item_pedido as t2
    ON t1.idPedido = t2.idPedido

    WHERE t1.dtPedido < '2018-01-01'
    AND t1.dtPedido >= julianday('2018-01-01', '-6 months')
    AND idVendedor IS NOT NULL

),

tb_join AS (

    SELECT t1.idVendedor,
           t2.*

    FROM tb_pedidos AS t1

    LEFT JOIN pagamento_pedido AS t2
    ON t1.idPedido = t2.idPedido
    
),

tb_group AS (

    SELECT idVendedor,
        descTipoPagamento,
        count(DISTINCT idPedido) AS qtdePedidoMeioPagamento,
        sum(vlPagamento) AS vlPedidoMeioPagamento

    FROM tb_join

    GROUP BY idVendedor, descTipoPagamento
    ORDER BY idVendedor, descTipoPagamento
)

SELECT idVendedor,

sum(case when descTipoPagamento = 'boleto'then qtdePedidoMeioPagamento else 0 end) as qtde_boleto_pedido,
sum(case when descTipoPagamento = 'credit_card'then qtdePedidoMeioPagamento else 0 end) as qtde_credit_card_pedido,
sum(case when descTipoPagamento = 'voucher'then qtdePedidoMeioPagamento else 0 end) as qtde_voucher_pedido,
sum(case when descTipoPagamento = 'debit_card'then qtdePedidoMeioPagamento else 0 end) as qtde_debit_card_pedido,

sum(case when descTipoPagamento = 'boleto'then vlPedidoMeioPagamento else 0 end) as valor_boleto_pedido,
sum(case when descTipoPagamento = 'credit_card'then vlPedidoMeioPagamento else 0 end) as valor_credit_card_pedido,
sum(case when descTipoPagamento = 'voucher'then vlPedidoMeioPagamento else 0 end) as valor_voucher_pedido,
sum(case when descTipoPagamento = 'debit_card'then vlPedidoMeioPagamento else 0 end) as valor_debit_card_pedido,

sum(case when descTipoPagamento = 'boleto' then qtdePedidoMeioPagamento else 0 end) / sum(qtdePedidoMeioPagamento) as pct_qtd_boleto_pedido,
sum(case when descTipoPagamento = 'credit_card' then qtdePedidoMeioPagamento else 0 end) / sum(qtdePedidoMeioPagamento) as pct_qtd_credit_card_pedido,
sum(case when descTipoPagamento = 'voucher' then qtdePedidoMeioPagamento else 0 end) / sum(qtdePedidoMeioPagamento) as pct_qtd_voucher_pedido,
sum(case when descTipoPagamento = 'debit_card' then qtdePedidoMeioPagamento else 0 end) / sum(qtdePedidoMeioPagamento) as pct_qtd_debit_card_pedido,

sum(case when descTipoPagamento = 'boleto'then vlPedidoMeioPagamento else 0 end) / sum(vlPedidoMeioPagamento) as pct_valor_boleto_pedido,
sum(case when descTipoPagamento = 'credit_card'then vlPedidoMeioPagamento else 0 end) / sum(vlPedidoMeioPagamento) as pct_valor_credit_card_pedido,
sum(case when descTipoPagamento = 'voucher'then vlPedidoMeioPagamento else 0 end) / sum(vlPedidoMeioPagamento) as pct_valor_voucher_pedido,
sum(case when descTipoPagamento = 'debit_card'then vlPedidoMeioPagamento else 0 end) / sum(vlPedidoMeioPagamento) as pct_valor_debit_card_pedido

FROM tb_group
GROUP BY idVendedor