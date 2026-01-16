DECLARE @Query AS VARCHAR(MAX);


SET @Query = '
	SELECT
		SI.cServicoItem,
		SI.cServico,
		SI.Descricao,
		SI.Quantidade,
		SI.ValorUnitarioLiquido,
		SI.ValorTotalLiquido,
		SI.cVendedor,
		PV.NomeRazao,
		S.cServicoGrupo AS GrupoServico
	FROM TbOpr_ServicoItem SI
	INNER JOIN TbCad_Vendedor V ON V.cVendedor = SI.cVendedor AND V.cEmpresa = SI.cEmpresa
	INNER JOIN TbCad_Pessoa PV ON PV.cPessoa = V.cPessoa
	INNER JOIN TbOpr_Servico S ON SI.cServico = S.cServico
	WHERE
		SI.Estado = ''''
		AND SI.cEmpresa = ' + @cEmpresa + '
		AND SI.cAtendimento = ' + @cAtendimento + '
';

IF (@cServicoGrupo <> '')
	SET @Query = @Query + ' AND S.cServicoGrupo = ''' + @cServicoGrupo + '''';

IF (@cServico <> '')
	SET @Query = @Query + ' AND S.cServico = ''' + @cServicoGrupo + '''';

EXECUTE(@Query);