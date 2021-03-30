
CREATE PROCEDURE dbo.trav_ArAgeCustomer_proc
AS
Set NoCount ON
BEGIN TRY
	--PET:http://webfront:801/view.php?id=236015
	--MOD:Finance Charge Enhancements

	--Customer selection based upon contents of the #CustomerList table
	--	CREATE TABLE #CustomerList (CustID pCustId)
	-- PET: http://webfront:801/view.php?id=239623
	-- Exclude proforma invoice

	DECLARE @Age1 datetime, @Age2 datetime, @Age3 datetime, @Age4 datetime
	DECLARE @WrkStnDate datetime, @ApplyCreditsToOldest bit
	DECLARE @BFRollBalances bit

	--Retrieve global values
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @ApplyCreditsToOldest = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ApplyCreditsToOldest'
	SELECT @BFRollBalances = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'BFRollBalances'

	IF @WrkStnDate IS NULL SET @WrkStnDate = GETDATE()
	IF @BFRollBalances IS NULL SET @BFRollBalances = 0 --option to roll balance forward balances

	IF @ApplyCreditsToOldest IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--list of balance forward customers to update
	CREATE TABLE #AgeBFCust
	(
		CustId pCustId, 
		CurAmtDue pDecimal, 
		BalAge1 pDecimal, 
		BalAge2 pDecimal, 
		BalAge3 pDecimal, 
		BalAge4 pDecimal, 
		UnpaidFinch pDecimal, 
		Credits pDecimal
	)

	--list of open invoice customers to update
	CREATE TABLE #AgeOICust
	(
		CustId pCustId, 
		CurAmtDue pDecimal, 
		BalAge1 pDecimal, 
		BalAge2 pDecimal, 
		BalAge3 pDecimal, 
		BalAge4 pDecimal, 
		UnpaidFinch pDecimal, 
		Credits pDecimal
	)

	--temporary invoice information for aging
	CREATE TABLE #AgeInvoices
	(
		CustId pCustId, 
		InvcNum pInvoiceNum, 
		FirstOfTransDate datetime, 
		Amount pDecimal, 
		MaxOfRecType smallint
	)

	--=================================
	--Update Balance forward customers
	--=================================

	--capture the list of Balance forward customers to process
	--	conditionally roll the balances (generally done as a periodic process)
	IF @BFRollBalances = 1
		INSERT INTO #AgeBFCust (CustId, CurAmtDue, BalAge1, BalAge2, BalAge3, BalAge4, UnpaidFinch, Credits) 
			SELECT c.CustId, 0, CurAmtDue, BalAge1, BalAge2, BalAge3 + BalAge4, UnpaidFinch, -UnapplCredit 
			FROM dbo.tblArCust c INNER JOIN #CustomerList ON c.CustId = #CustomerList.CustId 
			WHERE c.AcctType = 1
	ELSE --do not roll balances
		INSERT INTO #AgeBFCust (CustId, CurAmtDue, BalAge1, BalAge2, BalAge3, BalAge4, UnpaidFinch, Credits) 
			SELECT c.CustId, CurAmtDue, BalAge1, BalAge2, BalAge3, BalAge4, UnpaidFinch, -UnapplCredit 
			FROM dbo.tblArCust c INNER JOIN #CustomerList ON c.CustId = #CustomerList.CustId 
			WHERE c.AcctType = 1

	UPDATE #AgeBFCust 
		SET Credits = Credits + CurAmtDue,  CurAmtDue = 0 
	WHERE CurAmtDue < 0

	UPDATE #AgeBFCust 
		SET Credits = Credits + BalAge1, BalAge1 = 0 
	WHERE BalAge1 < 0

	UPDATE #AgeBFCust 
		SET Credits = Credits + BalAge2,  BalAge2 = 0 
	WHERE BalAge2 < 0

	UPDATE #AgeBFCust 
		SET Credits = Credits + BalAge3,  BalAge3 = 0 
	WHERE BalAge3 < 0

	UPDATE #AgeBFCust 
		SET Credits = Credits + BalAge4, BalAge4 = 0 
	WHERE BalAge4 < 0

	UPDATE #AgeBFCust 
		SET Credits = UnpaidFinch + Credits,  UnpaidFinch = 0 
	WHERE UnpaidFinch < 0

	--distribute credits 
	IF @ApplyCreditsToOldest = 1
	BEGIN
		UPDATE #AgeBFCust 
			SET UnpaidFinch = UnpaidFinch + Credits, Credits = UnpaidFinch + Credits 
		WHERE Credits < 0

		UPDATE #AgeBFCust 
			SET BalAge4 = BalAge4 + Credits, Credits = BalAge4 + Credits 
		WHERE Credits < 0
	 
		UPDATE #AgeBFCust 
			SET BalAge3 = BalAge3 + Credits, Credits = BalAge3 + Credits 
		WHERE Credits < 0
	 
		UPDATE #AgeBFCust 
			SET BalAge2 = BalAge2 + Credits, Credits = BalAge2 + Credits 
		WHERE Credits < 0
	 
		UPDATE #AgeBFCust 
			SET BalAge1 = BalAge1 + Credits, Credits = BalAge1 + Credits 
		WHERE Credits < 0
	 
		UPDATE #AgeBFCust 
			SET CurAmtDue = CurAmtDue + Credits, Credits = CurAmtDue + Credits 
		WHERE Credits < 0
	END
	ELSE   --DO NOT APPLY TO OLDEST FIRST
	BEGIN
		UPDATE #AgeBFCust 
			SET CurAmtDue = CurAmtDue + Credits, Credits = CurAmtDue + Credits 
		WHERE Credits < 0 AND CurAmtDue > 0

		UPDATE #AgeBFCust 
			SET BalAge1 = BalAge1 + Credits, Credits = BalAge1 + Credits 
		WHERE Credits < 0
	 
		UPDATE #AgeBFCust 
			SET BalAge2 = BalAge2 + Credits, Credits = BalAge2 + Credits 
		WHERE Credits < 0

		UPDATE #AgeBFCust 
			SET BalAge3 = BalAge3 + Credits, Credits = BalAge3 + Credits 
		WHERE Credits < 0
	 
		UPDATE #AgeBFCust 
			SET BalAge4 = BalAge4 + Credits, Credits = BalAge4 + Credits 
		WHERE Credits < 0
	 
		UPDATE #AgeBFCust 
			SET UnpaidFinch = UnpaidFinch + Credits, Credits = UnpaidFinch + Credits 
		WHERE Credits < 0

		-- put remaining credits into curamt 
		UPDATE #AgeBFCust 
			SET CurAmtDue = CurAmtDue + Credits, Credits = CurAmtDue + Credits 
		WHERE Credits < 0 AND CurAmtDue > 0
	END

	--apply the updates to the customer
	UPDATE dbo.tblArCust 
		SET CurAmtDue = CASE WHEN t.CurAmtDue > 0 THEN t.CurAmtDue ELSE 0 END
		, BalAge1 = (CASE WHEN t.BalAge1 > 0 THEN t.BalAge1 ELSE 0 END)
		, BalAge2 = (CASE WHEN t.BalAge2 > 0 THEN t.BalAge2 ELSE 0 END)
		, BalAge3 = (CASE WHEN t.BalAge3 > 0 THEN t.BalAge3 ELSE 0 END)
		, BalAge4 = (CASE WHEN t.BalAge4 > 0 THEN t.BalAge4 ELSE 0 END)
		, UnpaidFinch = (CASE WHEN t.UnpaidFinch > 0 THEN t.UnpaidFinch ELSE 0 END)
		, UnapplCredit = (CASE WHEN t.Credits < 0 THEN ABS(t.Credits) ELSE 0 END) 
	FROM dbo.tblArCust INNER JOIN #AgeBFCust t ON dbo.tblArCust.CustId = t.CustId


	--=================================
	--Update Open Invoice customers
	--=================================
	SELECT @Age1 = DATEADD(day, -30, @WrkStnDate)
	SELECT @Age2 = DATEADD(day, -60, @WrkStnDate)
	SELECT @Age3 = DATEADD(day, -90, @WrkStnDate)
	SELECT @Age4 = DATEADD(day, -120, @WrkStnDate)

	--capture the Open invoice customers - initialize the new balances to zero (0)
	INSERT INTO #AgeOICust (CustId, CurAmtDue, BalAge1, BalAge2, BalAge3, BalAge4, UnpaidFinch, Credits) 
		SELECT c.CustId, 0, 0, 0, 0, 0, 0, 0
		FROM dbo.tblArCust c INNER JOIN #CustomerList ON c.CustId = #CustomerList.CustId 
		WHERE c.AcctType <> 1 --open invoice customers

	--capture invoice/payment information for each customer
	--Exclude pro forma invoice 	
	INSERT INTO #AgeInvoices (CustId, InvcNum, MaxOfRecType, FirstOfTransDate, Amount) 
		SELECT CustId, InvcNum, MAX(RecType) MaxOfRecType
			, CASE WHEN MAX(RecType) = 1 THEN MIN(TransDate) ELSE MIN(PmtDate) END FirstOfTransDate
			, SUM(SIGN(RecType) * AmtFgn) AS Amount 
		FROM (SELECT i.CustId, i.InvcNum, i.RecType, i.AmtFgn
				, CASE WHEN i.RecType = 1 THEN i.TransDate ELSE NULL END TransDate
				, CASE WHEN i.RecType <> 1 THEN i.TransDate ELSE NULL END PmtDate 
			FROM dbo.tblArOpenInvoice i 
			INNER JOIN #AgeOICust l ON i.CustID = l.CustID WHERE i.RecType<>5
			) d 
		GROUP BY CustId, InvcNum

	--age the invoice/payment information and distribute the values
	UPDATE #AgeOICust 
		SET CurAmtDue = t.CurAmtDue
		, BalAge1 = t.BalAge1, BalAge2 = t.BalAge2
		, BalAge3 = t.BalAge3, BalAge4 = t.BalAge4 
		, UnpaidFinch = t.UnpaidFinch, Credits = -t.UnApplCredit
	FROM #AgeOICust
	INNER JOIN (SELECT CustID, SUM(CASE WHEN MaxOfRecType = 4 THEN Amount ELSE 0 END) UnpaidFinch
			, SUM(CASE WHEN MaxOfRecType < 0 THEN Amount ELSE 0 END) UnApplCredit
			, SUM(CASE WHEN MaxOfRecType > 0 AND MaxOfRecType <> 4 AND FirstOfTransDate >= @Age1 THEN Amount ELSE 0 END) CurAmtDue
			, SUM(CASE WHEN MaxOfRecType > 0 AND MaxOfRecType <> 4 
				AND FirstOfTransDate BETWEEN @Age2 AND DATEADD(day, -1, @Age1) THEN Amount ELSE 0 END) BalAge1
			, SUM(CASE WHEN MaxOfRecType > 0 AND MaxOfRecType <> 4 
				AND FirstOfTransDate BETWEEN @Age3 AND DATEADD(day, -1, @Age2) THEN Amount ELSE 0 END) BalAge2
			, SUM(CASE WHEN MaxOfRecType > 0 AND MaxOfRecType <> 4 
				AND FirstOfTransDate BETWEEN @Age4 AND DATEADD(day, -1, @Age3) THEN Amount ELSE 0 END) BalAge3
			, SUM(CASE WHEN MaxOfRecType > 0 AND MaxOfRecType <> 4 AND FirstOfTransDate < @Age4 THEN Amount ELSE 0 END)  BalAge4
		FROM #AgeInvoices 
		GROUP BY CustId
	) t ON #AgeOICust.CustId = t.CustId

	--apply the updates to the customer
	UPDATE dbo.tblArCust 
		SET CurAmtDue = t.CurAmtDue 
		, BalAge1 = t.BalAge1
		, BalAge2 = t.BalAge2
		, BalAge3 = t.BalAge3
		, BalAge4 = t.BalAge4
		, UnpaidFinch = t.UnpaidFinch
		, UnapplCredit = t.Credits
	FROM dbo.tblArCust INNER JOIN #AgeOICust t ON dbo.tblArCust.CustId = t.CustId


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArAgeCustomer_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArAgeCustomer_proc';

