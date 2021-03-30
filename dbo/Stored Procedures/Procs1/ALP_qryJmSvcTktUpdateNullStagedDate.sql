CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateNullStagedDate]                      
 @ProjID varchar(10) ,                    
 @Tickets varchar(4000) ,            
 @StagedDate varchar(22),            
 @ModifiedBy varchar(50) ,           
 @ModifiedDate varchar(22)
 --MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50                     
As                      
SET NOCOUNT ON                  
declare @strSql nvarchar(4000)                  
set @strSql= '                  
UPDATE ALP_tblJmSvcTkt                      
SET ALP_tblJmSvcTkt.StagedDate = NULL,            
ModifiedBy=''' + @ModifiedBy + ''',ModifiedDate=''' + @ModifiedDate +'''            
FROM   ALP_tblJmSvcTkt                    
WHERE ALP_tblJmSvcTkt.StagedDate Is Null and ALP_tblJmSvcTkt.ProjectId ='''+ @ProjID+'''                      
and ALP_tblJmSvcTkt.TicketId in ('+ @Tickets +') '              
              
EXECUTE sp_executesql @strSql