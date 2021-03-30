CREATE PROCEDURE [dbo].[ALP_qryJmSvcUpdateProjectPartsStagedDate]                              
 @StagedDate datetime ,                            
 @ModifiedBy varchar(50),                    
 @ModifiedDate varchar(22),              
 @TicketItemId varchar(4000) 
 --MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50                              
As                              
SET NOCOUNT ON                          
declare @strSql nvarchar(4000)                          
set @strSql= '                          
UPDATE ALP_tblJmSvcTktItem                              
SET ALP_tblJmSvcTktItem.StagedDate = ''' + CONVERT(varchar(10),@StagedDate,101) + ''' ,                    
ALP_tblJmSvcTktItem.ModifiedBy = ''' + @ModifiedBy + ''',                    
ALP_tblJmSvcTktItem.ModifiedDate = ''' + @ModifiedDate + '''                       
WHERE ALP_tblJmSvcTktItem.StagedDate Is Null 
and ALP_tblJmSvcTktItem.TicketItemId in ('+ @TicketItemId +')'                      
                      
EXECUTE sp_executesql @strSql