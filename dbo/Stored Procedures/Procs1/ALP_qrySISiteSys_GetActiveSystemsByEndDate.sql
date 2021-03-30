
CREATE PROCEDURE [dbo].[ALP_qrySISiteSys_GetActiveSystemsByEndDate]       
-- Created by Nidheesh on 05/19/09
-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
(      
	@CustID varchar(10),      
	@EffectiveDate datetime,  
	@LastPeriodBilled_EndDate datetime      
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
	FROM  [dbo].[ALP_tblArAlpSiteSys_view] AS [ss] 
	LEFT OUTER JOIN  [dbo].[ALP_tblArAlpSiteRecBillServ_view] AS [rbs]
	--incorrect join fixed by MAH on 09/02/13:
		--ON [ss].[SysId] = [rbs].[RecBillServId]  
		ON  [ss].[SysId] = [rbs].[SysId]  
	WHERE	[ss].[CustId] = @CustID        
		AND ([ss].[InstallDate] <= @EffectiveDate  AND [ss].[InstallDate] IS NOT NULL )     
		AND ([ss].[PulledDate]  > @EffectiveDate  OR [ss].[PulledDate]  IS NULL)     
		AND ([rbs].[ServiceStartDate] <= @EffectiveDate)    
		AND ([rbs].[FinalBillDate]    >  @EffectiveDate OR [rbs].[FinalBillDate] IS NULL)    
		AND ([rbs].[CanServEndDate]   >  @EffectiveDate  OR [rbs].[CanServEndDate] IS NULL)    
		AND [rbs].[ServiceStartDate] >=  @LastPeriodBilled_EndDate  
END