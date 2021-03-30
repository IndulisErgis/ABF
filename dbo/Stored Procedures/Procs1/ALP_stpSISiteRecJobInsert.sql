





CREATE PROCEDURE [dbo].[ALP_stpSISiteRecJobInsert]      
(      
--   --The contact param length modified by ravi on 04.28.2014 (Earlier its 25 char not it has been changed to 60 char)  
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50   
 @RecJobEntryId INT OUTPUT,      
 @CreateDate DATETIME = NULL,      
 @CustId VARCHAR(10) = NULL,      
 @SiteId INT = NULL,      
 @RecBillEntryId INT = NULL,      
 @RecSvcId INT = NULL,      
 @SysId INT = NULL,      
 @ContractId INT = NULL,      
 @CustPoNum VARCHAR(25) = NULL,      
 @JobCycleId INT = NULL,      
 @LastCycleStartDate DATETIME = NULL,      
 @NextCycleStartDate DATETIME = NULL,      
 @ExpirationDate DATETIME = NULL,      
 @LastDateCreated DATETIME = NULL,      
 --@Contact VARCHAR(25) = NULL,      
 @Contact VARCHAR(60) = NULL,    --The contact param length modified by ravi on 04.28.2014  
 @ContactPhone VARCHAR(15) = NULL,      
 @WorkDesc TEXT = NULL,      
 @WorkCodeId INT = NULL,      
 @RepPlanId INT = NULL,      
 @PriceId VARCHAR(15) = NULL,      
 @BranchId INT = NULL,      
 @DeptId INT = NULL,      
 @DivId INT = NULL,      
 @SkillId INT = NULL,      
 @PrefTechId INT = NULL,      
 @EstHrs FLOAT = NULL,      
 @PrefTime VARCHAR(50) = NULL,      
 @OtherComments TEXT = NULL,      
 @SalesRepId VARCHAR(3) = NULL,      
 @ModifiedBy VARCHAR(50) = NULL,      
 @ModifiedDate DATETIME = NULL  ,    
 @PhoneExt Varchar(10)=null    
)      
AS      
BEGIN      
 INSERT INTO [dbo].[ALP_tblArAlpSiteRecJob]      
 ([CreateDate], [CustId], [SiteId], [RecBillEntryId], [RecSvcId], [SysId], [ContractId], [CustPoNum], [JobCycleId], [LastCycleStartDate], [NextCycleStartDate], [ExpirationDate], [LastDateCreated], [Contact], [ContactPhone], [WorkDesc], [WorkCodeId],    
  [RepPlanId], [PriceId], [BranchId], [DeptId], [DivId], [SkillId], [PrefTechId], [EstHrs], [PrefTime], [OtherComments], [SalesRepId], [ModifiedBy], [ModifiedDate],PhoneExt)      
 VALUES      
 ( @CreateDate,      
  @CustId,      
  @SiteId,      
  @RecBillEntryId,      
  @RecSvcId,      
  @SysId,      
  @ContractId,      
  @CustPoNum,      
  @JobCycleId,      
  @LastCycleStartDate,      
  @NextCycleStartDate,      
  @ExpirationDate,      
  @LastDateCreated,      
  @Contact,      
  @ContactPhone,      
  @WorkDesc,      
  @WorkCodeId,      
  @RepPlanId,      
  @PriceId,      
  @BranchId,      
  @DeptId,      
  @DivId,      
  @SkillId,      
  @PrefTechId,      
  @EstHrs,      
  @PrefTime,      
  @OtherComments,      
  @SalesRepId,      
  @ModifiedBy,      
  @ModifiedDate,    
  @PhoneExt)      
       
 SET @RecJobEntryId = @@IDENTITY      
END