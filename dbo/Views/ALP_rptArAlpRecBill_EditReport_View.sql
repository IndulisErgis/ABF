CREATE VIEW [dbo].[ALP_rptArAlpRecBill_EditReport_View]
AS
	SELECT
		[e].[RecBillID],
		[e].[CustID],
		[c].[CustName],
		[ac].[AlpFirstName] AS [CustFirstName],
		[e].[SiteId],
		[s].[SiteName],
		[s].[AlpFirstName] AS [SiteFirstName],
		[srb].[ItemId] AS [EntryId], -- EntryId
		[srb].[AcctCode] AS [EntryAcctCode],
		[e].[RecBillNextBillDate], --NextBillDate
		[srbs].[ServiceID],
		[sys].[SysType] AS [System],
		[e].[BillingPeriodStart],
		[e].[BillingPeriodEnd],
		[srbs].[AcctCode] AS [ServAcctCode],
		ISNULL([e].[Price], 0) AS [Price],
		ISNULL([e].[CycleUnits] * [e].[Price], 0) AS [NormalBilling],
		ISNULL([e].[BillQty]* [e].[Price], 0) AS [BillPrice],
		[cyc].[Cycle],
		[r].[NextBillDate],
		CASE WHEN	ISNULL([e].[BillQty] - [e].[CycleUnits], 0) <> 0 --proration of some kind
					OR	[r].[NextBillDate] <> [e].[RecBillNextBillDate] -- arrears
					OR	[c].[CreditHold] = 1 -- on credit hold
				 THEN CAST(1 AS BIT)
				 ELSE CAST(0 AS BIT)
			END AS [HasWarnings],
		[e].[Comments],
		[e].[UseInvcConsolidationSiteYn],
		[e].[InvoiceSiteId],
		[r].[RunId]
	FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [e]
	INNER JOIN [dbo].[ALP_tblArAlpRecBillRun] AS [r]
		ON	[r].[RunId] = [e].[RunId]
	INNER JOIN [dbo].[ALP_tblArAlpSite] AS [s]
		ON	[s].[SiteId] = [e].[SiteId]
	INNER JOIN [dbo].[tblArCust] AS [c]
		ON	[c].[CustId] = [e].[CustId]
	INNER JOIN [dbo].[ALP_tblArCust] AS [ac]
		ON	[ac].[AlpCustId] = [e].[CustId]
	INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill] AS [srb]
		ON	[srb].[RecBillId] = [e].[RecBillId]
	INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [srbs]
		ON	[srbs].[RecBillServId] = [e].[RecBillServId]
	INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [srbsp]
		ON	[srbsp].[RecBillServPriceId] = [e].[RecBillServPriceId]
	INNER JOIN [dbo].[ALP_tblArAlpCycle] AS [cyc]
		ON	[cyc].[CycleId] = [srb].[BillCycleId]
	INNER JOIN [dbo].[ALP_tblArAlpSiteSys] AS [ss]
		ON	[ss].[SysId] = [srbs].[SysId]
	INNER JOIN [dbo].[ALP_tblArAlpSysType] AS [sys]
		ON	[sys].[SysTypeId] = [ss].[SysTypeId]