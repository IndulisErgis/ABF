CREATE PROCEDURE [dbo].[ALP_stpSISiteSysInsert]
(
	-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
    @SysId int output,
    @CustId varchar(10) = null,
    @SiteId int,
    @InstallDate datetime = null,
    @ContractId int = null,
    @SysTypeId int,
    @SysDesc varchar(255) = null,
    @CentralId int = null,
    @AlarmId varchar(50) = null,
    @WarrPlanId int = null,
    @WarrTerm smallint = null,
    @WarrExpires datetime = null,
    @RepPlanId int = null,
    @LeaseYn bit = null,
    @PulledDate datetime = null,
    @CreateDate datetime = null,
    @LastUpdateDate datetime = null,
    @UploadDate datetime = null,
    @ModifiedBy VARCHAR(50) = NULL,
    @ModifiedDate DATETIME = NULL
)
AS
BEGIN    
    INSERT INTO ALP_tblArAlpSiteSys
        ([CustId],[SiteId],[InstallDate],[ContractId],[SysTypeId],[SysDesc],[CentralId],[AlarmId],[WarrPlanId],
         [WarrTerm],[WarrExpires],[RepPlanId],[LeaseYN],[PulledDate],[CreateDate],[LastUpdateDate],[UploadDate], [ModifiedBy], [ModifiedDate])
    VALUES (@CustId,@SiteId,@InstallDate,@ContractId,@SysTypeId,@SysDesc,@CentralId,@AlarmId,
            @WarrPlanId,@WarrTerm,@WarrExpires,@RepPlanId,@LeaseYn,@PulledDate,@CreateDate,
            @LastUpdateDate,@UploadDate, @ModifiedBy, @ModifiedDate)
            
    SET @SysId = @@identity
END