CREATE PROCEDURE [dbo].[ALP_qrySISiteSys_GetActiveAccount_AllServices] 
(
	-- Created by Nidheesh on 05/19/09        
	-- Updated for TRAV11 by Josh Gillespie on 04/26/2013   
	@CustID VARCHAR(10),      
	@EffectiveDate DATETIME      
)
AS
BEGIN
	SELECT     
		[rbs].[RecBillServId],
		COUNT([rbs].[RecBillId]) AS [TotalNoActAccounts]
	FROM [dbo].[ALP_tblArAlpSiteSys_view] AS [ss] 
	LEFT OUTER JOIN  [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]
		ON [ss].[SysId] = [rbs].[SysId]   
	WHERE	[ss].[CustId] = @CustID        
	  AND ([rbs].[Status] = 'New' OR [rbs].[Status] = 'Active')    
	  AND ([rbs].[ServiceStartDate] <= @EffectiveDate)    
	  AND ([rbs].[FinalBillDate]    >  @EffectiveDate OR [rbs].[FinalBillDate] IS NULL)    
	  AND ([rbs].[CanServEndDate]   >  @EffectiveDate  OR [rbs].[CanServEndDate] IS NULL)    
    GROUP BY [rbs].[RecBillServId]
END