
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateStagedDate]                    
 @ProjID varchar(10) ,                  
 @Tickets varchar(4000) ,          
 @StagedDate varchar(22),          
 @ModifiedBy varchar(16) ,         
 @ModifiedDate varchar(22)                  
As                    
SET NOCOUNT ON                
declare @strSql nvarchar(4000)                
set @strSql= '                
UPDATE ALP_tblJmSvcTkt                    
SET ALP_tblJmSvcTkt.StagedDate = ''' + @StagedDate + ''',          
ModifiedBy=''' + @ModifiedBy + ''',ModifiedDate=''' + @ModifiedDate +'''          
FROM   ALP_tblJmSvcTkt                  
WHERE ALP_tblJmSvcTkt.StagedDate Is Null and ALP_tblJmSvcTkt.ProjectId ='''+ @ProjID+'''                    
and ALP_tblJmSvcTkt.TicketId in ('+ @Tickets +') '            
            
EXECUTE sp_executesql @strSql