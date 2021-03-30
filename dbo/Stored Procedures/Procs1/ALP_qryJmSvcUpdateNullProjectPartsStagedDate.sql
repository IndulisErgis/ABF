CREATE PROCEDURE dbo.ALP_qryJmSvcUpdateNullProjectPartsStagedDate                                  
 @StagedDate varchar(10) =null,                                
 @ModifiedBy varchar(16),                        
 @ModifiedDate varchar(22) ,            
 @TicketItemId varchar(4000)                             
As                                  
SET NOCOUNT ON                              
declare @strSql nvarchar(4000)                              
set @strSql= '                              
UPDATE ALP_tblJmSvcTktItem                                  
SET ALP_tblJmSvcTktItem.StagedDate = NULL ,                        
ALP_tblJmSvcTktItem.ModifiedBy = ''' + @ModifiedBy + ''',                        
ALP_tblJmSvcTktItem.ModifiedDate = ''' + @ModifiedDate + '''                           
WHERE ALP_tblJmSvcTktItem.TicketItemId in ('+ @TicketItemId +')'                          
                          
EXECUTE sp_executesql @strSql