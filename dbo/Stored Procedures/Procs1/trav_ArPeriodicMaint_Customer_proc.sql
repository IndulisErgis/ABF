
CREATE PROCEDURE dbo.trav_ArPeriodicMaint_Customer_proc
AS

SET NOCOUNT ON
BEGIN TRY
	DECLARE @WrkStnDate datetime
	DECLARE @InvcFinch pInvoiceNum
	DECLARE @ApplyCreditsToOldest bit, @BFRollBalances bit
	DECLARE @AgeCustomers bit, @UpdateCreditStatus bit
	DECLARE @ClearHighBalances bit
	

	--Retrieve global values
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @InvcFinch = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'InvcFinch'
	SELECT @ApplyCreditsToOldest = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ApplyCreditsToOldest' --used by aging
	SELECT @BFRollBalances = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'BFRollBalances' --used by aging - should be set to 1 for Periodic Maint 
	SELECT @AgeCustomers = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'AgeCustomers'
	SELECT @UpdateCreditStatus = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'UpdateCreditStatus' 
	SELECT @ClearHighBalances = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ClearHighBalances' 

	IF @WrkStnDate IS NULL OR @InvcFinch IS NULL 
	OR @ApplyCreditsToOldest IS NULL OR @BFRollBalances IS NULL
	OR @AgeCustomers IS NULL OR @UpdateCreditStatus IS NULL
	OR @ClearHighBalances IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	--================
	--Age all the customers
	--================
	IF @AgeCustomers = 1
	BEGIN
		--create the list of customers to age
		CREATE TABLE #CustomerList (CustId pCustId, UNIQUE CLUSTERED (CustId))
		
		--set the list of customers to process (all customers)
		INSERT INTO #CustomerList (CustId)
		SELECT CustId FROM dbo.tblArCust

		--execute the aging
		EXEC dbo.trav_ArAgeCustomer_proc
	END

	--================
	--Update the customer Credit Status
	--================
	IF @UpdateCreditStatus = 1
	BEGIN
		CREATE TABLE #CreditStatus
		(
			CustId pCustId, 
			BalAge1 pDecimal, 
			BalAge2 pDecimal, 
			BalAge3 pDecimal, 
			BalAge4 pDecimal, 
			UnapplCredit pDecimal, 
			CS nvarchar(1), 
			UNIQUE CLUSTERED (CustId)
		)

		--capture the aging brackets for each customer
		INSERT INTO #CreditStatus (CustId, BalAge1, BalAge2, BalAge3, BalAge4, UnapplCredit, CS) 
		SELECT CustID, BalAge1, BalAge2, BalAge3, BalAge4, -UnapplCredit, '0' 
		FROM dbo.tblArCust

		--move all credits into the UnapplCredit column
		UPDATE #CreditStatus SET UnapplCredit = UnapplCredit + BalAge1, BalAge1 = 0  WHERE BalAge1 < 0

		UPDATE #CreditStatus SET UnapplCredit = UnapplCredit + BalAge2, BalAge2 = 0 WHERE BalAge2 < 0

		UPDATE #CreditStatus SET UnapplCredit = UnapplCredit + BalAge3, BalAge3 = 0  WHERE BalAge3 < 0

		UPDATE #CreditStatus SET UnapplCredit = UnapplCredit + BalAge4, BalAge4 = 0 WHERE BalAge4 < 0

		--distribute the credits starting with the oldest aging bracket
		UPDATE #CreditStatus SET UnapplCredit = UnapplCredit + BalAge4, BalAge4 = UnapplCredit + BalAge4 WHERE UnapplCredit < 0

		UPDATE #CreditStatus SET UnapplCredit = UnapplCredit + BalAge3, BalAge3 = UnapplCredit + BalAge3 WHERE UnapplCredit < 0
	  
		UPDATE #CreditStatus SET UnapplCredit = UnapplCredit + BalAge2, BalAge2 = UnapplCredit + BalAge2 WHERE UnapplCredit < 0

		UPDATE #CreditStatus SET UnapplCredit = UnapplCredit + BalAge1, BalAge1 = UnapplCredit + BalAge1 WHERE UnapplCredit < 0

		--set the credit status based upon which aging bracket has an amount due
		UPDATE #CreditStatus SET CS = '1' WHERE BalAge1 > 0

		UPDATE #CreditStatus SET CS = '2' WHERE BalAge2 > 0

		UPDATE #CreditStatus SET CS = '3' WHERE BalAge3 > 0

		UPDATE #CreditStatus SET CS = '4' WHERE BalAge4 > 0

		--append the most recent credit status to the customer 
		UPDATE dbo.tblArCust SET CreditStatus = SUBSTRING(#CreditStatus.CS + COALESCE(tblArCust.CreditStatus,''), 1, 12) 
		FROM dbo.tblArCust INNER JOIN #CreditStatus ON dbo.tblArCust.CustID = #CreditStatus.CustID
	END
	
	--================
	--Clear high balances
	--================
	IF @ClearHighBalances = 1
	BEGIN
		UPDATE dbo.tblArCust SET HighBal = 0
	END

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_Customer_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_Customer_proc';

