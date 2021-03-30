
CREATE PROCEDURE dbo.trav_ArExtPmtInvoice_proc
@CustId pCustID
AS
SET NOCOUNT ON
BEGIN TRY
	--capture the list of invoices
	CREATE TABLE #InvoiceTotal
	(
		[InvcNum] [pInvoiceNum] NULL, 
		[RecType] [smallint],
		[CurrencyId] [pCurrency],
		[TransDate] [Datetime],
		UNIQUE CLUSTERED ([InvcNum], [RecType], [CurrencyId])
	)
		
	--identify the list of invoice with outstanding balances
	INSERT INTO #InvoiceTotal ([InvcNum], [RecType], [CurrencyId], [TransDate])
	SELECT [InvcNum]
		, CASE [RecType] WHEN 5 THEN 5 ELSE 1 END --map non-deposit entries to invoice
		, [CurrencyId]
		, Min([TransDate]) --oldest date per invoice
	FROM dbo.tblArOpenInvoice
	WHERE [Status] <> 4 and [CustId] = @CustId 
	GROUP BY [InvcNum], Case [RecType] When 5 Then 5 Else 1 End, [CurrencyId]
	HAVING ISNULL(SUM(SIGN([RecType]) * [AmtFgn]), 0) <> 0

	--return the list of aggregate invoice entries
	--	use oldest dated entry for secondary values when aggregating data
	SELECT CAST(0 AS bit) AS [Pay]
			, l.[TransDate] AS [InvoiceDate]
			, l.[RecType] AS [InvoiceType]
			, l.[InvcNum] AS [InvoiceNumber]
			, MIN(Case When l.[TransDate] = i.[TransDate] Then i.[DiscDueDate] Else NULL End) AS [DiscountDate] --use discduedate from oldest entry
			, MIN(Case When l.[TransDate] = i.[TransDate] Then i.[CustPONum] Else NULL End) AS [CustPONum] --use custponum from oldest entry
			, SUM(i.[AmountDue]) AS [AmountDue]
			, SUM(i.[AmountDueFgn]) AS [AmountDueFgn]
			, SUM(i.[DiscountAllowed]) AS [DiscountAllowed]
			, SUM(i.[DiscountAllowedFgn]) AS [DiscountAllowedFgn]
			, CAST(0 AS decimal(28, 10)) AS [PaymentAmount]
			, CAST(0 AS decimal(28, 10)) AS [Discount]
			, l.[CurrencyId]
	FROM #InvoiceTotal l
	Inner Join (
		SELECT [InvcNum]
			, CASE [RecType] WHEN 5 THEN 5 ELSE 1 END AS [RecType] --map non-deposit entries to invoice
			, [TransDate]
			, [CurrencyId]
			, [DiscDueDate]
			, [CustPONum]
			--Amount due in base currency  
			, SIGN([RecType]) * [Amt] AS [AmountDue]
			--Amount due in payment currency
			, SIGN([RecType]) * [AmtFgn] AS [AmountDueFgn]
			--Discount amount allowed in base currency  			
			, SIGN(RecType) * DiscAmt AS [DiscountAllowed]
			--Discount amount allowed in payment currency
			, SIGN(RecType) * DiscAmtFgn AS [DiscountAllowedFgn]
		FROM dbo.tblArOpenInvoice
		WHERE [Status] <> 4 and [CustId] = @CustId
	) i ON l.[InvcNum] = i.[InvcNum] 
		AND l.[RecType] = i.[RecType] 
		AND l.[CurrencyId] = i.[CurrencyId]
	GROUP BY l.[InvcNum], l.[RecType], l.[CurrencyId], l.[TransDate]

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArExtPmtInvoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArExtPmtInvoice_proc';

