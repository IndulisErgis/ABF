CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateInstallPullDate]    
 @ID int, @PullDate datetime,  
  --Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017 
 @ModifiedBy varchar(50),  
 @ModifiedDate datetime  
   
As    
SET NOCOUNT ON    
UPDATE ALP_tblJmSvcTktItem    
SET ALP_tblJmSvcTktItem.PartPulledDate = @PullDate,  
--Below line added by NSK on 12 Nov 2014  
ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate   
FROM  ALP_tblJmResolution INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId     
WHERE ALP_tblJmSvcTktItem.PartPulledDate Is Null AND ALP_tblJmSvcTktItem.TicketId = @ID AND (ALP_tblJmResolution.[Action] ='Add' Or ALP_tblJmResolution.[Action] ='Replace')