  
  
CREATE PROCEDURE [dbo].[ALP_qryJmSvcGetProjectTickets]                                    
@Tickets varchar(4000)                               
As                                    
SET NOCOUNT ON                               
declare @strSql nvarchar(4000)                
                               
set @strSql= '                            
Select * from ALP_tblJmSvcTkt                                   
WHERE ALP_tblJmSvcTkt.TicketId in ('+ @Tickets +')'                 
               
                 
EXECUTE sp_executesql @strSql