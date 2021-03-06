CREATE PROCEDURE [dbo].[ALP_qryJmSvcUpdateProjectPartsMoveToTickets]                                
   
@NewTicketId varchar(10) ,              
@ModifiedBy varchar(50),                      
@ModifiedDate varchar(22),              
@TicketItemId varchar(4000)   
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50                         
As                                
SET NOCOUNT ON                           
declare @strSql nvarchar(4000)            
                           
set @strSql= '                        
UPDATE ALP_tblJmSvcTktItem                                
SET ALP_tblJmSvcTktItem.TicketId = '''+ @NewTicketId +''', ALP_tblJmSvcTktItem.OldTicketId=ALP_tblJmSvcTktItem.TicketId,                     
ALP_tblJmSvcTktItem.ModifiedDate = '''+ @ModifiedDate +''' ,                                  
ALP_tblJmSvcTktItem.ModifiedBy = '''+ @ModifiedBy +'''                       
WHERE ALP_tblJmSvcTktItem.TicketItemId in ('+ @TicketItemId +')'             
           
             
EXECUTE sp_executesql @strSql