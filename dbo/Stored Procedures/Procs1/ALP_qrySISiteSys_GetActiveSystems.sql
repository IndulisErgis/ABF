
CREATE PROCEDURE [dbo].[ALP_qrySISiteSys_GetActiveSystems]       
-- Created by Nidheesh on 05/19/09   
-- Updated for TRAV11 by Josh Gillespie on 04/26/2013  
(      
	@CustID varchar(10),      
	@EffectiveDate datetime      
)      
AS
BEGIN
	SELECT
		[ss].[SysId],
		[ss].[CustId],
		[ss].[SiteId],
		[ss].[InstallDate],    
		[ss].[ContractId],
		[ss].[SysTypeId],
		[ss].[SysDesc],
		[ss].[CentralId],    
		[ss].[AlarmId],
		[ss].[WarrPlanId],
		[ss].[WarrTerm],
		[ss].[WarrExpires],    
		[ss].[RepPlanId],
		[ss].[LeaseYN],
		[ss].[PulledDate],
		[ss].[CreateDate],    
		[ss].[LastUpdateDate],
		[ss].[UploadDate],
		[ss].[ModifiedBy],
		[ss].[ModifiedDate]
	FROM [dbo].[ALP_tblArAlpSiteSys_view] AS [ss]
	LEFT OUTER JOIN  [dbo].[ALP_tblArAlpSiteRecBillServ_view] AS [rbs]
		ON [ss].[SysId] = [rbs].[RecBillServId]
	LEFT OUTER JOIN [dbo].[ALP_tblArAlpSite_view] AS [s]
		ON [s].[SiteId] = [ss].[SiteId]
	WHERE	[ss].[CustId] = @CustID 
		AND [s].[WDBTemplateYN] <> 1
		AND ([rbs].[ServiceStartDate] <= @EffectiveDate)    
		AND ([rbs].[FinalBillDate]    >  @EffectiveDate OR [rbs].[FinalBillDate] IS NULL)    
		AND ([rbs].[CanServEndDate]   >  @EffectiveDate  OR [rbs].[CanServEndDate] IS NULL)    
END