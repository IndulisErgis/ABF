
CREATE PROCEDURE dbo.trav_SoTransPost_SalesRep_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @PrecCurr smallint, @UseCommissions bit, @CommByLineItemYn bit

	--Retrieve global values
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @UseCommissions = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'UseCommissions'
	SELECT @CommByLineItemYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'CommByLineItemYn'

	IF @PrecCurr IS NULL OR @UseCommissions IS NULL OR @CommByLineItemYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	CREATE TABLE #tmpCommissions 
	(
		TransID pTransId NOT NULL, 
		SalesRep1Id pSalesRep NULL, 
		SalesRep2Id pSalesRep NULL,
		InvcDate datetime, 
		TransType smallint, 
		SalesTax pDecimal NULL DEFAULT (0), 
		TaxAmtAdj pDecimal NULL DEFAULT (0), 
		Freight pDecimal NULL DEFAULT (0), 
		Misc pDecimal NULL DEFAULT (0), 
		PriceExt pDecimal NULL DEFAULT (0), 
		CustId pCustId, 
		InvcNum pInvoiceNum, 
		SalesRep1Pct pDecimal NULL DEFAULT (0), 
		CommRate1 pDecimal NULL DEFAULT (0), 
		SalesRep2Pct pDecimal NULL DEFAULT (0), 
		CommRate2 pDecimal NULL DEFAULT (0), 
		AmtCogs pDecimal NULL DEFAULT (0) 
	)

	-- insert a record for the header
	INSERT INTO #tmpCommissions (TransID, SalesRep1Id, SalesRep2Id, InvcDate, TransType, SalesTax, TaxAmtAdj
		, Freight, Misc, PriceExt, CustId, InvcNum, SalesRep1Pct, CommRate1, SalesRep2Pct, CommRate2, AmtCogs) 
		SELECT h.TransID, Rep1Id, Rep2Id, InvcDate, TransType, SIGN(TransType) * SalesTax, SIGN(TransType) * TaxAmtAdj
			, SIGN(TransType) * Freight, SIGN(TransType) * Misc, 0, CustId
			, CASE WHEN TransType < 0 
				THEN ISNULL(OrgInvcNum, l.DefaultInvoiceNumber) 
				ELSE l.DefaultInvoiceNumber
				END
			, Rep1Pct, Rep1CommRate, Rep2Pct, Rep2CommRate, 0 
		FROM dbo.tblSoTransHeader h
		INNER JOIN #PostTransList l on h.TransId = l.TransId
		WHERE (SalesTax <> 0 OR TaxAmtAdj <> 0 OR Freight <> 0 OR Misc <> 0)

	-- insert a record for each line item in the detail
	INSERT INTO #tmpCommissions (TransID, SalesRep1Id, SalesRep2Id, InvcDate, TransType, SalesTax, TaxAmtAdj
		, Freight, Misc, PriceExt, CustId, InvcNum, SalesRep1Pct, CommRate1, SalesRep2Pct, CommRate2, AmtCogs) 
		SELECT h.TransID
			, CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Id ELSE d.Rep1Id END
			, CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Id ELSE d.Rep2Id END
			, h.InvcDate, h.TransType, 0, 0
			, 0, 0, SIGN(TransType) * d.PriceExt, h.CustId
			, CASE WHEN TransType < 0 
				THEN ISNULL(OrgInvcNum, l.DefaultInvoiceNumber) 
				ELSE l.DefaultInvoiceNumber
				END
			, CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Pct ELSE d.Rep1Pct END
			, CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1CommRate ELSE d.Rep1CommRate END
			, CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Pct ELSE d.Rep2Pct END
			, CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2CommRate ELSE d.Rep2CommRate END
			, CASE WHEN TransType < 0 
				THEN -ROUND((QtyOrdSell * isnull(UnitCommBasis, UnitCostSell)), @PrecCurr) -- use authorized qty for Credits
				ELSE ROUND((QtyShipSell * isnull(UnitCommBasis, UnitCostSell)), @PrecCurr) 
				END
		FROM dbo.tblSoTransHeader h
		INNER JOIN dbo.tblSoTransDetail d ON h.TransID = d.TransID 
		INNER JOIN #PostTransList l on h.TransId = l.TransId
		WHERE GrpId IS NULL
			AND (PriceExt <> 0 OR (QtyShipSell * isnull(UnitCommBasis, UnitCostSell)) <> 0 
			OR (QtyOrdSell * isnull(UnitCommBasis, UnitCostSell)) <> 0)

	-- update Sales Reps (PTDSales, YTDSales, & LastSalesDate)
	-- process values for sales rep 1
	UPDATE dbo.tblArSalesRep SET PTDSales = dbo.tblArSalesRep.PTDSales + t.Sales
		, YTDSales = dbo.tblArSalesRep.YTDSales + t.Sales
		, LastSalesDate = CASE WHEN t.InvcDate > dbo.tblArSalesRep.LastSalesDate OR dbo.tblArSalesRep.LastSalesDate IS NULL
			THEN t.InvcDate ELSE dbo.tblArSalesRep.LastSalesDate END 
	FROM dbo.tblArSalesRep 
		INNER JOIN (SELECT SalesRep1Id, MAX(CASE WHEN TransType > 0 THEN InvcDate ELSE NULL END) InvcDate
				, SUM(PriceExt + SalesTax + TaxAmtAdj + Freight + Misc) Sales 
			FROM #tmpCommissions GROUP BY SalesRep1Id) t 
		ON dbo.tblArSalesRep.SalesRepId = t.SalesRep1Id

	-- process values for sales rep 2
	UPDATE dbo.tblArSalesRep SET PTDSales = dbo.tblArSalesRep.PTDSales + t.Sales
		, YTDSales = dbo.tblArSalesRep.YTDSales + t.Sales
		, LastSalesDate = CASE WHEN t.InvcDate > dbo.tblArSalesRep.LastSalesDate OR dbo.tblArSalesRep.LastSalesDate IS NULL
			THEN t.InvcDate ELSE dbo.tblArSalesRep.LastSalesDate END 
	FROM dbo.tblArSalesRep 
		INNER JOIN (SELECT SalesRep2Id, MAX(CASE WHEN TransType > 0 THEN InvcDate ELSE NULL END) InvcDate
				, SUM(PriceExt + SalesTax + TaxAmtAdj + Freight + Misc) Sales 
			FROM #tmpCommissions GROUP BY SalesRep2Id) t 
		ON dbo.tblArSalesRep.SalesRepId = t.SalesRep2Id


	--update Commissions (tblArCommInvc)
	IF (@UseCommissions = 1)
	BEGIN
		--add new commission invoice records **/
		IF (@CommByLineItemYn = 1)
		BEGIN
			INSERT dbo.tblArCommInvc (SalesRepID, CustId, InvcNum, InvcDate, PctInvc, CommRateDtl, PctOfDtl, BasedOnDtl
				, PayLines, PayTax, PayFreight, PayMisc, AmtLines, AmtTax, AmtFreight, AmtMisc, AmtCogs, AmtInvc) 
			SELECT sr.SalesRepID, c.CustId, c.InvcNum, c.InvcDate, c.SalesRepPct, c.CommRate, sr.PctOf, sr.BasedOn
				, CONVERT(smallint,sr.PayOnLineItems), CONVERT(smallint,sr.PayOnSalesTax)
				, CONVERT(smallint,sr.PayOnFreight), CONVERT(smallint,sr.PayOnMisc)
				, PriceExt, SalesTax + TaxAmtAdj, Freight, Misc, AmtCogs, AmtInvc 
			FROM dbo.tblArSalesRep sr 
				INNER JOIN (SELECT TransId, CustId, InvcNum, InvcDate, PriceExt, SalesTax, TaxAmtAdj, Freight, Misc, AmtCogs
						, SalesRep1ID AS SalesRepId, SalesRep1Pct AS SalesRepPct, CommRate1 AS CommRate
						FROM #tmpCommissions 
						WHERE SalesRep1ID IS NOT NULL AND SalesRep1Pct > 0
					UNION ALL
					SELECT TransId, CustId, InvcNum, InvcDate, PriceExt, SalesTax, TaxAmtAdj, Freight, Misc, AmtCogs
						, SalesRep2ID AS SalesRepId, SalesRep2Pct AS SalesRepPct, CommRate2 AS CommRate
						FROM #tmpCommissions 
						WHERE SalesRep2ID IS NOT NULL AND SalesRep2Pct > 0
				) c  ON sr.SalesRepID = c.SalesRepID 
				LEFT JOIN ( SELECT TransID, SUM(PriceExt + SalesTax + TaxAmtAdj + Freight + Misc) AS AmtInvc 
					FROM #tmpCommissions GROUP BY TransID) Tot ON c.TransID = Tot.TransID 
		END
		ELSE
		BEGIN
			INSERT dbo.tblArCommInvc (SalesRepID, CustId, InvcNum, InvcDate, PctInvc, CommRateDtl, PctOfDtl, BasedOnDtl
				, PayLines, PayTax, PayFreight, PayMisc, AmtLines, AmtTax, AmtFreight, AmtMisc, AmtCogs, AmtInvc) 
			SELECT sr.SalesRepID, c.CustId, c.InvcNum, c.InvcDate, c.SalesRepPct, c.CommRate, sr.PctOf, sr.BasedOn
				, CONVERT(smallint,sr.PayOnLineItems), CONVERT(smallint,sr.PayOnSalesTax)
				, CONVERT(smallint,sr.PayOnFreight), CONVERT(smallint,sr.PayOnMisc)
				, SUM(PriceExt), SUM(SalesTax+ TaxAmtAdj), SUM(Freight), SUM(Misc), SUM(AmtCogs), AmtInvc 
			FROM dbo.tblArSalesRep sr 
				INNER JOIN (SELECT TransId, CustId, InvcNum, InvcDate, PriceExt, SalesTax, TaxAmtAdj, Freight, Misc, AmtCogs
						, SalesRep1ID AS SalesRepId, SalesRep1Pct AS SalesRepPct, CommRate1 AS CommRate
						FROM #tmpCommissions 
						WHERE SalesRep1ID IS NOT NULL AND SalesRep1Pct > 0
					UNION ALL
					SELECT TransId, CustId, InvcNum, InvcDate, PriceExt, SalesTax, TaxAmtAdj, Freight, Misc, AmtCogs
						, SalesRep2ID AS SalesRepId, SalesRep2Pct AS SalesRepPct, CommRate2 AS CommRate
						FROM #tmpCommissions 
						WHERE SalesRep2ID IS NOT NULL AND SalesRep2Pct > 0
				) c  ON sr.SalesRepID = c.SalesRepID 
				LEFT JOIN ( SELECT TransID, SUM(PriceExt + SalesTax + TaxAmtAdj + Freight + Misc) AS AmtInvc 
					FROM #tmpCommissions GROUP BY TransID) Tot ON c.TransID = Tot.TransID
			GROUP BY sr.SalesRepID, c.CustId, c.InvcNum, c.InvcDate, c.SalesRepPct, c.CommRate, sr.PctOf, sr.BasedOn
				, CONVERT(smallint, sr.PayOnLineItems), CONVERT(smallint, sr.PayOnSalesTax)
				, CONVERT(smallint, sr.PayOnFreight), CONVERT(smallint, sr.PayOnMisc)
				, AmtInvc
		END
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_SalesRep_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_SalesRep_proc';

