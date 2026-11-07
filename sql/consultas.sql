-- Variação entre o primeiro e o último ano disponíveis de cada país.
WITH limites AS (
    SELECT pais, MIN(ano) AS ano_inicial, MAX(ano) AS ano_final
    FROM precos
    GROUP BY pais
)
SELECT
    fim.pais,
    l.ano_inicial,
    inicio.preco AS preco_inicial,
    fim.preco AS preco_final,
    ROUND((fim.preco / inicio.preco - 1) * 100, 1) AS variacao_pct,
    ROUND((POWER(fim.preco / inicio.preco, 1.0 / (l.ano_final - l.ano_inicial)) - 1) * 100, 2) AS cagr_pct
FROM limites AS l
JOIN precos AS inicio ON inicio.pais = l.pais AND inicio.ano = l.ano_inicial
JOIN precos AS fim ON fim.pais = l.pais AND fim.ano = l.ano_final
ORDER BY variacao_pct DESC;

-- Variação média anual entre os países, com LAG.
WITH variacoes AS (
    SELECT
        ano,
        pais,
        (preco / LAG(preco) OVER (PARTITION BY pais ORDER BY ano) - 1) * 100 AS variacao_pct
    FROM precos
)
SELECT ano, ROUND(AVG(variacao_pct), 1) AS variacao_media_pct
FROM variacoes
WHERE variacao_pct IS NOT NULL
GROUP BY ano
ORDER BY ano;

-- Quantos anos cada país foi o mais caro, com RANK.
WITH ranking AS (
    SELECT
        ano,
        pais,
        RANK() OVER (PARTITION BY ano ORDER BY preco DESC) AS posicao
    FROM precos
)
SELECT pais, COUNT(*) AS anos_como_mais_caro
FROM ranking
WHERE posicao = 1
GROUP BY pais
ORDER BY anos_como_mais_caro DESC;
