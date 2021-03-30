
--Modified by NSK on 29 Jan 2015 TicketItemId is used instead of ItemId in where clause
CREATE PROCEDURE [dbo].[ALP_qryJmSvcUpdateProjectInstallPullDate]                      
 @ID varchar(10),     
 @PullDate datetime ,                    
 @Tickets varchar(4000) ,            
 @ModifiedBy varchar(16),            
 @ModifiedDate varchar(22),      
 @TicketItemId varchar(4000)                      
As                      
SET NOCOUNT ON                  
declare @strSql nvarchar(4000)                  
set @strSql= '                  
UPDATE ALP_tblJmSvcTktItem                      
SET ALP_tblJmSvcTktItem.PartPulledDate = ''' + CONVERT(varchar(10),@PullDate,101) + ''' ,            
ALP_tblJmSvcTktItem.ModifiedBy = ''' + @ModifiedBy + ''',            
ALP_tblJmSvcTktItem.ModifiedDate = ''' + @ModifiedDate + '''               
FROM  ALP_tblJmResolution INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId                       
inner join ALP_tblJmSvcTkt on ALP_tblJmSvcTktItem.TicketId=ALP_tblJmSvcTkt.TicketId                    
WHERE ALP_tblJmSvcTktItem.PartPulledDate Is Null AND ALP_tblJmSvcTkt.ProjectId ='''+ @ID+''' AND (ALP_tblJmResolution.[Action] =''Add'' Or ALP_tblJmResolution.[Action] =''Replace'')                      
and ALP_tblJmSvcTktItem.TicketId in ('+ @Tickets +')       
and ALP_tblJmSvcTktItem.TicketItemId in ('+ @TicketItemId +')'              
              
EXECUTE sp_executesql @strSql