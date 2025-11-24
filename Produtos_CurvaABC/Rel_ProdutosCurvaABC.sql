WITH ValorTotalVendido AS (
    SELECT 
        P.Codigo,
        P.Descricao,
        ROUND(P.PrecoVenda, 2) AS PrecoVenda,
        Q.Venda AS QtdeVendas,
        ROUND(Q.Venda * P.PrecoVenda, 2) AS ValorTotal
    FROM Produtos P
    INNER JOIN VwVendaProdutoQuantidade Q ON Q.Codigo = P.Codigo
),
Ordenado AS (
    SELECT
        *,
        SUM(ValorTotal) OVER() AS ValorGeral,
        SUM(ValorTotal) OVER(ORDER BY ValorTotal DESC, Codigo) AS Acumulado
    FROM ValorTotalVendido
),
Classificado AS (
    SELECT
        Codigo,
        Descricao,
        PrecoVenda,
        QtdeVendas,
        ValorTotal,      
        CAST((Acumulado / NULLIF(ValorGeral,0)) * 100 AS DECIMAL(10,2)) AS PercentualAcumulado,
        CASE 
            WHEN (Acumulado / NULLIF(ValorGeral,0)) <= 0.80 THEN 'A'
            WHEN (Acumulado / NULLIF(ValorGeral,0)) <= 0.95 THEN 'B'
            ELSE 'C'
        END AS Classe
    FROM Ordenado
)
SELECT
Codigo, 
descricao as Descricao, 
PrecoVenda, 
QtdeVendas,
Classe
FROM Classificado
ORDER BY ValorTotal DESC;