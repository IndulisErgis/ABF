CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_Search]
(
	@NextBillDate DATETIME,
	@CustFrom pCustId = NULL,
	@CustTo pCustId = NULL,
	@BranchFrom INT = NULL,
	@BranchTo INT = NULL,
	@ClassFrom VARCHAR(6) = NULL,
	@ClassTo VARCHAR(6) = NULL,
	@GroupFrom VARCHAR(1) = NULL,
	@GroupTo VARCHAR(1) = NULL
)
AS
BEGIN
	SELECT
		@CustFrom = NULLIF(RTRIM(@CustFrom), ''),
		@CustTo = NULLIF(RTRIM(@CustTo), ''),
		@ClassFrom = NULLIF(RTRIM(@ClassFrom), ''),
		@ClassTo = NULLIF(RTRIM(@ClassTo), ''),
		@GroupFrom = NULLIF(RTRIM(@GroupFrom), ''),
		@GroupTo = NULLIF(RTRIM(@GroupTo), '')
	SELECT
		-1 AS [RunRecordId],
		-1 AS [RunId],
		[srb].[CustId],
		[srb].[InvcConsolidationSiteId] AS [InvoiceSiteId],
		[srb].[SiteId],
		[srb].[MailSiteYN],
		[srb].[UseInvcConsolidationSiteYn],
		[srb].[RecBillId],
		[srbs].[RecBillServId],
		[srbsp].[RecBillServPriceId],
		[srb].[NextBillDate] AS [RecBillNextBillDate],
		[srbs].[ServiceStartDate],
		GETDATE() AS [EndCycleDate], -- Placeholder value for non-null field. Real value calculated in C# Code
		NULL AS [EndDate], -- Calculated in C# Code
		[srbs].[Status] AS [RecBillServiceStatus],
		[srbs].[SysId],
		ISNULL([srbsp].[Price], 0) AS [Price],
		ISNULL(CAST([cyc].[Units] AS INT), 0) AS [CycleUnits],
		NULL AS [BillQty], -- Calculated in C# Code
		[ss].[AlarmId],
		NULL AS [BillingPeriodStart], -- For WDB,
		NULL AS [BillingPeriodEnd], -- For WDB,
		NULL AS [ServiceStatus], -- For WDB,
		NULL AS [Comments]
	FROM [dbo].[ALP_tblArAlpSiteRecBill] AS [srb]
	INNER JOIN [dbo].[ALP_tblArAlpCycle] AS [cyc]
		ON	[cyc].[CycleId] = [srb].[BillCycleId]
	INNER JOIN [dbo].[ALP_tblArAlpSite] AS [s]
		ON	[srb].[SiteId] = [s].[SiteId]
	INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [srbs]
		ON	[srbs].[RecBillId] = [srb].[RecBillId]
	INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [srbsp]
		ON	[srbsp].[RecBillServId] = [srbs].[RecBillServId]
	INNER JOIN [dbo].[tblArCust] AS [c]
		ON	[srb].[CustId] = [c].[CustId]
	INNER JOIN [dbo].[ALP_tblArAlpSiteSys] AS [ss]
		ON	[ss].[SysId] = [srbs].[SysId]
	WHERE	[srb].[NextBillDate] <= @NextBillDate
		AND	[s].[Status] = 'Active'
		AND [srbs].[SysId] IS NOT NULL
		AND [srbs].[Status] IN ( 'New', 'Active' )
		AND	[srbs].[ServiceStartDate] IS NOT NULL
		AND	[srbs].[ServiceStartDate] <= @NextBillDate
		AND [s].[WDBTemplateYN] = 0 -- from Edit report query.
		AND	[srbsp].[StartBillDate] < DATEADD(m, [cyc].[Units], @NextBillDate)
		--	removed from query because FinalBillDate can be set for expiring prices.
		--	AND ([srbs].[FinalBillDate] IS NULL OR [srbs].[FinalBillDate] >= [srb].[NextBillDate])
		AND	(		[srbsp].[EndBillDate] IS NULL
				OR	[srbsp].[EndBillDate] >= [srb].[NextBillDate]
			)
		AND (@CustFrom IS NULL OR [srb].[CustId] >= @CustFrom)
		AND	(@CustTo IS NULL OR [srb].[CustId] <= @CustTo)
		AND	(@BranchFrom IS NULL OR [s].[BranchId] >= @BranchFrom)
		AND	(		@BranchTo IS NULL
				OR	(	[s].[BranchId] <= @BranchTo
					OR	(@BranchFrom IS NULL AND [s].[BranchId] IS NULL)
					)
			)
		AND	(@ClassFrom IS NULL OR [c].[ClassId] >= @ClassFrom)
		AND (		@ClassTo IS NULL
				OR	(	[c].[ClassId] <= @ClassTo
						OR	(@ClassFrom IS NULL AND [c].[ClassId] IS NULL)
					)
			)
		AND	(@GroupFrom IS NULL OR [c].[GroupCode] >= @GroupFrom)
		AND (	@GroupTo IS NULL
				OR	(	[c].[GroupCode] <= @GroupTo
					OR	(@GroupFrom IS NULL AND [c].[GroupCode] IS NULL)
				)
			)
	ORDER BY
		[srb].[CustId],
		[srb].[InvcConsolidationSiteId]
END