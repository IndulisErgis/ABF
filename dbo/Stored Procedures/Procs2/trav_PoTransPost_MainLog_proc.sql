
CREATE PROCEDURE dbo.trav_PoTransPost_MainLog_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @PostRun nvarchar(14), @Multicurrency bit, 
		@CurrBase pCurrency,@InHsVendor pVendorId,@PoJcYn bit,@gPoPostDtlYn bit, @OutOfBalance bit,
		@PrecCurr tinyint,	@CompId nvarchar(3),@WksDate datetime

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PoJcYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PoJcYn'
	SELECT @Multicurrency = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	SELECT @InHsVendor = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'InHsVendor'
	SELECT @gPoPostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'

	IF @Multicurrency IS NULL OR @PoJcYn IS NULL 
		OR @gPoPostDtlYn IS NULL OR @PostRun IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL 
		OR @CompId IS NULL OR @WksDate IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	SET @InHsVendor = ISNULL(@InHsVendor,'')
	SET @OutOfBalance = 0

	INSERT INTO #PoTransPostVendorLog(FiscalYear, FiscalPeriod, VendorTableAmount, OpenInvoiceTableAmount, VendorTableAmountFgn, OpenInvoiceTableAmountFgn, CurrencyId) 
	SELECT t.FiscalYear, t.GLPeriod, SUM(SIGN(h.TransType) * (CurrTaxable + CurrNonTaxable + CurrSalesTax + CurrFreight + CurrMisc + CurrTaxAdjAmt)),
		SUM(SIGN(h.TransType) * (CurrPmtAmt1 + CurrPmtAmt2 + CurrPmtAmt3 + CurrPrepaid + CurrDisc)),
		SUM(SIGN(h.TransType) * (CurrTaxableFgn + CurrNonTaxableFgn + CurrSalesTaxFgn + CurrFreightFgn + CurrMiscFgn + CurrTaxAdjAmtFgn)),
		SUM(SIGN(h.TransType) * (CurrPmtAmt1Fgn + CurrPmtAmt2Fgn + CurrPmtAmt3Fgn + CurrPrepaidFgn + CurrDiscFgn)),
		h.CurrencyId	
	FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId 
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransID 
	WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND (t.CurrTaxablefgn != 0 OR t.CurrNonTaxablefgn != 0 OR t.CurrSalesTaxfgn != 0 OR  t.CurrFreightfgn != 0 OR  t.CurrMiscfgn != 0 OR  t.CurrTaxAdjAmtfgn != 0 OR t.CurrPrepaidFgn <> 0) 
	GROUP BY t.FiscalYear, t.GLPeriod, h.CurrencyId

	IF @gPoPostDtlYn = 0
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId)
		SELECT @PostRun, FiscalYear, GlPeriod, [Grouping], GlAcct, SUM(Amount), 'PO'
			, CASE Grouping 
				WHEN 10 THEN 'Line Item' 
				WHEN 101 THEN 'Sales Tax' 
				WHEN 102 THEN 'Freight' 
				WHEN 103 THEN 'Misc' 
				WHEN 104 THEN 'AP' 
				WHEN 105 THEN 'GOODS RCVD-IN Accrual' 
				WHEN 106 THEN 'GOODS RCVD-Exp Accrual' 
				WHEN 107 THEN 'GOODS RCVD-AP Accrual' 
				WHEN 108 THEN 'INV RCVD-IN Accrual' 
				WHEN 109 THEN 'INV RCVD-Exp Accrual' 
				WHEN 110 THEN 'INV RCVD-AP Accrual' 
				WHEN 111 THEN 'Landed Cost'
				WHEN 120 THEN 'INV COGS Adjustment' END
			, CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END
			, CASE WHEN SUM(Amount) < 0 THEN - SUM(Amount) ELSE 0 END 
			, CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END
			, CASE WHEN SUM(Amount) < 0 THEN - SUM(Amount) ELSE 0 END,
			'PO', @WksDate, @WksDate,@CurrBase, 1, @CompId 
		FROM #PoTransPostGlLog 
		WHERE Amount <> 0
		GROUP BY FiscalYear, GlPeriod, Grouping, GlAcct 
		ORDER BY FiscalYear, GlPeriod, Grouping
	END
	ELSE
	BEGIN	
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId, LinkID, LinkIDSub, LinkIDSubLine)
		SELECT @PostRun, FiscalYear, GlPeriod, [Grouping], GlAcct, CASE WHEN CurrencyId = @CurrBase THEN Amount ELSE Amountfgn END, Reference, Descr, 
			DR, CR, DebitAmtFgn, CreditAmtFgn,'PO', PostDate, TransDate,CurrencyId,ExchRate, @CompId , LinkID, LinkIDSub, LinkIDSubLine
		FROM #PoTransPostGlLog 
		WHERE Amount <> 0
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_MainLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_MainLog_proc';

