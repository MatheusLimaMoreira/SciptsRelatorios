
DECLARE @Produto INT = {?Produto};
DECLARE @Marca INT = {?Marca};
DECLARE @Grupo INT = {?Grupo};
DECLARE @Inativo INT = {?Inativo};

SELECT 
	P.Codigo,
	P.descricao AS Descricao,
	M.Descricao AS Marca,
	G.Descricao AS Grupo,
	V.Estoque,
	P.Unidade,
	P.precoVenda AS PrecoVenda,
	P.Inativo
FROM Produtos P
LEFT JOIN Vw_EstoqueProduto V ON V.Codigo = P.Codigo
LEFT JOIN Marcas M ON M.Codigo = P.Marca
LEFT JOIN GrupoProdutos G ON G.Codigo = P.Grupo
WHERE
	(P.Codigo =  @Produto OR @Produto = 0)
AND (M.Codigo = @Marca OR @Marca = 0)
AND	(G.Codigo = @Grupo OR @Grupo = 0)
AND (P.Inativo = @Inativo OR @Inativo= 0)
ORDER BY P.Codigo

