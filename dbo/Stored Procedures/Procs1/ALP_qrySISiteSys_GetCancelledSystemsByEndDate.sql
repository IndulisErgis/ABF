
CREATE PROCEDURE [dbo].[ALP_qrySISiteSys_GetCancelledSystemsByEndDate]
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
	 FROM [dbo].[ALP_tblArAlpSiteSys_view] AS [ss]
	 LEFT OUTER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ_view] AS [rbs]    
		ON [ss].[SysId] = [rbs].[RecBillServId]    
	 WHERE	[ss].[CustId] = @CustID        
		AND ([rbs].[FinalBillDate]    <=  @EffectiveDate)
		AND ([rbs].[CanServEndDate]   <=  @EffectiveDate  OR [rbs].[CanServEndDate] IS NOT NULL)    
		AND ([rbs].[CanServEndDate] >=  @LastPeriodBilled_EndDate  OR [rbs].[FinalBillDate] >= @LastPeriodBilled_EndDate)
END