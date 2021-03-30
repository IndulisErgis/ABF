
CREATE VIEW [dbo].[ALP_rptArAlpRecBill_ExpiringServicesReport_View]
AS
	WITH [LastPrice] AS 
	(
		SELECT
			MAX([p].[RecBillServPriceId]) AS [RecBillServPriceId]
		FROM [dbo].[ALP_tblArAlpSiteRecBillServPrice_view] AS [p]
		GROUP BY [p].[RecBillServId]
	)
	SELECT
		[r].[RunId],
		[rr].[RunRecordId],
		[c].[CustName],
		[ac].[AlpFirstName] AS [CustFirstName],
		[c].[CustId],
		[s].[SiteId],
		[s].[SiteName],
		[s].[AlpFirstName] AS [SiteFirstName],
		[srb].[ItemId],
		[rr].[RecBillNextBillDate],
		[rr].[RecBillServiceStatus],
		[rr].[BillingPeriodStart],
		[rr].[EndDate],
		[rr].[BillingPeriodEnd],
		[cyc].[Cycle],
		[cyc].[Units],
		[srbs].[ServiceID],
		[srbs].[Desc],
		[st].[SysType],
		[srbs].[ServiceStartDate],
		[srbsp].[EndBillDate],
		[rr].[Price],
		ISNULL([rr].[Price] * [rr].[BillQty], 0) AS [BillPrice],
		[r].[NextBillDate], 
		[r].[NewNextBillDate], 
		[r].[BatchCode], 
		[r].[InvoiceDate], 
		[r].[GLYear], 
		[r].[GLPeriod], 
		[r].[CustomerIdFrom], 
		[r].[CustomerIdTo], 
		[r].[BranchFrom], 
		[r].[BranchTo], 
		[r].[ClassFrom], 
		[r].[ClassTo], 
		[r].[GroupFrom], 
		[r].[GroupTo], 
		[r].[StatusCode], 
		[r].[CreatedDate]
	FROM [dbo].[ALP_tblArAlpRecBillRun] AS [r]
	INNER JOIN [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]
		ON	[r].[RunId] = [rr].[RunId]
	INNER JOIN [dbo].[tblArCust] AS [c]
		ON	[c].[CustId] = [rr].[CustId]
	INNER JOIN [dbo].[ALP_tblArCust] AS [ac]
		ON	[ac].[AlpCustId] = [rr].[CustId]
	INNER JOIN	[dbo].[ALP_tblArAlpSite_view] AS [s]
		ON	[s].[SiteId] = [rr].[SiteId]
	INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill_view] AS [srb]
		ON	[srb].[RecBillId] = [rr].[RecBillId]
	INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ_view] AS [srbs]
		ON	[srbs].[RecBillId] = [srb].[RecBillId]
		AND	[srbs].[RecBillServId] = [rr].[RecBillServId]
	INNER JOIN [dbo].[ALP_tblArAlpCycle] AS [cyc]
		ON	[srb].[BillCycleId] = [cyc].[CycleId]
	INNER JOIN [dbo].[ALP_tblArAlpSiteSys_view] AS [ss]
		ON	[ss].[SysId] = [srbs].[SysId]
	INNER JOIN [dbo].[ALP_tblArAlpSysType] AS [st]
		ON	[st].[SysTypeId] = [ss].[SysTypeId]
	INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice_view] AS [srbsp]
		ON	[srbsp].[RecBillServId] = [srbs].[RecBillServId]
		AND	[srbsp].[RecBillServPriceId] = [rr].[RecBillServPriceId]
	INNER JOIN [LastPrice] AS [l]
		ON	[l].[RecBillServPriceId] = [srbsp].[RecBillServPriceId]
	WHERE	[rr].[EndDate] IS NOT NULL
		AND	[rr].[EndCycleDate] >= [rr].[EndDate]