  
  
CREATE PROCEDURE [dbo].[ALP_qryJmSvcGetProjectPartItems]                                    
@TicketItemId varchar(4000)                               
As                                    
SET NOCOUNT ON                               
declare @strSql nvarchar(4000)                
                               
set @strSql= '                            
Select * from ALP_tblJmSvcTktItem                                    
WHERE ALP_tblJmSvcTktItem.TicketItemId in ('+ @TicketItemId +')'                 
               
                 
EXECUTE sp_executesql @strSql