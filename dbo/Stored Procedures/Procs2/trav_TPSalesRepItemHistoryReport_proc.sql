
CREATE PROCEDURE [dbo].[trav_TPSalesRepItemHistoryReport_proc]
@CustId pCustID,
@SearchString nvarchar(100),
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD', --Base currency WHEN @PrintAllInBase = 1
@ReportUnit tinyint = 1, --0=Base/1=Selling
@IncludeTransactionType tinyint = 0, -- 0 = Transactions, 1 = Voids, 2 = Both
@FiscalPeriodFrom smallint = 0,
@FiscalPeriodThru smallint = 366,
@FiscalYearFrom smallint = 0,
@FiscalYearThru smallint = 9999,
@TransactionDateFrom datetime = '19000101',
@TransactionDateThru datetime = '21991231'

AS
SET NOCOUNT ON
BEGIN TRY

DECLARE @FiscalFrom int, @FiscalThru int
SELECT @FiscalFrom = (ISNULL(@FiscalYearFrom, 0) * 1000) + ISNULL(@FiscalPeriodFrom, 0)
	, @FiscalThru = (ISNULL(@FiscalYearThru, 0) * 1000) + ISNULL(@FiscalPeriodThru, 0)

SELECT  h.TransId
	, d.EntryNum
	, h.InvcDate AS InvoiceDate
	, h.InvcNum AS InvoiceNumber
	, d.PartId AS ItemId
	, d.[Desc] 
	, h.PostRun
	, h.[Source]
	, h.SourceId
	, h.PrintOption
	, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum < 0 THEN 0 ELSE CASE WHEN @PrintAllInBase = 1 THEN d.CostExt ELSE d.CostExtFgn END END, 0) AS Cost --line item
	, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum < 0 THEN 0 ELSE CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END END, 0) AS Sales --line item
	, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum = -1 THEN CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END ELSE 0 END, 0) AS SalesTax
	, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum = -2 THEN CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END ELSE 0 END, 0) AS Freight
	, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum = -3 THEN CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END ELSE 0 END, 0) AS Misc
	, CASE WHEN d.EntryNum < 0 THEN NULL ELSE CASE WHEN @ReportUnit = 0 THEN d.UnitsBase ELSE d.UnitsSell END END AS Units--line item
	, ISNULL(CASE WHEN d.EntryNum < 0 THEN 0 
		ELSE CASE WHEN @ReportUnit = 0 -- use order qty for credits / ship qty for invoices
			THEN CASE WHEN [TransType] < 0 
				THEN -(d.QtyOrdSell * d.ConversionFactor) 
				ELSE d.QtyShipBase 
				END
			ELSE CASE WHEN [TransType] < 0 
				THEN -d.QtyOrdSell 
				ELSE d.QtyShipSell 
				END	
			END
		END, 0) AS Quantity

FROM dbo.tblArHistHeader h 
LEFT JOIN dbo.tblArHistDetail d on h.PostRun = d.PostRun AND h.TransId = d.TransID 
WHERE 
	(d.PartId like '%' + @SearchString + '%'
	OR d.[Desc] like '%' + @SearchString + '%'
	OR h.InvcNum like '%' + @SearchString + '%')
	AND d.EntryNum > 0
	AND h.CustId = @CustId
	AND (@PrintAllInBase = 1 OR (@PrintAllInBase = 0 AND h.CurrencyID = @ReportCurrency))
	AND ((h.VoidYn = 0 AND @IncludeTransactionType = 0) OR (h.VoidYn = 1 AND @IncludeTransactionType = 1) OR (@IncludeTransactionType = 2)) --conditionally process voids --PET:http://webfront:801/view.php?id=230902
	AND d.[Status] = 0 --open line items
	AND d.[GrpId] IS NULL --exclude kit components
	AND (h.FiscalYear * 1000) + h.GLPeriod BETWEEN @FiscalFrom AND @FiscalThru
	AND h.InvcDate BETWEEN @TransactionDateFrom AND @TransactionDateThru
order by d.PartId, h.InvcNum
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TPSalesRepItemHistoryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TPSalesRepItemHistoryReport_proc';

