
CREATE PROCEDURE dbo.trav_ArCalcFinanceCharge_Calculate_proc
AS
--PET:http://webfront:801/view.php?id=225002
--PET:http://webfront:801/view.php?id=237636
--MOD:Finance Charge Enhancements
--PET:http://webfront:801/view.php?id=238956
--MOD:Deposit Invoices - Exclude proforma invoice(rectype=5)

SET NOCOUNT ON
BEGIN TRY
	DECLARE @ApplyCreditsToOldest bit, @FinchDate datetime
		, @FinchDays smallint, @FinchPct pDecimal, @FinchMin pDecimal
		, @PrecBaseCurr smallint
		, @AgeBy tinyint --0;TransDate;1;DueDate

	--Retrieve global values
	SELECT @ApplyCreditsToOldest = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ApplyCreditsToOldest'
	SELECT @FinchDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'FinchDate'
	SELECT @FinchDays = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FinchDays'
	SELECT @FinchPct = Cast([Value] AS decimal(28, 10)) FROM #GlobalValues WHERE [Key] = 'FinchPct'
	SELECT @FinchMin = Cast([Value] AS decimal(28, 10)) FROM #GlobalValues WHERE [Key] = 'FinchMin'
	SELECT @PrecBaseCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecBaseCurr'
	SELECT @AgeBy = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'AgeBy'
	
	--Assign default values
	SELECT @AgeBy = ISNULL(@AgeBy, 0) --use TransDate by default

	IF @ApplyCreditsToOldest IS NULL OR @FinchDate IS NULL 
		OR @FinchDays IS NULL OR @FinchPct IS NULL 
		OR @FinchMin IS NULL OR @PrecBaseCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--create a temp table for calculating the finance charges
	CREATE TABLE #CalcFinch 
	(
		[CustomerId] pCustID Not Null, 
		[CustomerName] nvarchar(255) Null,
		[AcctType] tinyint Null,
		[UnpaidFinch] pDecimal Not Null Default ((0)), 
		[Bal0] pDecimal Not Null Default ((0)), 
		[Bal1] pDecimal Not Null Default ((0)), 
		[Bal2] pDecimal Not Null Default ((0)), 
		[Bal3] pDecimal Not Null Default ((0)), 
		[Bal4] pDecimal Not Null Default ((0)), 
		[UnapplCredit] pDecimal Not Null Default ((0)), 
		[NonFinchAmt] pDecimal Not Null Default ((0)), 
		[FinchBase] pDecimal Not Null Default ((0)), 
		[CalcFinch] pDecimal Not Null Default ((0)), 
		[Credits] pDecimal Not Null Default ((0)),
		[CurrencyId] pCurrency
	)

	--open invoice temp table
	Create Table #InvoiceSummary
	(
		CustomerId pCustId,
		InvoiceNumber pInvoiceNum,
		FinChgCount int,
		AgingDate datetime,
		Amount pDecimal            
	)

	--capture balance forward customers
	INSERT INTO #CalcFinch (CustomerId, CustomerName, AcctType, UnpaidFinch
		, Bal0, Bal1, Bal2, Bal3, Bal4
		, UnapplCredit, NonFinchAmt, FinchBase, CalcFinch, Credits, CurrencyId) 
	SELECT c.CustId, c.CustName, c.AcctType, c.UnpaidFinch
		, c.CurAmtDue, c.BalAge1, c.BalAge2, c.BalAge3, c.BalAge4 
		, c.UnapplCredit, 0, 0, 0, -c.UnapplCredit, c.CurrencyId
	FROM dbo.tblArCust c 
	INNER JOIN #CustomerList l on c.CustId = l.CustomerId
	WHERE c.AcctType = 1 AND c.CalcFinch = 1 --balance forward customers


	--rollup the available unapplied credit for each customer
	UPDATE #CalcFinch 
		SET Credits = Credits + Bal0, Bal0 = 0 
		WHERE Bal0 < 0 

	UPDATE #CalcFinch 
		SET Credits = Credits + Bal1, Bal1 = 0 
		WHERE Bal1 < 0 

	UPDATE #CalcFinch 
		SET Credits = Credits + Bal2, Bal2 = 0 
		WHERE Bal2 < 0 

	UPDATE #CalcFinch 
		SET Credits = Credits + Bal3, Bal3 = 0 
		WHERE Bal3 < 0 

	UPDATE #CalcFinch 
		SET Credits = Credits + Bal4, Bal4 = 0 
		WHERE Bal4 < 0 

	--distribute the available credit 
	IF @ApplyCreditsToOldest = 1
	BEGIN
		UPDATE #CalcFinch 
			SET Bal4 = CASE WHEN Credits + Bal4 > 0 THEN Credits + Bal4 ELSE 0 END
				, Credits = Credits + Bal4 
			WHERE Credits < 0 

		UPDATE #CalcFinch 
			SET Bal3 = CASE WHEN Credits + Bal3 > 0 THEN Credits + Bal3 ELSE 0 END
				, Credits = Credits + Bal3 
			WHERE Credits < 0 

		UPDATE #CalcFinch 
			SET Bal2 = CASE WHEN Credits + Bal2 > 0 THEN Credits + Bal2 ELSE 0 END
				, Credits = Credits + Bal2 
			WHERE Credits < 0 

		UPDATE #CalcFinch 
			SET Bal1 = CASE WHEN Credits + Bal1 > 0 THEN Credits + Bal1 ELSE 0 END
				, Credits = Credits + Bal1 
			WHERE Credits < 0 

		UPDATE #CalcFinch 
			SET Bal0 = Credits + Bal0, Credits = 0 
			WHERE Credits < 0 
	END
	ELSE
	BEGIN
		UPDATE #CalcFinch 
			SET Bal0 = CASE WHEN Credits + Bal0 > 0 THEN Credits + Bal0 ELSE 0 END
				, Credits = Credits + Bal0 
			WHERE Credits < 0 

		UPDATE #CalcFinch 
			SET Bal1 = CASE WHEN Credits + Bal1 > 0 THEN Credits + Bal1 ELSE 0 END
				, Credits = Credits + Bal1 
			WHERE Credits < 0 

		UPDATE #CalcFinch 
			SET Bal2 = CASE WHEN Credits + Bal2 > 0 THEN Credits + Bal2 ELSE 0 END
				, Credits = Credits + Bal2 
			WHERE Credits < 0 

		UPDATE #CalcFinch 
			SET Bal3 = CASE WHEN Credits + Bal3 > 0 THEN Credits + Bal3 ELSE 0 END
				, Credits = Credits + Bal3 
			WHERE Credits < 0 

		UPDATE #CalcFinch 
			SET Bal4 = CASE WHEN Credits + Bal4 > 0 THEN Credits + Bal4 ELSE 0 END
				, Credits = Credits + Bal4 
			WHERE Credits < 0 

		--put remaining credits into current amount
		UPDATE #CalcFinch 
			SET Bal0 = Credits + Bal0, Credits = 0 
			WHERE Credits < 0 
	END
	

	--Calculate first aging bucket to determine finchbase and nonfinchamt values
	IF (@FinChDays < 30)
	Begin
		UPDATE #CalcFinch SET FinchBase = Bal0 + Bal1 + Bal2 + Bal3 + Bal4 
	End

	IF (@FinChDays >= 30 AND @FinChDays < 60)
	Begin
		UPDATE #CalcFinch SET NonFinchAmt = Bal0, FinchBase = Bal1 + Bal2 + Bal3 + Bal4 
	End

	IF (@FinChDays >= 60 AND @FinChDays < 90)
	Begin
		UPDATE #CalcFinch SET NonFinchAmt = Bal0 + Bal1, FinchBase = Bal2 + Bal3 + Bal4
	End

	IF (@FinChDays >= 90 AND @FinChDays < 120)
	Begin
		UPDATE #CalcFinch SET NonFinchAmt = Bal0 + Bal1 + Bal2, FinchBase = Bal3 + Bal4 
	End

	IF (@FinChDays >= 120)
	Begin
		UPDATE #CalcFinch SET NonFinchAmt = Bal0 + Bal1 + Bal2 + Bal3, FinchBase = Bal4 
	End


	--capture summarized invoice amounts for open invoice customers
	--	use the earliest date for the finance charge aging
	--  count any finance charge entries to identify finance change invoice numbers 
	--	(count of finance chage invoices enables exclusion of invoices and payments for finance charges)
	INSERT INTO #InvoiceSummary (CustomerId, InvoiceNumber, FinChgCount, AgingDate, Amount)
	SELECT i.CustId, i.InvcNum
		, SUM(CASE WHEN i.RecType = 4 THEN 1 ELSE 0 END)
		, MIN(CASE WHEN i.RecType < 0 THEN @FinchDate ELSE CASE WHEN @AgeBy = 1 THEN ISNULL(i.NetDueDate, i.TransDate) ELSE i.TransDate END END)
		, Sum(Case When i.RecType < 0 Then -i.AmtFgn Else i.AmtFgn End) 
	FROM dbo.tblArCust c
	INNER JOIN dbo.tblArOpenInvoice i
		ON c.CustId = i.CustId AND i.RecType<>5   
	INNER JOIN #CustomerList l
		ON c.CustId = l.CustomerId
	WHERE i.[Status] = 0 AND c.CalcFinch = 1 AND c.AcctType = 0 --open invoice customers
	GROUP BY i.CustId, i.InvcNum   


	--Append finance charge amounts for open invoice customers
	INSERT INTO #CalcFinch (CustomerId, CustomerName, AcctType, UnpaidFinch, FinchBase, NonFinchAmt, CurrencyId) 
	SELECT c.CustId, c.CustName, c.AcctType, c.UnpaidFinch
		, Sum(CASE WHEN s.AgingDate < @FinchDate AND s.FinChgCount = 0 THEN s.Amount ELSE 0 END)
		, Sum(CASE WHEN s.AgingDate >= @FinchDate AND s.FinChgCount = 0 THEN s.Amount ELSE 0 END) 
		, c.CurrencyId
	FROM dbo.tblArCust c
	INNER JOIN #InvoiceSummary s
		ON c.CustId = s.CustomerId
	GROUP BY c.CustId, c.CustName, c.AcctType, c.UnpaidFinch, c.CurrencyId


	--check for negative values in finch base and non finch amt in main temp table
	UPDATE #CalcFinch
		SET FinchBase = 0, NonFinchAmt = FinchBase + NonFinchAmt
		WHERE Bal0 < 0 


	--calculate finance charge (Round to customer currency precision)
	UPDATE #CalcFinch 
		SET CalcFinch = CASE WHEN Round(FinchBase * (@FinchPct / 100), ISNULL(ci.[Prec], @PrecBaseCurr)) > @FinchMin 
			THEN Round(FinchBase * (@FinchPct / 100), ISNULL(ci.[Prec], @PrecBaseCurr)) 
			ELSE Round(@FinchMin, ISNULL(ci.[Prec], @PrecBaseCurr))
			END 
	FROM #CalcFinch
	LEFT JOIN #CurrencyInfo ci on #CalcFinch.CurrencyId = ci.CurrencyId
	WHERE Round(#CalcFinch.FinchBase, ISNULL(ci.[Prec], @PrecBaseCurr)) > 0 


	--Update tblArCust table NewFinch field with the calcfinch amount
	UPDATE dbo.tblArCust
		SET NewFinch = t.CalcFinch 
		FROM dbo.tblArCust 
		INNER JOIN #CalcFinch t 
			ON dbo.tblArCust.CustId = t.CustomerId


	--populate the log table
	INSERT INTO #CalcFinchLog(CustomerId, CustomerName, AccountType
		, UnpaidFinch, NonFinchAmt, FinchBase, CalcFinch, CurrencyId)
	SELECT CustomerId, CustomerName, AcctType
		, UnpaidFinch, NonFinchAmt, FinchBase, CalcFinch, CurrencyId
	FROM #CalcFinch 


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCalcFinanceCharge_Calculate_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCalcFinanceCharge_Calculate_proc';

