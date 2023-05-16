WITH tb_join AS (

    SELECT DISTINCT
        t2.idVendedor,
        t3.*

    FROM pedido as t1

    LEFT JOIN item_pedido as t2
    ON t1.idPedido = t2.idPedido

    LEFT JOIN produto as t3
    ON t2.idProduto = t3.idProduto

    WHERE t1.dtPedido < '{date}'
    AND t1.dtPedido >= julianday('{date}', '-6 months')
    AND t2.idVendedor IS NOT NULL

),

tb_summary AS (

    SELECT idVendedor,
        --    coalesce is like fillna in sql
        AVG(coalesce(nrFotos, 0)) AS avgFotos,
        AVG(vlComprimentoCm * vlAlturaCm * vlLarguraCm) AS avgVolumeProduto,
        min(vlComprimentoCm * vlAlturaCm * vlLarguraCm) AS minVolumeProduto,
        max(vlComprimentoCm * vlAlturaCm * vlLarguraCm) AS maxVolumeProduto,

        CAST(count(distinct case when descCategoria = 'cama_mesa_banho' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriacama_mesa_banho,
        CAST(count(distinct case when descCategoria = 'beleza_saude' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriabeleza_saude,
        CAST(count(distinct case when descCategoria = 'esporte_lazer' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriaesporte_lazer,
        CAST(count(distinct case when descCategoria = 'informatica_acessorios' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriainformatica_acessorios,
        CAST(count(distinct case when descCategoria = 'moveis_decoracao' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriamoveis_decoracao,
        CAST(count(distinct case when descCategoria = 'utilidades_domesticas' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriautilidades_domesticas,
        CAST(count(distinct case when descCategoria = 'relogios_presentes' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriarelogios_presentes,
        CAST(count(distinct case when descCategoria = 'telefonia' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriatelefonia,
        CAST(count(distinct case when descCategoria = 'automotivo' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriaautomotivo,
        CAST(count(distinct case when descCategoria = 'brinquedos' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriabrinquedos,
        CAST(count(distinct case when descCategoria = 'cool_stuff' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriacool_stuff,
        CAST(count(distinct case when descCategoria = 'ferramentas_jardim' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriaferramentas_jardim,
        CAST(count(distinct case when descCategoria = 'perfumaria' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriaperfumaria,
        CAST(count(distinct case when descCategoria = 'bebes' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriabebes,
        CAST(count(distinct case when descCategoria = 'eletronicos' then idProduto end) as FLOAT) / CAST(count(distinct idProduto) as FLOAT) as pctCategoriaeletronicos


    FROM tb_join
    GROUP BY idVendedor

)

SELECT '{date}' as dtReference,
       datetime('now') as dtInjestion,
       *

FROM tb_summary

