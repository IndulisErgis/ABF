CREATE PROCEDURE [dbo].[ALP_qrySISiteRecBill_GetActiveServices_ServiceID]              
(                
	@CustID varchar(10),                
	@EffectiveDate	[datetime],
	@ServiceID varchar(24)            
)                
AS                 
BEGIN                
	SELECT  
		[rbs].[RecBillServId],
		[rbs].[RecBillId],
		[rbs].[Status],	
		[rbs].[ServiceID],        
		[rbs].[Desc],	
		[rbs].[LocID],
		[rbs].[ActivePrice],
		[rbs].[ActiveCycleId],        
		[rbs].[ActiveCost],
		[rbs].[ActiveRMR],
		[rbs].[AcctCode],
		[rbs].[GLAcctSales],        
		[rbs].[GLAcctCOGS],
		[rbs].[GLAcctInv],
		[rbs].[DfltPrice],
		[rbs].[DfltCost],        
		[rbs].[ServiceType],
		[rbs].[SysId],
		[rbs].[ExtRepPlanId],
		[rbs].[ContractId],        
		[rbs].[InitialTerm],
		[rbs].[RenTerm],
		[rbs].[ServiceStartDate],
		[rbs].[BilledThruDate],        
		[rbs].[FinalBillDate],
		[rbs].[AllowGlobalPriceChangeYN],
		[rbs].[MinMths],
		[rbs].[NoChangePriorTo],        
		[rbs].[AutoRenYN],
		[rbs].[NotifyYN],
		[rbs].[CanReasonId],
		[rbs].[CanComments],        
		[rbs].[CanReportDate],
		[rbs].[CanServEndDate],
		[rbs].[CanCustId],
		[rbs].[CanCustName],        
		[rbs].[CanSiteName],
		[rbs].[CanCustFirstName],
		[rbs].[CanSiteFirstName],
		[rbs].[Processed]
	FROM	[dbo].[ALP_tblArAlpSiteRecBillServ_view] AS [rbs]
	LEFT OUTER JOIN [dbo].[ALP_tblArAlpSiteSys_view] AS [ss]
		ON [ss].[SysId] = [rbs].[SysId]
	LEFT OUTER JOIN [dbo].[ALP_tblArAlpSite_view] AS [s]
		ON [s].[SiteId] = [ss].[SiteId]
	WHERE	[ss].[CustID] = @CustID      
		AND [s].[WDBTemplateYN] <> 1         
		AND  [rbs].[ServiceID] = @ServiceID
		AND  [rbs].[ServiceStartDate] <=   @EffectiveDate
		AND  ( [rbs].[FinalBillDate] > @EffectiveDate  OR [rbs].[FinalBillDate] IS NULL)
		AND  ([rbs].[CanServEndDate] > @EffectiveDate  OR [rbs].[CanServEndDate] IS NULL)
END