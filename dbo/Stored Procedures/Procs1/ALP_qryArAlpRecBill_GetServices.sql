
CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_GetServices]
(
	@RecBillServIds IntegerListType READONLY
)
AS
BEGIN
	SELECT
		[s].[RecBillServId],
		[s].[RecBillId],
		[s].[Status],
		[s].[ServiceID],
		[s].[Desc],
		[s].[LocID],
		[s].[ActivePrice],
		[s].[ActiveCycleId],
		[s].[ActiveCost],
		[s].[ActiveRMR],
		[s].[AcctCode],
		[s].[GLAcctSales],
		[s].[GLAcctCOGS],
		[s].[GLAcctInv],
		[s].[DfltPrice],
		[s].[DfltCost],
		[s].[ServiceType],
		[s].[SysId],
		[s].[ExtRepPlanId],
		[s].[ContractId],
		[s].[InitialTerm],
		[s].[RenTerm],
		[s].[ServiceStartDate],
		[s].[BilledThruDate],
		[s].[FinalBillDate],
		[s].[AllowGlobalPriceChangeYN],
		[s].[MinMths],
		[s].[NoChangePriorTo],
		[s].[AutoRenYN],
		[s].[NotifyYN],
		[s].[CanReasonId],
		[s].[CanComments],
		[s].[CanReportDate],
		[s].[CanServEndDate],
		[s].[CanCustId],
		[s].[CanCustName],
		[s].[CanSiteName],
		[s].[CanCustFirstName],
		[s].[CanSiteFirstName],
		[s].[Processed],
		[s].[ts],
		[s].[ModifiedBy],
		[s].[ModifiedDate]
	FROM	[dbo].[ALP_tblArAlpSiteRecBillServ] AS [s]
	INNER JOIN @RecBillServIds AS [input]
		ON	[input].[Id] = [s].[RecBillServId]
END