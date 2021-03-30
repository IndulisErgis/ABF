
CREATE PROCEDURE [dbo].[ALP_qryJmSvcProjOverwritePickListBODate]                    
 @ProjectID varchar(10) ,                  
 @Tickets varchar(4000) ,          
 @BODate varchar(22),   
 --Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017       
 @ModifiedBy varchar(50) ,
 @ModifiedDate varchar(22)                  
As                    
SET NOCOUNT ON                
declare @strSql nvarchar(4000)                
set @strSql= '                
UPDATE ALP_tblJmSvcTkt                    
SET ALP_tblJmSvcTkt.BoDate = ''' + @BoDate + ''',          
ModifiedBy=''' + @ModifiedBy + ''',ModifiedDate=''' + @ModifiedDate +'''          
FROM   ALP_tblJmSvcTkt                  
WHERE  ALP_tblJmSvcTkt.ProjectId ='''+ @ProjectID+'''                    
and ALP_tblJmSvcTkt.TicketId in ('+ @Tickets +') '            
            
EXECUTE sp_executesql @strSql