	DECLARE @Query AS VARCHAR(MAX);

	SET @Query = '
	SELECT 
		''Venda'' AS TipoVenda,
		PG.cProdutoGrupo,
		PG.Descricao GrupoDescricao,
		AI.cProdutoEmbalagem,
		AI.Descricao,
		V.cVenda,
		A.cCliente,
		A.IdPedidoZeDelivery AS ZeDlvID,
		CAST(V.Data AS DATE) AS Data,
		AI.Quantidade * PE.QtdeEmbalagem AS Quantidade,
		AI.ValorTotalLiquido,
		AI.DescontoValor,
		(AI.CustoFuncionalValor + AI.ComissaoPrecoValor + AI.IcmsValor + AI.PisValor + AI.IpiValor + AI.CofinsValor) AS Custo,
		(AI.PrecoCusto * AI.Quantidade) AS PrecoCusto,
		AI.LucroValor AS Lucro,
		(AI.ValorTotalLiquido - (AI.CustoFuncionalValor + AI.ComissaoPrecoValor + AI.IcmsValor + AI.PisValor + AI.IpiValor + AI.CofinsValor) - (AI.PrecoCusto * AI.Quantidade)) AS LucroReal
		FROM TbOpr_Atendimento A 
		INNER JOIN TbOpr_AtendimentoItem AI ON A.cAtendimento = AI.cAtendimento AND A.cEmpresa = AI.cEmpresa
		INNER JOIN TbOpr_Venda V ON A.cAtendimento = V.cAtendimento AND A.cEmpresa = V.cEmpresa
		INNER JOIN TbCad_ProdutoEmbalagem PE ON AI.cProdutoEmbalagem = PE.cProdutoEmbalagem 
		INNER JOIN TbCad_Produto p ON PE.cProduto = P.cProduto
		INNER JOIN TbCad_ProdutoGrupo PG ON P.cProdutoGrupo = PG.cProdutoGrupo
		LEFT JOIN TbCad_ProdutoMarca PM ON P.cProdutoMarca = PM.cProdutoMarca
		WHERE 1=1 
		AND V.Estado != 10
		AND AI.Estado = 0
	'

	IF(@DataInicial <> '')
		SET @Query = @Query + ' AND CAST(V.Data AS DATE) >= '''+@DataInicial+''''

	IF(@DataFinal <> '')
		SET @Query = @Query + ' AND CAST(V.Data AS DATE) <= '''+@DataFinal+''''

	IF(@cVenda <> '')
		SET @Query = @Query + ' AND V.cVenda = '''+@cVenda+''''

	IF(@cCliente <> '')
		SET @Query = @Query + ' AND A.cCliente = '''+@cCliente+''''

	IF(@cGrupo <> '')
		SET @Query = @Query + ' AND P.cProdutoGrupo = '''+@cGrupo+''''

	IF(@cSubGrupo <> '')
		SET @Query = @Query + ' AND P.cProdutoSubGrupo = '''+@cSubGrupo+''''

	IF(@cProduto <>'')
		SET @Query = @Query + ' AND P.cProduto = '''+@cProduto+''''

	IF(@cMarca <>'')
		SET @Query = @Query + ' AND PM.cProdutoMarca = '''+@cMarca+''''

	IF(@cFornecedor <>'')
		SET @Query = @Query + ' AND AI.cProdutoEmbalagem IN (SELECT NFI.cProdutoEmbalagem FROM TbOpr_NotaFiscalFornecedorItem NFI WHERE NFI.cPessoa =   '''+@cFornecedor+''' AND NFI.cEmpresa = '''+@cEmpresa+''') '

	IF(@ZeDelivery <>'')
		SET @Query = @Query + ' AND A.IdPedidoZeDelivery IS NOT NULL '

	SET @Query = @Query + ' AND V.cEmpresa = '''+@cEmpresa+''''

	SET @Query = @Query + '

	UNION ALL

	SELECT 
		''Estorno'' AS TipoVenda,
		PG.cProdutoGrupo,
		PG.Descricao GrupoDescricao,
		AI.cProdutoEmbalagem,
		AI.Descricao,
		V.cVenda,
		A.cCliente,
		A.IdPedidoZeDelivery AS ZeDlvID,
		CAST(O.Data AS DATE) AS Data,
		AI.Quantidade * PE.QtdeEmbalagem * -1 AS Quantidade,
		AI.ValorTotalLiquido * -1 AS ValorTotalLiquido,
		0 AS DescontoValor,
		(AI.CustoFuncionalValor + AI.ComissaoPrecoValor + AI.IcmsValor + AI.PisValor + AI.IpiValor + AI.CofinsValor) * -1 AS Custo,
		(AI.PrecoCusto * AI.Quantidade)  * -1 AS PrecoCusto,
		AI.LucroValor  * -1 AS Lucro ,
		(AI.ValorTotalLiquido - (AI.CustoFuncionalValor + AI.ComissaoPrecoValor + AI.IcmsValor + AI.PisValor + AI.IpiValor + AI.CofinsValor) - (AI.PrecoCusto * AI.Quantidade))  * -1 AS LucroReal
	FROM 
		TbOpr_Atendimento A 
		INNER JOIN TbOpr_Venda V ON A.cAtendimento = V.cAtendimento AND A.cEmpresa = V.cEmpresa
		INNER JOIN TbOpr_VendaEstorno VES ON VES.cVenda = V.cVenda
		INNER JOIN TbOpr_VendaEstornoItem VEI ON VEI.cOperacao = VES.cOperacao AND VEI.cEmpresa = VES.cEmpresa
		INNER JOIN TbOpr_Operacao O ON O.cOperacao = VES.cOperacao AND O.cEmpresa = VES.cEmpresa
		INNER JOIN TbOpr_AtendimentoItem AI ON AI.cAtendimentoItem = VEI.cAtendimentoItem AND AI.cEmpresa = VEI.cEmpresa
		INNER JOIN TbCad_ProdutoEmbalagem PE ON AI.cProdutoEmbalagem = PE.cProdutoEmbalagem 
		INNER JOIN TbCad_Produto p ON PE.cProduto = P.cProduto
		INNER JOIN TbCad_ProdutoGrupo PG ON P.cProdutoGrupo = PG.cProdutoGrupo
		LEFT JOIN TbCad_ProdutoMarca PM ON P.cProdutoMarca = PM.cProdutoMarca
	WHERE 1=1 
		AND V.Estado != 10
		AND AI.Estado = 0
		AND VES.Estado = 2
	'

	IF(@DataInicial <> '')
		SET @Query = @Query + ' AND CAST(O.Data AS DATE) >= '''+@DataInicial+''''

	IF(@DataFinal <> '')
		SET @Query = @Query + ' AND CAST(O.Data AS DATE) <= '''+@DataFinal+''''

	IF(@cVenda <> '')
		SET @Query = @Query + ' AND V.cVenda = '''+@cVenda+''''

	IF(@cCliente <> '')
		SET @Query = @Query + ' AND A.cCliente = '''+@cCliente+''''

	IF(@cGrupo <> '')
		SET @Query = @Query + ' AND P.cProdutoGrupo = '''+@cGrupo+''''

	IF(@cSubGrupo <> '')
		SET @Query = @Query + ' AND P.cProdutoSubGrupo = '''+@cSubGrupo+''''

	IF(@cProduto <>'')
		SET @Query = @Query + ' AND P.cProduto = '''+@cProduto+''''

	IF(@cMarca <>'')
		SET @Query = @Query + ' AND PM.cProdutoMarca = '''+@cMarca+''''

	IF(@cFornecedor <>'')
		SET @Query = @Query + ' AND AI.cProdutoEmbalagem IN (SELECT NFI.cProdutoEmbalagem FROM TbOpr_NotaFiscalFornecedorItem NFI WHERE NFI.cPessoa =   '''+@cFornecedor+''' AND NFI.cEmpresa = '''+@cEmpresa+''') '
	
	IF(@ZeDelivery <>'')
		SET @Query = @Query + ' AND A.IdPedidoZeDelivery IS NOT NULL '

	SET @Query = @Query + ' AND V.cEmpresa = '''+@cEmpresa+''''

	SET @Query = @Query + '

	UNION ALL

	SELECT 
		''Devolução NF'' AS TipoVenda,
		QQ.cProdutoGrupo,
		QQ.GrupoDescricao,
		QQ.cProdutoEmbalagem,
		QQ.Descricao,
		QQ.cVenda,
		QQ.cCliente,
		QQ.IdPedidoZeDelivery AS ZeDlvID,
		QQ.DataEmissao,
		QQ.Quantidade * -1,
		QQ.ValorTotalLiquido * -1 AS ValorTotalLiquido,
		QQ.DescontoValor,
		(((AI.CustoFuncionalValor + AI.ComissaoPrecoValor)/AI.Quantidade * QQ.Quantidade) + QQ.Custo) * -1 AS Custo,
		((AI.PrecoCusto + QQ.Custo) * QQ.QuantidadeItem) * -1 AS PrecoCusto,
		AI.LucroValor * -1 AS LucroValor,
		((QQ.ValorTotalLiquido - (((AI.CustoFuncionalValor + AI.ComissaoPrecoValor)/AI.Quantidade * QQ.Quantidade) + QQ.Custo)) - (AI.PrecoCusto * QQ.QuantidadeItem)) * -1 AS LucroReal
	FROM (
		SELECT
			Q.cAtendimento,
			PG.cProdutoGrupo,
			PG.Descricao AS GrupoDescricao,
			NFPI.cProdutoEmbalagem,
			NFPI.Descricao,
			Q.cVenda,
			Q.cCliente,
			Q.IdPedidoZeDelivery,
			NFP.DataEmissao,
			NFPI.Quantidade AS QuantidadeItem,
			NFPI.Quantidade * PE.QtdeEmbalagem AS Quantidade,
			NFPI.ValorTotalLiquido,
			NFPI.DescontoValor,
			(COALESCE(NFPI.IcmsValor, 0) + COALESCE(NFPI.PisValor, 0) + COALESCE(NFPI.IpiValor, 0) + COALESCE(NFPI.CofinsValor, 0)) AS Custo
		FROM
			(
			SELECT
				A.cAtendimento,
				A.cCliente,
				A.IdPedidoZeDelivery,
				V.cVenda,
				_NFP.Chave
			FROM 
				TbOpr_Atendimento A 
				INNER JOIN TbOpr_Venda V ON A.cAtendimento = V.cAtendimento AND A.cEmpresa = V.cEmpresa
				INNER JOIN TbOpr_NotaFiscalPropria _NFP ON _NFP.cNotaFiscalModelo = V.cNotaFiscalModelo AND _NFP.Numero = V.NumeroNF AND _NFP.Serie = V.Serie AND _NFP.cEmpresa = V.cEmpresa
			WHERE 1=1 
				AND V.Estado != 10
	'

	SET @Query = @Query + ' AND V.cEmpresa = '''+@cEmpresa+'''
			) AS Q,
			TbOpr_NotaFiscalPropria NFP
			INNER JOIN TbOpr_NotaFiscalPropriaItem NFPI ON NFPI.cEmpresa = NFP.cEmpresa AND NFPI.cNotaFiscalModelo = NFP.cNotaFiscalModelo AND NFPI.Serie = NFP.Serie AND NFPI.Numero = NFP.Numero
			INNER JOIN TbCad_EFD_CFOP EC ON EC.cCfop = NFP.cCfop
		
			INNER JOIN TbCad_ProdutoEmbalagem PE ON PE.cProdutoEmbalagem = NFPI.cProdutoEmbalagem 
			INNER JOIN TbCad_Produto P ON P.cProduto = PE.cProduto
			INNER JOIN TbCad_ProdutoGrupo PG ON PG.cProdutoGrupo = P.cProdutoGrupo
			LEFT JOIN TbCad_ProdutoMarca PM ON PM.cProdutoMarca = P.cProdutoMarca
		WHERE
			1=1 
			AND NFP.ChaveReferenciada IN (Q.Chave)
			AND NFP.Estado = 3
			AND EC.IsEntrada = 1 
			AND EC.IsDevolucao = 1
			AND EXISTS 
			(
			SELECT 
				OFR.cOperacao 
			FROM 
				TbOpr_OperacaoFaturamentoReceber OFR 
			WHERE 
				OFR.cOperacao = NFP.cOperacao
				AND OFR.cEmpresa = NFP.cEmpresa 
				AND OFR.IsConfirmado = 1
				AND OFR.IsDevolucao = 1
				AND OFR.IsGerado = 1
			)
	'

	IF(@DataInicial <> '')
		SET @Query = @Query + ' AND CAST(NFP.DataEmissao AS DATE) >= '''+@DataInicial+''''

	IF(@DataFinal <> '')
		SET @Query = @Query + ' AND CAST(NFP.DataEmissao AS DATE) <= '''+@DataFinal+''''

	IF(@cVenda <> '')
		SET @Query = @Query + ' AND Q.cVenda = '''+@cVenda+''''

	IF(@cCliente <> '')
		SET @Query = @Query + ' AND Q.cCliente = '''+@cCliente+''''

	IF(@cGrupo <> '')
		SET @Query = @Query + ' AND P.cProdutoGrupo = '''+@cGrupo+''''

	IF(@cSubGrupo <> '')
		SET @Query = @Query + ' AND P.cProdutoSubGrupo = '''+@cSubGrupo+''''

	IF(@cSecao <> '')
		SET @Query = @Query + ' AND P.cProdutoSecao = '''+@cSecao+''''

	IF(@cProduto <>'')
		SET @Query = @Query + ' AND P.cProduto = '''+@cProduto+''''

	IF(@cMarca <>'')
		SET @Query = @Query + ' AND PM.cProdutoMarca = '''+@cMarca+''''

	IF(@cFornecedor <>'')
		SET @Query = @Query + ' AND NFPI.cProdutoEmbalagem IN (SELECT NFI.cProdutoEmbalagem FROM TbOpr_NotaFiscalFornecedorItem NFI WHERE NFI.cPessoa = '''+@cFornecedor+''' AND NFI.cEmpresa = '''+@cEmpresa+''') '

	IF(@ZeDelivery <>'')
		SET @Query = @Query + ' AND Q.IdPedidoZeDelivery IS NOT NULL '

	SET @Query = @Query + '
	) QQ
	CROSS APPLY(
		SELECT TOP 1 * FROM TbOpr_AtendimentoItem AI WHERE  AI.cAtendimento = QQ.cAtendimento AND AI.cProdutoEmbalagem = QQ.cProdutoEmbalagem
	) AI
	'

	EXECUTE(@Query)