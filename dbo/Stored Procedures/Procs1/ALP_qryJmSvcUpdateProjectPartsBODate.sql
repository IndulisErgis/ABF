CREATE PROCEDURE dbo.ALP_qryJmSvcUpdateProjectPartsBODate                                
 @BODate datetime ,                              
 @ModifiedBy varchar(16),                      
 @ModifiedDate varchar(22),                
 @TicketItemId varchar(4000)                                
As                                
SET NOCOUNT ON                            
declare @strSql nvarchar(4000)                            
set @strSql= '                            
UPDATE ALP_tblJmSvcTktItem                                
SET ALP_tblJmSvcTktItem.BODate = ''' + CONVERT(varchar(10),@BODate,101) + ''' ,                      
ALP_tblJmSvcTktItem.ModifiedBy = ''' + @ModifiedBy + ''',                      
ALP_tblJmSvcTktItem.ModifiedDate = ''' + @ModifiedDate + '''                         
WHERE ALP_tblJmSvcTktItem.BODate Is Null   
and ALP_tblJmSvcTktItem.TicketItemId in ('+ @TicketItemId +')'                        
                        
EXECUTE sp_executesql @strSql