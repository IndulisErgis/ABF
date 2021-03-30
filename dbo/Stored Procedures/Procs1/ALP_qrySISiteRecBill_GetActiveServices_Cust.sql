CREATE PROCEDURE [dbo].[ALP_qrySISiteRecBill_GetActiveServices_Cust]
-- Created by Nidheesh on 05/19/09
-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
(
    @CustID VARCHAR (10), 
    @EffectiveDate DATETIME
)
AS
BEGIN
    SELECT
        @CustID AS [CustID],
        [rbs].[RecBillServId],
        [rbs].[RecBillId],
        [rbs].[Status],
        [rbs].[ServiceID]s,
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
        [rbs].[Processed],
        [ss].[AlarmId],
        [s].[SiteName],
        [s].[AlpFirstName],
        [s].[Addr1],
        [s].[Addr2],
        [s].[City],
        [s].[Region],
        [s].[PostalCode],
        [rbsp].[Price],
        [rbsp].[PriceLockedYn],
        [rbsp].[EndBillDate],
        [rbsp].[StartBillDate]
    FROM [dbo].[ALP_tblArAlpSiteRecBillServ_view] AS [rbs]
    INNER JOIN [dbo].[ALP_tblArAlpSiteSys_view] AS [ss]
        ON	[ss].[SysId] = [rbs].[SysId]
    INNER JOIN [dbo].[ALP_tblArAlpSite_view] AS [s]
        ON	[s].[SiteId] = [ss].[SiteId]
    INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice_view] AS [rbsp]
        ON [rbsp].[RecBillServId] = [rbs].[RecBillServId]
    WHERE    [ss].[CustId] = @CustID
        AND [s].[WDBTemplateYN] <> 1
        AND [rbs].[ServiceStartDate] <= @EffectiveDate
        AND ([rbs].[FinalBillDate] > @EffectiveDate OR [rbs].[FinalBillDate] IS NULL)
        AND ([rbs].[CanServEndDate] > @EffectiveDate OR [rbs].[CanServEndDate] IS NULL)
        AND ([rbsp].[startbilldate] <= @EffectiveDate
        AND ([rbsp].[startbilldate] IS NOT NULL OR [rbsp].[StartBillDate] <> ''))
        AND ([rbsp].[Endbilldate] > @EffectiveDate OR [rbsp].[Endbilldate] IS NULL)
    ORDER BY [rbs].[ServiceID]
END