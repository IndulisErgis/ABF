
CREATE PROCEDURE dbo.trav_PsTransPost_SalesRep_proc
AS
SET NOCOUNT ON
BEGIN TRY
	--Rounding adjustment is not part of commission invoice total
	--Reward Redemption

	DECLARE @UseCommissions bit, @CommByLineItemYn bit

	--Retrieve global values
	SELECT @UseCommissions = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'UseCommissions'
	SELECT @CommByLineItemYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'CommByLineItemYn'

	IF @UseCommissions IS NULL OR @CommByLineItemYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #tmpCommissions 
	(
		TransID bigint NOT NULL, 
		SalesRepId pSalesRep NULL, 
		InvcDate datetime NOT NULL, 
		TransType smallint NOT NULL, 
		SalesTax pDecimal NOT NULL DEFAULT (0), 
		Freight pDecimal NOT NULL DEFAULT (0), 
		Misc pDecimal NOT NULL DEFAULT (0), 
		PriceExt pDecimal NOT NULL DEFAULT (0), 
		CustId pCustId NULL, 
		InvcNum pInvoiceNum NOT NULL, 
		AmtCogs pDecimal NOT NULL DEFAULT (0) 
	)

	-- insert a record for the header
	INSERT INTO #tmpCommissions (TransID, SalesRepId, InvcDate, TransType, SalesTax, Freight, Misc, PriceExt, CustId, InvcNum, AmtCogs) 
	SELECT h.ID, h.SalesRepID, h.TransDate, TransType, SIGN(h.TransType) * d.SalesTax, SIGN(h.TransType) * d.Freight, 
		SIGN(h.TransType) * d.Misc, 0, h.BillToID, t.InvoiceNum, 0 
	FROM #PsTransList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID
		INNER JOIN (SELECT HeaderID, SUM(CASE LineType WHEN 2 THEN ExtPrice ELSE 0 END) SalesTax, 
			SUM(CASE LineType WHEN 3 THEN ExtPrice ELSE 0 END) Freight, 
			SUM(CASE LineType WHEN 4 THEN ExtPrice ELSE 0 END) Misc 
		FROM dbo.tblPsTransDetail 
		WHERE LineType IN (2, 3, 4)	
		GROUP BY HeaderID) d ON h.ID = d.HeaderID 
	WHERE h.VoidDate IS NULL AND h.SalesRepID IS NOT NULL

	-- insert a record for each line item in the detail
	INSERT INTO #tmpCommissions (TransID, SalesRepId, InvcDate, TransType, SalesTax, Freight, Misc, PriceExt, CustId, InvcNum, AmtCogs) 
	SELECT h.ID, ISNULL(d.SalesRepID, h.SalesRepID), h.TransDate, TransType, 0, 0, 0, SIGN(TransType) * (d.ExtPrice - ISNULL(c.ExtPrice,0)), 
		h.BillToID, t.InvoiceNum, SIGN(TransType) * ISNULL(i.ExtCost,0)
	FROM #PsTransList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransDetail d ON h.ID = d.HeaderID 
		LEFT JOIN dbo.tblPsTransDetailIN i ON d.ID = i.DetailID 
		LEFT JOIN (SELECT ParentID, SUM(ExtPrice) AS ExtPrice 
			FROM dbo.tblPsTransDetail 
			WHERE LineType IN (-2, -3) AND ParentID IS NOT NULL 
			GROUP BY ParentID) c ON d.ID = c.ParentID
	WHERE h.VoidDate IS NULL AND d.LineType = 1 AND ISNULL(d.SalesRepID, h.SalesRepID) IS NOT NULL

	-- insert a record for total coupon/discount of header
	INSERT INTO #tmpCommissions (TransID, SalesRepId, InvcDate, TransType, SalesTax, Freight, Misc, PriceExt, CustId, InvcNum, AmtCogs) 
	SELECT h.ID, h.SalesRepID, h.TransDate, TransType, 0, 0, 0, SIGN(TransType) * c.ExtPrice, h.BillToID, t.InvoiceNum, 0 
	FROM #PsTransList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN (SELECT d.HeaderID, SUM(-d.ExtPrice) AS ExtPrice
		FROM dbo.tblPsTransDetail d LEFT JOIN dbo.tblPsTransDetail l ON d.ParentID = l.ID
		WHERE d.LineType IN (-2, -3) AND l.ID IS NULL	
		GROUP BY d.HeaderID) c ON h.ID = c.HeaderID 
	WHERE h.VoidDate IS NULL AND h.SalesRepID IS NOT NULL

	-- update Sales Reps (PTDSales, YTDSales, & LastSalesDate)
	UPDATE dbo.tblArSalesRep SET PTDSales = dbo.tblArSalesRep.PTDSales + t.Sales
		, YTDSales = dbo.tblArSalesRep.YTDSales + t.Sales
		, LastSalesDate = CASE WHEN t.InvcDate > dbo.tblArSalesRep.LastSalesDate OR dbo.tblArSalesRep.LastSalesDate IS NULL
			THEN t.InvcDate ELSE dbo.tblArSalesRep.LastSalesDate END 
	FROM dbo.tblArSalesRep 
		INNER JOIN (SELECT SalesRepId, MAX(CASE WHEN TransType > 0 THEN InvcDate ELSE NULL END) InvcDate
				, SUM(PriceExt + SalesTax + Freight + Misc) Sales 
			FROM #tmpCommissions GROUP BY SalesRepId) t 
		ON dbo.tblArSalesRep.SalesRepId = t.SalesRepId

	--update Commissions (tblArCommInvc)
	IF (@UseCommissions = 1)
	BEGIN
		--add new commission invoice records **/
		IF (@CommByLineItemYn = 1)
		BEGIN
			INSERT dbo.tblArCommInvc (SalesRepID, CustId, InvcNum, InvcDate, PctInvc, CommRateDtl, PctOfDtl, BasedOnDtl
				, PayLines, PayTax, PayFreight, PayMisc, AmtLines, AmtTax, AmtFreight, AmtMisc, AmtCogs, AmtInvc, AmtPmt) 
			SELECT s.SalesRepID, t.CustId, t.InvcNum, t.InvcDate, 100, s.CommRate, s.PctOf, s.BasedOn, s.PayOnLineItems, 
				s.PayOnSalesTax, s.PayOnFreight, s.PayOnMisc, t.PriceExt, t.SalesTax, t.Freight, t.Misc, t.AmtCogs, 
				SIGN(t.TransType) * d.InvoiceTotal, SIGN(t.TransType) * d.Payment 
			FROM dbo.tblArSalesRep s INNER JOIN #tmpCommissions t ON s.SalesRepID = t.SalesRepId 
				INNER JOIN (SELECT HeaderID, SUM(CASE WHEN LineType = -1 OR LineType = -4 THEN ExtPrice ELSE 0 END) AS Payment, --including rounding adjustment
					SUM(CASE WHEN LineType = -1 OR LineType = -4 THEN 0 ELSE SIGN(LineType) * ExtPrice END) InvoiceTotal
					FROM dbo.tblPsTransDetail
					GROUP BY HeaderID) d ON t.TransID = d.HeaderID
		END
		ELSE
		BEGIN
			INSERT dbo.tblArCommInvc (SalesRepID, CustId, InvcNum, InvcDate, PctInvc, CommRateDtl, PctOfDtl, BasedOnDtl
				, PayLines, PayTax, PayFreight, PayMisc, AmtLines, AmtTax, AmtFreight, AmtMisc, AmtCogs, AmtInvc, AmtPmt) 
			SELECT s.SalesRepID, h.BillToID, h.TransIDPrefix + CAST(h.TransID AS varchar), h.TransDate, 100, s.CommRate, 
				s.PctOf, s.BasedOn, s.PayOnLineItems, s.PayOnSalesTax, s.PayOnFreight, s.PayOnMisc, 
				SIGN(h.TransType) * d.ExtPrice, SIGN(h.TransType) * d.Tax, SIGN(h.TransType) * d.Freight, SIGN(h.TransType) * d.Misc, 
				SIGN(h.TransType) * ISNULL(d.ExtCost,0), SIGN(h.TransType) * d.InvoiceTotal, SIGN(h.TransType) * d.Payment
			FROM #PsTransList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID
				INNER JOIN dbo.tblArSalesRep s ON h.SalesRepID = s.SalesRepID
				INNER JOIN (SELECT d.HeaderID, SUM(CASE WHEN d.LineType = 1 THEN d.ExtPrice WHEN d.LineType IN (-2, -3) THEN -d.ExtPrice ELSE 0 END) AS ExtPrice, 
					SUM(ExtCost) AS ExtCost, SUM(CASE WHEN d.LineType = -1 OR LineType = -4 THEN d.ExtPrice ELSE 0 END) AS Payment, --including rounding adjustment
					SUM(CASE WHEN d.LineType = 4 THEN d.ExtPrice ELSE 0 END) AS Misc, 
					SUM(CASE WHEN d.LineType = 2 THEN d.ExtPrice ELSE 0 END) AS Tax, SUM(CASE WHEN d.LineType = 3 THEN d.ExtPrice ELSE 0 END) AS Freight,
					SUM(CASE WHEN LineType = -1 OR LineType = -4 THEN 0 ELSE SIGN(LineType) * ExtPrice END) InvoiceTotal
					FROM dbo.tblPsTransDetail d LEFT JOIN dbo.tblPsTransDetailIN i ON d.ID = i.DetailID 
					GROUP BY d.HeaderID) d ON h.ID = d.HeaderID
			WHERE h.VoidDate IS NULL
		END
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_SalesRep_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_SalesRep_proc';

