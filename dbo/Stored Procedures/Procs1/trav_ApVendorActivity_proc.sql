
CREATE PROCEDURE [dbo].[trav_ApVendorActivity_proc]
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD'    --Base currency WHEN @PrintAllInBase = 1

AS
SET NOCOUNT ON
BEGIN TRY

		SELECT 0 AS RecType, h.PostRun, h.TransId, d.EntryNum, h.VendorId, v.Name, d.WhseId, h.InvoiceNum, h.CurrencyId, h.InvoiceDate, 
		   h.TransType, h.PONum, h.GLPeriod, h.FiscalYear, d.GLAcct, d.PhaseId, d.JobId, d.CostType, d.PartId, d.[Desc], d.Units, 
		   SIGN(h.TransType) * d.Qty AS Qty, 		   
		   CASE WHEN @PrintAllInBase = 1 THEN SIGN(h.TransType) * d.UnitCost ELSE SIGN(h.TransType) * d.UnitCostFgn END AS UnitCost, 
		   CASE WHEN @PrintAllInBase = 1 THEN SIGN(h.TransType) * d.ExtCost ELSE SIGN(h.TransType) * d.ExtCostFgn END AS ExtCost, 
		   0 AS SalesTax, 0 AS Freight, 0 AS Misc, d.AddnlDesc, 0 AS GrossAmtDue, 0 AS DiscTaken, 0 AS NetPaid, 0 AS NetPaidCalc, 0 AS GainLoss		     
		FROM dbo.tblApVendor AS v 
			INNER JOIN dbo.tblApHistHeader AS h ON v.VendorID = h.VendorId
		    LEFT OUTER JOIN dbo.tblApHistDetail AS d ON h.PostRun = d.PostRun AND h.TransId = d.TransID AND h.InvoiceNum = d.InvoiceNum
		    INNER JOIN #tmpVendorList t ON t.VendorID = h.VendorId AND h.PostRun = t.PostRun  AND h.TransId = t.TransId 
				AND h.InvoiceNum = t.InvoiceNum AND d.EntryNum = t.EntryNum				
		WHERE ( @PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency )  AND ISNULL(d.EntryNum, 0) >= 0 --exclude SalesTax/Freight/Misc detail records

		UNION ALL
		
		SELECT 1 AS RecType, NULL,NULL, NULL, i.VendorId, v.Name, NULL, i.InvoiceNum, i.CurrencyId, i.InvoiceDate, 
		   1, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
		   0 AS Qty, 0 AS UnitCost, 0 AS ExtCost, i.SalesTax, i.Freight, i.Misc, NULL,
		   c.GrossAmtDue, c.DiscTaken,  c.NetPaid, c.NetPaidCalc, 		   
		   CASE WHEN i.CurrencyId = @ReportCurrency THEN 0 ELSE c.GainLoss END  AS GainLoss	
		FROM dbo.tblApVendor AS v 
		INNER JOIN
			(SELECT  h.VendorId,h.InvoiceNum,h.CurrencyId,h.InvoiceDate,
				SUM(CASE WHEN @PrintAllInBase=1 THEN SIGN(h.TransType) * (h.SalesTax + h.TaxAdjAmt) ELSE SIGN(h.TransType) * (h.SalesTaxFgn + h.TaxAdjAmtFgn) END ) AS SalesTax, 
			    SUM(CASE WHEN @PrintAllInBase=1 THEN SIGN(h.TransType) * h.Freight ELSE SIGN(h.TransType) * h.FreightFgn END) AS Freight, 
			    SUM(CASE WHEN @PrintAllInBase=1 THEN SIGN(h.TransType) * h.Misc ELSE SIGN(h.TransType) * h.MiscFgn END) AS Misc
				FROM dbo.tblApHistHeader AS h INNER JOIN  ( SELECT DISTINCT VendorId,InvoiceNum, PostRun, TransId FROM #tmpVendorList) t 
				ON h.VendorID = t.VendorId AND h.InvoiceNum = t.InvoiceNum AND h.PostRun = t.PostRun  AND h.TransId = t.TransId 
				GROUP BY h.VendorId,h.InvoiceNum,h.CurrencyId,h.InvoiceDate
			) i ON i.VendorId = v.VendorID
		LEFT JOIN 
		(SELECT VendorId, InvoiceNum,InvoiceDate, CASE WHEN @PrintAllInBase=1 THEN SUM(GrossAmtDue) ELSE SUM(GrossAmtDueFgn) END AS GrossAmtDue, 
			CASE WHEN @PrintAllInBase=1 THEN SUM(DiscTaken)  ELSE SUM(DiscTakenFgn) END AS DiscTaken,  
			CASE WHEN @PrintAllInBase=1 THEN SUM(GrossAmtDue - DiscTaken)  ELSE SUM(GrossAmtDueFgn - DiscTakenFgn) END AS NetPaid, 
			SUM(NetPaidCalc) NetPaidCalc,
			SUM(CASE WHEN NetPaidCalc <> 0 THEN NetPaidCalc - (GrossAmtDue - DiscTaken) ELSE 0 END) AS GainLoss
		FROM dbo.tblApCheckHist WHERE PmtType <> 9 GROUP BY VendorId, InvoiceNum,InvoiceDate) AS c 
		ON i.VendorId = c.VendorID AND i.InvoiceNum = c.InvoiceNum AND i.InvoiceDate =c.InvoiceDate
		WHERE ( @PrintAllInBase = 1 OR i.CurrencyId = @ReportCurrency )



		-- Data for AP Vendor Activity History Lot subreport
		SELECT  l.PostRun, l.TransId, l.InvoiceNum, l.EntryNum, SeqNum, ItemId, LocId, LotNum, QtyOrder, QtyFilled, QtyBkord, 
			CostUnit, CostUnitFgn, HistSeqNum, Cmnt
		FROM #tmpVendorList t INNER JOIN dbo.tblApHistHeader AS h ON t.VendorId = h.VendorId AND t.PostRun = h.PostRun  AND t.TransId = h.TransId AND t.InvoiceNum = h.InvoiceNum
			INNER JOIN dbo.tblApHistLot AS l ON h.PostRun = l.PostRun AND h.TransId = l.TransId AND h.InvoiceNum = l.InvoiceNum AND t.EntryNum = l.EntryNum
		WHERE ( @PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency )
		
		-- Data for AP Vendor Activity HistorySer subreport
		SELECT  s.PostRun, s.TransId, s.InvoiceNum, s.EntryNum, SeqNum, LotNum, SerNum, ItemId, LocId, CostUnit, PriceUnit, CostUnitFgn, 
			PriceUnitFgn, HistSeqNum, Cmnt, CASE WHEN LotNum = ' ################' THEN NULL ELSE LotNum END AS vLotNum
		FROM #tmpVendorList t INNER JOIN dbo.tblApHistHeader AS h ON t.VendorId = h.VendorId AND t.PostRun = h.PostRun  AND t.TransId = h.TransId AND t.InvoiceNum = h.InvoiceNum
			INNER JOIN dbo.tblApHistSer AS s ON h.PostRun = s.PostRun AND h.TransId = s.TransId AND h.InvoiceNum = s.InvoiceNum  AND t.EntryNum = s.EntryNum
		WHERE ( @PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency )
		
	-- Vendor Activity subreport data
	SELECT c.VendorID, c.InvoiceNum, c.CheckNum, PmtType, c.CheckDate, c.CurrencyID,  
		CASE WHEN @PrintAllInBase=1 THEN GrossAmtDue ELSE GrossAmtDueFgn END GrossAmtDue,
		CASE WHEN @PrintAllInBase=1 THEN DiscTaken ELSE DiscTakenfgn END  DiscTaken,
		CASE WHEN @PrintAllInBase=1 THEN GrossAmtDue - DiscTaken ELSE GrossAmtDueFgn - DiscTakenFgn END NetPaid, 
		CASE WHEN @PrintAllInBase=1 THEN NetPaidCalc ELSE GrossAmtDueFgn - DiscTakenFgn END NetPaidCalc, 
	    CASE WHEN h.CurrencyId = @ReportCurrency THEN 0 
				ELSE CASE WHEN NetPaidCalc <> 0 THEN NetPaidCalc - (GrossAmtDue - DiscTaken) ELSE 0 END END  AS GainLoss	   
	FROM dbo.tblApCheckHist AS c 
	INNER JOIN 
		(SELECT DISTINCT t.VendorId, t.InvoiceNum, h.CurrencyId,h.InvoiceDate FROM #tmpVendorList t INNER JOIN dbo.tblApHistHeader h 
		 ON t.VendorID = h.VendorId AND t.PostRun = h.PostRun  AND t.TransId = h.TransId AND t.InvoiceNum = h.InvoiceNum 
		 WHERE ( @PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency )
		 ) h
	ON h.VendorId = c.VendorID AND h.InvoiceNum = c.InvoiceNum	AND h.InvoiceDate=c.InvoiceDate
	WHERE  c.PmtType <> 9 
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorActivity_proc';

