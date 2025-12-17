SELECT
	AI.cAtendimentoItem,
	AI.cProdutoEmbalagem,
	AI.Descricao,
	AI.Quantidade,
	AI.ValorUnitarioLiquido,
	AI.ValorTotalLiquido,
	AI.cVendedor,
	PV.NomeRazao
FROM TbOpr_AtendimentoItem AI 
INNER JOIN TbCad_Vendedor V ON V.cVendedor = AI.cVendedor AND V.cEmpresa = AI.cEmpresa
INNER JOIN TbCad_Pessoa PV ON PV.cPessoa = V.cPessoa
WHERE
	AI.Estado = 0
	AND AI.cEmpresa = @cEmpresa 
	AND AI.cAtendimento = @cAtendimento