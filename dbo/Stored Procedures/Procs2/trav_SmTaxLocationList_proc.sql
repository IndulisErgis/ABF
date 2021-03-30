
CREATE PROCEDURE [dbo].[trav_SmTaxLocationList_proc]
@DateFrom datetime = '19000101' ,
@DateThru datetime = '99990101',
@OptDate tinyint = 0,
@FiscalYear smallint = 2009,
@FiscalPeriod smallint = 1,
@IncludeTaxAuth bit = 1

AS
--PET:http://webfront:801/view.php?id=239645

SET NOCOUNT ON
BEGIN TRY

	IF @IncludeTaxAuth  = 1
	BEGIN
		SELECT l.[Name], l.TaxLevel, l.TaxAuthority, l.TaxId, ABS(l.TaxOnFreight) TaxOnFreight, ABS(l.TaxOnMisc) TaxOnMisc, l.GLAcct, l.TaxRefAcct, 
		d.ExpenseAcct, d.TaxLocID, d.taxClassCode, d.SalesTaxPct, d.PurchTaxPct, d.RefundPct,
		SUM(COALESCE(TT.TaxSales, 0)) TaxSales, SUM(COALESCE(TT.NonTaxSales, 0)) NonTaxSales, SUM(COALESCE(TT.TaxCollect, 0)) TaxCollect, 
		SUM(COALESCE(TT.TaxPurch, 0)) TaxPurch, SUM(COALESCE(TT.NonTaxPurch, 0)) NonTaxPurch, SUM(COALESCE(TT.TaxPaid, 0)) TaxPaid, 
		SUM(COALESCE(TT.TaxRefund, 0)) TaxRefund, SUM(COALESCE(TT.TaxSales, 0)) contax, SUM(COALESCE(TT.taxsales, 0)) ftax 
		FROM dbo.tblSmTaxLoc l INNER JOIN dbo.tblSmTaxLocDetail d ON l.TaxLocId = d.TaxLocId
		INNER JOIN #tmpTaxLoc tmp ON l.TaxLocId = tmp.TaxLocId
		LEFT JOIN 
		(SELECT t.TaxLocId, t.TaxClassCode, l.TaxAuthority, SUM(COALESCE(t.TaxSales, 0)) TaxSales, 
		SUM(COALESCE(t.NonTaxSales, 0)) NonTaxSales, SUM(COALESCE(t.TaxCollect, 0)) TaxCollect, 
		SUM(COALESCE(t.TaxPurch, 0)) TaxPurch, SUM(COALESCE(t.NonTaxPurch, 0)) NonTaxPurch, 
		SUM(COALESCE(t.TaxPaid, 0)) TaxPaid, SUM(COALESCE(t.TaxRefund, 0)) TaxRefund,  
		SUM(COALESCE(t.TaxSales, 0)) contax, SUM(COALESCE(t.taxsales, 0)) ftax 
		FROM dbo.tblSmTaxLoc l INNER JOIN dbo.tblSmTaxLocTrans T ON l.TaxLocId = t.TaxLocId

		WHERE ((t.TransDate BETWEEN @DateFrom AND @DateThru AND @OptDate = 0) OR @OptDate = 1 )
		AND ((t.GLPeriod = @FiscalPeriod AND t.FiscalYear = @FiscalYear AND @OptDate = 1 )OR @OptDate = 0)
		GROUP BY t.TaxLocID, t.taxClassCode, l.TaxAuthority
		) TT
		ON d.TaxClassCode = TT.TaxClassCode AND d.TaxLocID =  TT.TaxLocID 
		GROUP BY d.TaxLocID, d.taxClassCode, l.[Name], l.TaxLevel, l.TaxAuthority, l.TaxId, ABS(l.TaxOnFreight), 
		   ABS(l.TaxOnMisc), l.GLAcct, l.TaxRefAcct, d.ExpenseAcct,  d.SalesTaxPct, d.PurchTaxPct, d.RefundPct
		ORDER BY  d.TaxLocID, d.taxClassCode
	END 

	ELSE

	BEGIN
		SELECT l.[Name], l.TaxLevel, l.TaxAuthority, l.TaxId, ABS(l.TaxOnFreight) TaxOnFreight, ABS(l.TaxOnMisc) TaxOnMisc, l.GLAcct, l.TaxRefAcct, 
		d.ExpenseAcct, d.TaxLocID, d.taxClassCode, d.SalesTaxPct, d.PurchTaxPct, d.RefundPct,
		SUM(COALESCE(TT.TaxSales, 0)) TaxSales, SUM(COALESCE(TT.NonTaxSales, 0)) NonTaxSales, SUM(COALESCE(TT.TaxCollect, 0)) TaxCollect, 
		SUM(COALESCE(TT.TaxPurch, 0)) TaxPurch, SUM(COALESCE(TT.NonTaxPurch, 0)) NonTaxPurch, SUM(COALESCE(TT.TaxPaid, 0)) TaxPaid, 
		SUM(COALESCE(TT.TaxRefund, 0)) TaxRefund, SUM(COALESCE(TT.TaxSales, 0)) contax, 
		SUM(COALESCE(TT.taxsales, 0)) ftax 
		FROM dbo.tblSmTaxLoc l INNER JOIN dbo.tblSmTaxLocDetail d ON l.TaxLocId = d.TaxLocId
		INNER JOIN #tmpTaxLoc tmp ON l.TaxLocId = tmp.TaxLocId
		INNER JOIN 
		(SELECT t.TaxLocId, t.TaxClassCode, l.TaxAuthority, SUM(COALESCE(t.TaxSales, 0)) TaxSales, 
		SUM(COALESCE(t.NonTaxSales, 0)) NonTaxSales, SUM(COALESCE(t.TaxCollect, 0)) TaxCollect, 
		SUM(COALESCE(t.TaxPurch, 0)) TaxPurch, SUM(COALESCE(t.NonTaxPurch, 0)) NonTaxPurch, 
		SUM(COALESCE(t.TaxPaid, 0)) TaxPaid, SUM(COALESCE(t.TaxRefund, 0)) TaxRefund,  
		SUM(COALESCE(t.TaxSales, 0)) contax, SUM(COALESCE(t.taxsales, 0)) ftax 
		FROM dbo.tblSmTaxLoc l INNER JOIN dbo.tblSmTaxLocTrans T ON l.TaxLocId = t.TaxLocId
		WHERE ((t.TransDate BETWEEN @DateFrom AND @DateThru AND @OptDate = 0) or @OptDate = 1 )
		AND ((t.GLPeriod = @FiscalPeriod AND t.FiscalYear = @FiscalYear AND @OptDate = 1 )OR @OptDate = 0)
		GROUP BY t.TaxLocID, t.taxClassCode, l.TaxAuthority
		) TT
		ON d.TaxClassCode = TT.TaxClassCode AND d.TaxLocID =  TT.TaxLocID 
		GROUP BY d.TaxLocID, d.taxClassCode, l.[Name], l.TaxLevel, l.TaxAuthority, l.TaxId, ABS(l.TaxOnFreight), 
		   ABS(l.TaxOnMisc), l.GLAcct, l.TaxRefAcct, d.ExpenseAcct, d.SalesTaxPct, d.PurchTaxPct, d.RefundPct
		ORDER BY  d.TaxLocID, d.taxClassCode
	END

	SELECT t.TaxLocId, t.TaxClassCode, t.TransDate, CONVERT(nvarchar(8), t.TransDate , 112) AS TransDateSort
		, t.GLPeriod, t.FiscalYear, t.SourceCode, t.LinkID
		, ISNULL(t.TaxSales, 0) TaxSales, ISNULL(t.NonTaxSales, 0) NonTaxSales
		, ISNULL(t.TaxCollect, 0) TaxCollect, ISNULL(t.TaxPurch, 0) TaxPurch
		, ISNULL(t.NonTaxPurch, 0) NonTaxPurch, ISNULL(t.TaxPaid, 0) TaxPaid
		, ISNULL(t.TaxRefund, 0) TaxRefund 
	FROM #tmpTaxLoc tmp 
		INNER JOIN dbo.tblSmTaxLocTrans t ON tmp.TaxLocId = t.TaxLocId 
	WHERE ((t.TransDate BETWEEN @DateFrom AND @DateThru AND @OptDate = 0) OR @OptDate = 1) 
		AND ((t.GLPeriod = @FiscalPeriod AND t.FiscalYear = @FiscalYear AND @OptDate = 1) OR @OptDate = 0)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmTaxLocationList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmTaxLocationList_proc';

