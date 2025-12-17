DECLARE @Query AS VARCHAR(MAX);
DECLARE @FistHour AS VARCHAR(13) = ' 00:00:00.000';
DECLARE @LastHour AS VARCHAR(13) = ' 23:59:59.999'

SET @Query = '
	SELECT 
		VA.cVendedor,
		PA.NomeRazao AS NomeRazaoVendedor,
		A.cAtendimento,
		A.DataHora,
		A.Hora,
		A.OrdemServicoEstado,
		CASE A.OrdemServicoEstado
			WHEN 1 THEN ''Aberto''
			WHEN 2 THEN ''Liberado''
			WHEN 3 THEN ''Concluido''
		END AS OrdemServicoEstadoDescricao,
		A.ValorTotalLiquido,
		C.cCliente,
		PC.NomeRazao AS NomeRazaoCliente
	FROM TbOpr_Atendimento A
	INNER JOIN TbCad_Cliente C ON C.cCliente = A.cCliente
	INNER JOIN TbCad_Pessoa PC ON PC.cPessoa = C.cPessoa
	INNER JOIN TbCad_Vendedor VA ON VA.cVendedor = A.cVendedor 
	INNER JOIN TbCad_Pessoa PA ON PA.cPessoa = VA.cPessoa

	WHERE A.cEmpresa = ' + @cEmpresa + '
		AND A.Tipo = 1
		AND A.Estado NOT IN (100, 101)
  ';

  IF(@DataInicial <> '')
    	SET @Query = @Query + ' AND A.DataHora >= ''' + @DataInicial + @FistHour + ''''

  IF(@DataFinal <> '')
    	SET @Query = @Query + ' AND A.DataHora <= ''' + @DataFinal + @LastHour + ''''

IF (@Situacao <> '')
 	SET @Query = @Query + ' AND A.OrdemServicoEstado =  ''' + @Situacao + ''''

IF (@cCliente <> '') 
  SET @Query = @Query + ' AND C.cCliente = ''' + @cCliente + '''';

IF (@cVendedorResp <> '') 
  SET @Query = @Query + ' AND VA.cVendedor = ''' + @cVendedorResp + '''';

IF (@cVendedorTec <> '')
	SET @Query = @Query + ' 
		AND A.cAtendimento IN (
			SELECT SI.cAtendimento 
			FROM TbOpr_ServicoItemComissaoRateio SICR
			INNER JOIN TbOpr_ServicoItem SI ON SI.cServicoItem = SICR.cServicoItem
			WHERE SICR.cVendedor = ''' + @cVendedorTec + '''

			UNION 

			SELECT SI.cAtendimento 
			FROM TbOpr_ServicoItem SI
			WHERE SI.cVendedor = ''' + @cVendedorTec + '''
		)
	';


EXECUTE(@Query);