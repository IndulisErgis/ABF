CREATE PROCEDURE [dbo].[ALP_qrySISiteRecBillServGetByRecBillIds]
(
	@RecBillIds IntegerListType READONLY
)
AS
BEGIN
	SELECT 
		[srbs].[RecBillServId],
		[srbs].[RecBillId],
		[srbs].[Status],
		[srbs].[ServiceID],
		[srbs].[Desc],
		[srbs].[LocID],
		[srbs].[ActivePrice],
		[srbs].[ActiveCycleId],
		[srbs].[ActiveCost],
		[srbs].[ActiveRMR],
		[srbs].[AcctCode],
		[srbs].[GLAcctSales],
		[srbs].[GLAcctCOGS],
		[srbs].[GLAcctInv],
		[srbs].[DfltPrice],
		[srbs].[DfltCost],
		[srbs].[ServiceType],
		[srbs].[SysId],
		[srbs].[ExtRepPlanId],
		[srbs].[ContractId],
		[srbs].[InitialTerm],
		[srbs].[RenTerm],
		[srbs].[ServiceStartDate],
		[srbs].[BilledThruDate],
		[srbs].[FinalBillDate],
		[srbs].[AllowGlobalPriceChangeYN],
		[srbs].[MinMths],
		[srbs].[NoChangePriorTo],
		[srbs].[AutoRenYN],
		[srbs].[NotifyYN],
		[srbs].[CanReasonId],
		[srbs].[CanComments],
		[srbs].[CanReportDate],
		[srbs].[CanServEndDate],
		[srbs].[CanCustId],
		[srbs].[CanCustName],
		[srbs].[CanSiteName],
		[srbs].[CanCustFirstName],
		[srbs].[CanSiteFirstName],
		[srbs].[Processed],
		[srbs].[ts],
		[srbs].[ModifiedBy],
		[srbs].[ModifiedDate]
	FROM [dbo].[ALP_tblArAlpSiteRecBillServ_view] AS [srbs] 
	INNER JOIN @RecBillIds AS [input]
		ON	[srbs].[RecBillId] = [input].[Id]
END