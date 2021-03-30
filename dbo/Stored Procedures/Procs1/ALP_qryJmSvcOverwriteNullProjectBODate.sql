  
CREATE PROCEDURE [dbo].[ALP_qryJmSvcOverwriteNullProjectBODate]                         
 @ProjectID varchar(10), @BoDate varchar(22) =null,                        
 @Tickets varchar(4000) ,  
 --Below @Modified  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017              
 @ModifiedBy varchar(50),                
 @ModifiedDate varchar(22)   
                
As                          
SET NOCOUNT ON                      
declare @strSql nvarchar(4000)                      
set @strSql= '                      
UPDATE ALP_tblJmSvcTkt                          
SET ALP_tblJmSvcTkt.BoDate = NULL ,                
ALP_tblJmSvcTkt.ModifiedBy = ''' + @ModifiedBy + ''',                
ALP_tblJmSvcTkt.ModifiedDate = ''' + @ModifiedDate + '''                   
WHERE ALP_tblJmSvcTkt.ProjectId ='''+ @ProjectID+'''   
and ALP_tblJmSvcTkt.TicketId in ('+ @Tickets +')'                  
                  
EXECUTE sp_executesql @strSql