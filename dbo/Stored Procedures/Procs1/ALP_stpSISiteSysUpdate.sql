
CREATE PROCEDURE [dbo].[ALP_stpSISiteSysUpdate]
(
	-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
	@SysId INT,
	@CustId VARCHAR(10) = NULL,
	@SiteId INT,
	@InstallDate DATETIME = NULL,
	@ContractId INT = NULL,
	@SysTypeId INT,
	@SysDesc VARCHAR(255) = NULL,
	@CentralId INT = NULL,
	@AlarmId VARCHAR(50) = NULL,
	@WarrPlanId INT = NULL,
	@WarrTerm SMALLINT = NULL,
	@WarrExpires DATETIME = NULL,
	@RepPlanId INT = NULL,
	@LeaseYn BIT = NULL,
	@PulledDate DATETIME = NULL,
	@CreateDate DATETIME = NULL,
	@LastUpdateDate DATETIME = NULL,
	@UploadDate DATETIME = NULL,
    @ModifiedBy VARCHAR(50) = NULL,
    @ModifiedDate DATETIME = NULL
)
AS
BEGIN
	UPDATE [ss]
	SET	[ss].[CustId] = @CustId,
		[ss].[SiteId] = @SiteId,
		[ss].[InstallDate] = @InstallDate,
		[ss].[ContractId] = @ContractId,
		[ss].[SysTypeId] = @SysTypeId,
		[ss].[SysDesc] = @SysDesc,
		[ss].[CentralId] = @CentralId,
		[ss].[AlarmId] = @AlarmId,
		[ss].[WarrPlanId] = @WarrPlanId,
		[ss].[WarrTerm] = @WarrTerm,
		[ss].[WarrExpires] = @WarrExpires,
		[ss].[RepPlanId] = @RepPlanId,
		[ss].[LeaseYN] = @LeaseYn,
		[ss].[PulledDate] = @PulledDate,
		[ss].[CreateDate] = @CreateDate,
		[ss].[LastUpdateDate] = @LastUpdateDate,
		[ss].[UploadDate] = @UploadDate,
		[ss].[ModifiedBy] = @ModifiedBy,
		[ss].[ModifiedDate] = @ModifiedDate
	FROM [dbo].[ALP_tblArAlpSiteSys] AS [ss]
	WHERE	[ss].[SysId] = @SysId
END