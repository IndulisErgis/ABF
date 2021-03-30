
CREATE PROCEDURE [dbo].[trav_ArSalesAnalysisReport_proc]

@CurrYr smallint,
@Period smallint,
@PeriodPerYear smallint

AS
SET NOCOUNT ON
BEGIN TRY

	--use temp table for header totals
	CREATE TABLE #cyly 
	(
		CYPTDSales pDecimal default 0, CYPTDCOGS pDecimal default 0, CYPTDGrossProfit pDecimal default 0, CYPTDNumInvc int default 0, CYPTDAvgInvoice pDecimal default 0,
		CYQTDSales pDecimal default 0, CYQTDCOGS pDecimal default 0, CYQTDGrossProfit pDecimal default 0, CYQTDNumInvc int default 0, CYQTDAvgInvoice pDecimal default 0,
		CYYTDSales pDecimal default 0, CYYTDCOGS pDecimal default 0, CYYTDGrossProfit pDecimal default 0, CYYTDNumInvc int default 0, CYYTDAvgInvoice pDecimal default 0,

		LYPTDSales pDecimal default 0, LYPTDCOGS pDecimal default 0, LYPTDGrossProfit pDecimal default 0, LYPTDNumInvc int default 0, LYPTDAvgInvoice pDecimal default 0,
		LYQTDSales pDecimal default 0, LYQTDCOGS pDecimal default 0, LYQTDGrossProfit pDecimal default 0, LYQTDNumInvc int default 0, LYQTDAvgInvoice pDecimal default 0,
		LYYTDSales pDecimal default 0, LYYTDCOGS pDecimal default 0, LYYTDGrossProfit pDecimal default 0, LYYTDNumInvc int default 0, LYYTDAvgInvoice pDecimal default 0
	)
	--create initial total record
	Insert into #cyly (
			  CYPTDSales, CYPTDCOGS, CYPTDGrossProfit, CYPTDNumInvc, CYPTDAvgInvoice
			, CYQTDSales, CYQTDCOGS, CYQTDGrossProfit, CYQTDNumInvc, CYQTDAvgInvoice
			, CYYTDSales, CYYTDCOGS, CYYTDGrossProfit, CYYTDNumInvc, CYYTDAvgInvoice
			, LYPTDSales, LYPTDCOGS, LYPTDGrossProfit, LYPTDNumInvc, LYPTDAvgInvoice
			, LYQTDSales, LYQTDCOGS, LYQTDGrossProfit, LYQTDNumInvc, LYQTDAvgInvoice
			, LYYTDSales, LYYTDCOGS, LYYTDGrossProfit, LYYTDNumInvc, LYYTDAvgInvoice)
	Values (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

	--get periods for qtr of current period
	DECLARE @qtr smallint
	DECLARE @PeriodFrom smallint, @PeriodThru smallint

	DECLARE @qpd smallint

	SET @qpd = @PeriodPerYear / 4

	SELECT @qtr=qtr FROM
	( SELECT CASE WHEN glperiod <= @qpd THEN 1 WHEN glperiod <= (@qpd * 2) THEN 2 WHEN glperiod <= (@qpd * 3) THEN 3 
		 WHEN glperiod <= (@qpd * 4) THEN 4 ELSE 0 END qtr, glperiod 
	  FROM dbo.tblsmperiodconversion WHERE glyear = @CurrYr ) q
	  WHERE glperiod = @Period

	SELECT @PeriodFrom = MIN(glperiod), @PeriodThru = MAX(glperiod) FROM
	( SELECT CASE WHEN glperiod <= @qpd THEN 1 WHEN glperiod <= (@qpd * 2) THEN 2 WHEN glperiod <= (@qpd * 3) THEN 3
			WHEN glperiod <= (@qpd * 4) THEN 4 ELSE 0 END qtr, glperiod 
	  FROM dbo.tblsmperiodconversion WHERE glyear = @CurrYr) q
	  WHERE qtr = @qtr

	--select @qpd,@qtr,@pdfrom,@pdthru
	SET @PeriodThru = CASE WHEN @PeriodThru > @Period THEN @Period ELSE @PeriodThru END

	--EXEC dbo.trav_GetQTR_proc @CurrYr, @Period, @PeriodPerYear, @qtr OUT, @PeriodFrom OUT, @PeriodThru OUT

	--Update current year values
		--Current period
		UPDATE #cyly SET 		
			CYPTDSales = ISNULL(histHdr.TotSales, 0), 
			CYPTDCOGS = ISNULL(histHdr.TotCogs, 0),
			CYPTDGrossProfit = ISNULL(histHdr.TotSales, 0) - ISNULL(histHdr.TotCogs, 0), 
			CYPTDNumInvc = ISNULL(histHdr.NumInvc, 0), 
			CYPTDAvgInvoice = ISNULL(CASE WHEN histHdr.NumInvc <> 0 THEN histHdr.TotSales / histHdr.NumInvc ELSE 0 END, 0)			
		FROM ( SELECT 
				SUM(SIGN(TransType) * (ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0))) TotSales,
				SUM(SIGN(TransType) * ISNULL(TotCost, 0)) TotCogs, 
				SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) NumInvc 
				FROM dbo.tblArHistHeader 
				WHERE FiscalYear = @CurrYr AND GlPeriod = @Period  AND VoidYn = 0) histHdr

		--qtr to date
		UPDATE #cyly SET CYQTDSales = ISNULL(upd.TotSales, 0), CYQTDCOGS = ISNULL(upd.TotCogs, 0),
			CYQTDGrossProfit = ISNULL(upd.TotSales, 0) - ISNULL(upd.TotCogs, 0), CYQTDNumInvc = ISNULL(upd.NumInvc, 0), 
			CYQTDAvgInvoice = ISNULL(CASE WHEN upd.NumInvc <> 0 THEN upd.TotSales / upd.NumInvc ELSE 0 END, 0)
		FROM (SELECT SUM(SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal)) TotSales
			, SUM(SIGN(TransType)* TotCost) TotCogs, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) NumInvc 
			  FROM dbo.tblArHistHeader 
			  WHERE FiscalYear = @CurrYr AND GlPeriod BETWEEN @PeriodFrom AND @PeriodThru AND VoidYn = 0) upd
			
		--year to date
		UPDATE #cyly SET CYYTDSales = ISNULL(upd.TotSales, 0), CYYTDCOGS = ISNULL(upd.TotCogs, 0),
			CYYTDGrossProfit = ISNULL(upd.TotSales, 0) - ISNULL(upd.TotCogs, 0), CYYTDNumInvc = ISNULL(upd.NumInvc, 0), 
			CYYTDAvgInvoice = ISNULL(CASE WHEN upd.NumInvc <> 0 THEN upd.TotSales / upd.NumInvc ELSE 0 END, 0)
		FROM (SELECT SUM(SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal)) TotSales
			, SUM(SIGN(TransType) * TotCost) TotCogs, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) NumInvc 
			FROM dbo.tblArHistHeader WHERE FiscalYear = @CurrYr AND GlPeriod <= @Period AND VoidYn = 0) upd

	--update last year values
		--last year pd
		UPDATE #cyly SET LYPTDSales = ISNULL(upd.TotSales, 0), LYPTDCOGS = ISNULL(upd.TotCogs, 0),
			LYPTDGrossProfit = ISNULL(upd.TotSales, 0) - ISNULL(upd.TotCogs, 0), LYPTDNumInvc = ISNULL(upd.NumInvc, 0), 
			LYPTDAvgInvoice = ISNULL(CASE WHEN upd.NumInvc <> 0 THEN upd.TotSales / upd.NumInvc ELSE 0 END, 0)
		FROM (SELECT SUM(SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal)) TotSales
			, SUM(SIGN(TransType) * TotCost) TotCogs, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) NumInvc 
			FROM dbo.tblArHistHeader WHERE FiscalYear = @CurrYr - 1 AND GlPeriod = @Period AND VoidYn = 0) upd
	
		--last year qtr to date
		UPDATE #cyly Set LYQTDSales = ISNULL(upd.TotSales, 0), LYQTDCOGS = ISNULL(upd.TotCogs, 0),
			LYQTDGrossProfit = ISNULL(upd.TotSales, 0) - ISNULL(upd.TotCogs, 0), LYQTDNumInvc = ISNULL(upd.NumInvc, 0), 
			LYQTDAvgInvoice = ISNULL(CASE WHEN upd.NumInvc <> 0 THEN upd.TotSales / upd.NumInvc ELSE 0 END,0)
		FROM (SELECT SUM(SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal)) TotSales
			, SUM(SIGN(TransType) * TotCost) TotCogs, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) NumInvc 
			FROM dbo.tblArHistHeader WHERE FiscalYear = @CurrYr - 1 AND GlPeriod BETWEEN @PeriodFrom AND @PeriodThru
			 AND VoidYn = 0) upd

		--last year year to date
		UPDATE #cyly SET LYYTDSales = ISNULL(upd.TotSales, 0), LYYTDCOGS = ISNULL(upd.TotCogs, 0),
			LYYTDGrossProfit = ISNULL(upd.TotSales, 0) - ISNULL(upd.TotCogs, 0), LYYTDNumInvc = ISNULL(upd.NumInvc, 0), 
			LYYTDAvgInvoice = ISNULL(CASE WHEN upd.NumInvc <> 0 THEN upd.TotSales / upd.NumInvc ELSE 0 END, 0)
		FROM (SELECT SUM(SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal)) TotSales
			, SUM(SIGN(TransType) * TotCost) TotCogs, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) NumInvc 
			FROM dbo.tblArHistHeader WHERE FiscalYear = @CurrYr - 1 AND GlPeriod <= @Period
			 AND VoidYn = 0) upd
			
	--period trend
	CREATE TABLE #dtl 
	(
		[Year] smallint, 
		Period smallint, 
		TotSales float, 
		TotCOGS float, 
		NumInvc int, 
		AvgInvoice float 
	)

	INSERT INTO #dtl 
		SELECT glyear, glperiod, 0, 0, 0, 0 FROM 
			( SELECT * FROM dbo.tblSmPeriodConversion )AS s
			  WHERE  glyear * 1000 + glperiod <= @CurrYr * 1000 + @Period AND glyear * 1000 + glperiod >= @CurrYr * 1000 + @Period - 1000 
					AND glperiod <= @PeriodPerYear

	UPDATE #dtl SET TotSales = t.TotSales, TotCOGS = t.TotCogs, NumInvc = t.NumInvc,
		AvgInvoice = CASE WHEN t.NumInvc <> 0 THEN t.TotSales / t.NumInvc ELSE 0 END
	FROM ( SELECT  fiscalyear, glperiod, SUM(SIGN(TransType) * (TaxSubtotal+NonTaxSubtotal)) TotSales,
				SUM(SIGN(TransType) * TotCost) TotCogs, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) NumInvc 
			FROM dbo.tblArHistHeader
			WHERE fiscalyear BETWEEN @CurrYr - 1 AND @CurrYr  AND VoidYn = 0
			GROUP BY fiscalYear, glperiod ) t INNER JOIN #dtl ON t.fiscalyear = #dtl.[Year] AND t.GlPeriod = #dtl.Period

	SELECT #cyly.*, #dtl.* FROM #cyly, #dtl
		ORDER BY #dtl.[Year] DESC, #dtl.Period DESC		
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArSalesAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArSalesAnalysisReport_proc';

