
CREATE PROCEDURE [dbo].[trav_PaCheckPost_BuildGlLog_proc]
AS
BEGIN TRY


	--PET:http://webfront:801/view.php?id=226504
	--PET:http://webfront:801/view.php?id=226651
	--PET:http://webfront:801/view.php?id=226643
	--PET:http://webfront:801/view.php?id=226466
	--PET:http://webfront:801/view.php?id=227220
	--PET;http://webfront:801/view.php?id=227418


	 DECLARE	 @Earnings smallint,  @Deductions  smallint,
	 @FED smallint, @State smallint, @Local smallint,
	 @PrecCurr smallint, @DateOnCheck Datetime, @PostYear smallint, 
	 @GlPeriod  smallint, @BankID nvarchar(10), @AdvPmtAcct nvarchar(40), @GlCashAcct nvarchar(40),
     @PostRun pPostRun, @WksDate datetime, @CurrBase pCurrency, @CompID nvarchar(30),@Accrual smallint,@AccruedWages smallint


    SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @GlCashAcct = Cast([Value] AS nvarchar(40)) FROM #GlobalValues WHERE [Key] = 'GlCashAcct'
	SELECT @AdvPmtAcct = Cast([Value] AS nvarchar(40)) FROM #GlobalValues WHERE [Key] = 'AdvPmtAcct'
    SELECT @BankID = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'BankID'
    SELECT @GlPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'GlPeriod' 
	SELECT @PostYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PostYear'
    SELECT @DateOnCheck = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DateOnCheck'
    SELECT @Earnings = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Earnings'
    SELECT @Deductions = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Deductions'
    SELECT @FED = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FED'
    SELECT @State = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'State'
    SELECT @Local = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Local'
    SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WksDate'
    SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
    SELECT @CompID = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'CompID'
	SELECT @Accrual = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Accrual'
	SELECT @AccruedWages = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'AccruedWages'

	IF  @Earnings IS NULL OR @BankID IS NULL Or @PostRun IS NULL Or @GlCashAcct Is Null Or @AdvPmtAcct Is null 
	OR @PostYear IS NULL OR @Accrual IS NULL OR @AccruedWages IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	
	IF(@Accrual = 1) -- via transaction
	BEGIN
		-- Accrued Wages  credit Amount
		INSERT INTO #PaCheckPostGlLog (Descr, GlAcct, Amount, Reference) 
		SELECT  MIN(SUBSTRING(d.[Description], 1, 30)),d.GLAcct,SUM(t.Amount)		
		,MIN(LEFT(d.DepartmentId + '-Unac', 15))
		FROM dbo.tblPaTransEarn t 
		INNER JOIN  dbo.tblPaCheckTrans ct on t.Id = ct.TransId AND ct.TransType = 0 
		INNER JOIN #PostTransList b ON  ct.CheckId = b.TransId 		
		INNER JOIN  dbo.tblPaEarnCode e ON t.EarningCode = e.Id 
		LEFT JOIN 
		(
			Select DepartmentId,Code,[Description],GLAcct 
			FROM dbo.tblPaDeptDtl 
			WHERE [Type] = @AccruedWages  AND Code = 'ACW'
		) d  ON t.DepartmentId = d.DepartmentId 
		WHERE t.Amount > 0	AND e.IncludeInNet <> 0
		GROUP BY  d.GLAcct,d.DepartmentId
		
		-- Accrued Wages  debit Amount
		INSERT INTO #PaCheckPostGlLog (Descr, GlAcct, Amount, Reference) 
		SELECT  MIN(SUBSTRING(d.[Description], 1, 30)),d.GLAcct,SUM(t.Amount)		
		,MIN(LEFT(d.DepartmentId + '-Unac', 15))
		FROM dbo.tblPaTransEarn t 
		INNER JOIN  dbo.tblPaCheckTrans ct on t.Id = ct.TransId AND ct.TransType = 0 
		INNER JOIN #PostTransList b ON  ct.CheckId = b.TransId 
		INNER JOIN  dbo.tblPaEarnCode e ON t.EarningCode = e.Id 
		LEFT JOIN 
		(
			Select DepartmentId,Code,[Description] ,GLAcct 
			FROM dbo.tblPaDeptDtl 
			WHERE [Type] = @AccruedWages  AND Code = 'ACW'
		) d  ON t.DepartmentId = d.DepartmentId 
		WHERE t.Amount < 0	AND e.IncludeInNet <> 0
		GROUP BY  d.GLAcct,d.DepartmentId
	

		--Wage/Salary Expense entries created by the Transaction Posting Credit amount
		INSERT INTO #PaCheckPostGlLog (Descr, GlAcct, Amount, Reference) 
		SELECT  SUBSTRING(d.[Description], 1, 30),d.GLAcct,-SUM(t.Amount),d.DepartmentId
		FROM dbo.tblPaTransEarn t 
		INNER JOIN  dbo.tblPaCheckTrans ct on t.Id = ct.TransId AND ct.TransType = 0 
		INNER JOIN #PostTransList b ON  ct.CheckId = b.TransId 
		INNER JOIN  dbo.tblPaEarnCode e ON t.EarningCode = e.Id 
		LEFT JOIN 
		(
			Select DepartmentId,Code,[Description] ,GLAcct 
			FROM dbo.tblPaDeptDtl 
			WHERE [Type] =@Earnings 
		) d  ON t.DepartmentId = d.DepartmentId  AND t.EarningCode = d.Code
		WHERE  t.Amount >0  AND e.IncludeInNet <> 0
		GROUP BY d.GLAcct,SUBSTRING(d.[Description], 1, 30),d.DepartmentId, t.PostRun


		--Wage/Salary Expense entries created by the Transaction Posting Debit amount
		INSERT INTO #PaCheckPostGlLog (Descr, GlAcct, Amount, Reference) 
		SELECT  SUBSTRING(d.[Description], 1, 30),d.GLAcct,-SUM(t.Amount),d.DepartmentId
		FROM dbo.tblPaTransEarn t 
		INNER JOIN  dbo.tblPaCheckTrans ct on t.Id = ct.TransId AND ct.TransType = 0 
		INNER JOIN #PostTransList b ON  ct.CheckId = b.TransId 
		INNER JOIN  dbo.tblPaEarnCode e ON t.EarningCode = e.Id 
		LEFT JOIN 
		(
			Select DepartmentId,Code,[Description] ,GLAcct
			FROM dbo.tblPaDeptDtl 
			WHERE [Type] =@Earnings
		) d  ON t.DepartmentId = d.DepartmentId AND t.EarningCode = d.Code
		WHERE  t.Amount < 0  AND e.IncludeInNet <> 0
		GROUP BY d.GLAcct,SUBSTRING(d.[Description], 1, 30),d.DepartmentId, t.PostRun

	END

	-- Check Earning department entries
	INSERT INTO #PaCheckPostGlLog (Descr, GlAcct, Amount, Reference) 
	SELECT SUBSTRING(d.[Description], 1, 30), d.GLAcct, SUM(c.EarningAmount), d.DepartmentId 	
	FROM dbo.tblPaDeptDtl d 
	INNER JOIN dbo.tblPaCheckEarn c ON d.DepartmentId = c.DepartmentId AND d.Code = c.EarningCode
	INNER JOIN #PostTransList b ON  c.CheckId = b.TransId 
	INNER JOIN dbo.tblPaEarnCode e ON c.EarningCode = e.Id 
	WHERE d.Type = @Earnings AND e.IncludeInNet <> 0   and c.EarningAmount <> 0
	GROUP BY d.[Description], d.GLAcct, c.EarningCode, d.TaxAuthorityId, d.DepartmentId


	-- Check deduct
	INSERT INTO #PaCheckPostGlLog (Descr, GlAcct, Amount, Reference) 
	SELECT d.[Description], d.GLLiabilityAccount,  -SUM(c.DeductionAmount), 'PA' 
	FROM dbo.tblPaCheckDeduct c 
	INNER JOIN #PostTransList b ON  c.CheckId = b.TransId 
	INNER JOIN dbo.tblPaDeductCode d ON c.DeductionCode = d.DeductionCode 
	WHERE d.EmployerPaid = 0  AND c.DeductionAmount <> 0
	GROUP BY d.[Description], d.GLLiabilityAccount, d.DeductionCode

	--Emplpoyee paid Fed tax authority
	INSERT INTO #PaCheckPostGlLog(Descr, GlAcct, Amount, Reference)
	SELECT d.[Description], d.GlLiabilityAccount, - sum(w.WithholdingPayments) WithholdingPayments, 'PA' 
	FROM dbo.tblPaTaxAuthorityDetail d
	INNER JOIN  dbo.tblPaTaxAuthorityHeader t ON t.Id = d.TaxAuthorityId
	INNER JOIN dbo.tblPaCheckWithhold w  ON d.Id = w.TaxAuthorityDtlId
	INNER JOIN dbo.tblPaCheck c  ON c.Id = w.CheckId 
	INNER JOIN #PostTransList b ON  c.Id = b.TransId
	WHERE d.EmployerPaid =0  AND t.Type = @FED AND d.Code  <> 'EIC' AND w.WithholdingPayments <> 0
	GROUP BY d.[Description], d.GlLiabilityAccount, d.Code

	-- Emplpoyee paid State tax authority
	INSERT INTO #PaCheckPostGlLog(Descr, GlAcct, Amount, Reference) 
	SELECT d.[Description], d.GlLiabilityAccount, - sum(w.WithholdingPayments) WithholdingPayments, 'PA' 
	FROM dbo.tblPaTaxAuthorityDetail d
	INNER JOIN  dbo.tblPaTaxAuthorityHeader t ON t.Id = d.TaxAuthorityId
	INNER JOIN dbo.tblPaCheckWithhold w  ON d.Id = w.TaxAuthorityDtlId
	INNER JOIN dbo.tblPaCheck c  ON c.Id = w.CheckId 
	INNER JOIN #PostTransList b ON  c.Id = b.TransId
	WHERE d.EmployerPaid = 0  AND t.Type = @State AND w.WithholdingPayments <> 0
	GROUP BY d.[Description], d.GlLiabilityAccount, d.Code 

	-- Emplpoyee paid Local tax authority
	INSERT INTO #PaCheckPostGlLog(Descr, GlAcct, Amount, Reference) 
	SELECT d.[Description], d.GlLiabilityAccount, - sum(w.WithholdingPayments) WithholdingPayments, 'PA' 
	FROM dbo.tblPaTaxAuthorityDetail d
	INNER JOIN  dbo.tblPaTaxAuthorityHeader t ON t.Id = d.TaxAuthorityId
	INNER JOIN dbo.tblPaCheckWithhold w  ON d.Id = w.TaxAuthorityDtlId
	INNER JOIN dbo.tblPaCheck c  ON c.Id = w.CheckId 
	INNER JOIN #PostTransList b ON  c.Id = b.TransId
	WHERE d.EmployerPaid = 0  AND t.Type = @Local AND w.WithholdingPayments <> 0
	GROUP BY d.[Description], d.GlLiabilityAccount, d.Code 
	
	-- Employer cost
	INSERT INTO #PaCheckPostGlLog (Descr, GlAcct, Amount, Reference) 
	SELECT d.[Description], d.GLLiabilityAccount,  -SUM(c.DeductionAmount), 'PA' 
	FROM dbo.tblPaCheckEmplrCost c 
	INNER JOIN #PostTransList b ON  c.CheckId = b.TransId 
	INNER JOIN dbo.tblPaDeductCode d ON c.DeductionCode = d.DeductionCode 
	WHERE d.EmployerPaid = 1  AND c.DeductionAmount <> 0
	GROUP BY d.[Description], d.GLLiabilityAccount, d.DeductionCode

	INSERT INTO #PaCheckPostGlLog(Descr, GlAcct, Amount, Reference)
	SELECT SUBSTRING(d.[Description], 1, 30), d.GLAcct, SUM(c.AllocCost), d.DepartmentId 	
	FROM dbo.tblPaDeptDtl d 
	INNER JOIN #tmpPaAllocCost c ON d.DepartmentId = c.DepartmentId AND d.Code = c.DeductionCode
	INNER JOIN #PostTransList b ON  c.CheckId = b.TransId 
	INNER JOIN dbo.tblPaDeductCode e ON c.DeductionCode = e.DeductionCode 
	WHERE d.Type = @Deductions  AND c.AllocCost <> 0 AND e.EmployerPaid = 1 
	GROUP BY d.[Description], d.GLAcct, c.DeductionCode, d.TaxAuthorityId, d.DepartmentId 

	--Employer paid Fed tax authority
	INSERT INTO #PaCheckPostGlLog(Descr, GlAcct, Amount, Reference)
	SELECT d.[Description], d.GlLiabilityAccount, - sum(w.WithholdingPayments) WithholdingPayments, 'PA' 
	FROM dbo.tblPaTaxAuthorityDetail d
	INNER JOIN dbo.tblPaTaxAuthorityHeader t ON t.Id = d.TaxAuthorityId
	INNER JOIN dbo.tblPaCheckEmplrTax w  ON d.Id = w.TaxAuthorityDtlId
	INNER JOIN dbo.tblPaCheck c  ON c.Id = w.CheckId 
	INNER JOIN #PostTransList b ON  c.Id = b.TransId
	WHERE d.EmployerPaid =1  AND t.Type = @FED AND w.WithholdingPayments <> 0
	GROUP BY d.[Description], d.GlLiabilityAccount, d.Code 
	
	----Employer paid State tax authority
	INSERT INTO #PaCheckPostGlLog(Descr, GlAcct, Amount, Reference) 
	SELECT d.[Description], d.GlLiabilityAccount, - sum(w.WithholdingPayments) WithholdingPayments, 'PA' 
	FROM dbo.tblPaTaxAuthorityDetail d
	INNER JOIN  dbo.tblPaTaxAuthorityHeader t ON t.Id = d.TaxAuthorityId
	INNER JOIN dbo.tblPaCheckEmplrTax w  ON d.Id = w.TaxAuthorityDtlId
	INNER JOIN dbo.tblPaCheck c  ON c.Id = w.CheckId 
	INNER JOIN #PostTransList b ON  c.Id = b.TransId
	WHERE d.EmployerPaid = 1  AND t.Type = @State AND w.WithholdingPayments <> 0
	GROUP BY d.[Description], d.GlLiabilityAccount, d.Code 
	
	--Employer paid local tax authority
	INSERT INTO #PaCheckPostGlLog(Descr, GlAcct, Amount, Reference) 
	SELECT d.[Description], d.GlLiabilityAccount, - sum(w.WithholdingPayments) WithholdingPayments, 'PA' 
	FROM dbo.tblPaTaxAuthorityDetail d
	INNER JOIN  dbo.tblPaTaxAuthorityHeader t ON t.Id = d.TaxAuthorityId
	INNER JOIN dbo.tblPaCheckEmplrTax w  ON d.Id = w.TaxAuthorityDtlId
	INNER JOIN dbo.tblPaCheck c  ON c.Id = w.CheckId 
	INNER JOIN #PostTransList b ON  c.Id = b.TransId
	WHERE d.EmployerPaid = 1  AND t.Type = @Local AND w.WithholdingPayments <> 0
	GROUP BY d.[Description], d.GlLiabilityAccount, d.Code 


	INSERT INTO #PaCheckPostGlLog (Descr, GlAcct, Amount, Reference) 
    SELECT SUBSTRING(tblPaDeptDtl.[Description], 1, 30), tblPaDeptDtl.GLAcct, sum(#tmpPaAllocTax.AllocTax), #tmpPaAllocTax.DepartmentId 
	FROM #tmpPaAllocTax 
    INNER JOIN dbo.tblPaTaxAuthorityHeader t ON #tmpPaAllocTax.TaxAuthorityId = t.Id
	INNER JOIN dbo.tblPaDeptDtl ON tblPaDeptDtl.TaxAuthorityId = #tmpPaAllocTax.TaxAuthorityId
		AND tblPaDeptDtl.Code = #tmpPaAllocTax.WithholdingCode 	AND tblPaDeptDtl.DepartmentId = #tmpPaAllocTax.DepartmentId
	GROUP BY tblPaDeptDtl.[Description], tblPaDeptDtl.GLAcct, #tmpPaAllocTax.DepartmentId
	
	-- Net cash entry
	INSERT INTO #PaCheckPostGlLog(Descr, GlAcct, Amount, Reference, RecType) 
	SELECT ch.Descr, ch.GlAcct, ch.Amount, ch.Reference, ch.RecType
	FROM 
	(
		SELECT 'Net Cash Entry' as descr, @GlCashAcct GlAcct, -SUM(c.NetPay) Amount, 'PA' as Reference, 1 as RecType
		FROM dbo.tblPaCheck c  
		INNER JOIN #PostTransList b ON c.Id = b.TransId
	) ch
	WHERE ch.Amount <> 0


	INSERT INTO #PaCheckPostGlLog(Descr, GlAcct, Amount, Reference)
	SELECT d.[Description], @AdvPmtAcct, -sum(w.WithholdingPayments) WithholdingPayments, 'PA' 
	FROM dbo.tblPaTaxAuthorityDetail d
	INNER JOIN  dbo.tblPaTaxAuthorityHeader t ON t.Id = d.TaxAuthorityId
	INNER JOIN  dbo.tblPaCheckWithhold w  ON d.Id = w.TaxAuthorityDtlId
	INNER JOIN dbo.tblPaCheck c  ON c.Id = w.CheckId 
	INNER JOIN #PostTransList b ON  c.Id = b.TransId
	WHERE d.EmployerPaid =0  AND t.Type = @FED AND d.Code  = 'EIC' AND w.WithholdingPayments <> 0
	GROUP BY d.[Description], d.GlLiabilityAccount, d.Code 


	UPDATE #PaCheckPostGlLog SET Amount = ROUND(CONVERT(Decimal(28,10), Amount), @PrecCurr)
	
	UPDATE #PaCheckPostGlLog SET [PaYear] = @PostYear, GlPeriod = @GLPeriod, CheckDate = @DateOnCheck, SourceCode = 'PA'
	, DR = CASE WHEN Amount > 0 THEN Amount ELSE 0 END
	, CR = CASE WHEN Amount < 0 THEN ABS(Amount) ELSE 0 END
	, BankId = @BankID 

	--Summarize credit/debit entries separately
	--Credit entry
	INSERT INTO #GlPostLogs(PostRun, FiscalYear, FiscalPeriod, [Grouping]
		, GlAccount, Reference, [Description], SourceCode
		, PostDate, TransDate, CurrencyId, ExchRate, CompId
		, AmountFgn, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn)
	SELECT @PostRun, PaYear, GlPeriod, 1
		, GlAcct, Reference, Descr, SourceCode
        , @WksDate, CheckDate, @CurrBase, 1,@CompID
		, CR, 0, CR, 0, CR		
	FROM #PaCheckPostGlLog 
	WHERE CR <> 0

	--Debit entry
	INSERT INTO #GlPostLogs(PostRun, FiscalYear, FiscalPeriod, [Grouping]
		, GlAccount, Reference, [Description], SourceCode
		, PostDate, TransDate, CurrencyId, ExchRate, CompId
		, AmountFgn, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn)
	SELECT @PostRun, PaYear, GlPeriod, 1
		, GlAcct, Reference, Descr, SourceCode
        , @WksDate, CheckDate, @CurrBase, 1,@CompID
		, DR, DR, 0, DR, 0	
	FROM #PaCheckPostGlLog 
	WHERE DR <> 0

	INSERT INTO #PaCheckBankLog(BankId, NetPay)
	SELECT  @BankId, (COALESCE(c.NetPay, 0)) SumNetPay   
	FROM dbo.tblPaCheck c 
    INNER JOIN #PostTransList b ON c.Id = b.TransId
    WHERE (COALESCE(c.NetPay, 0)) <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_BuildGlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_BuildGlLog_proc';

