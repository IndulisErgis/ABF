
      
CREATE PROCEDURE [dbo].[ALP_qryJmSvcUpdateNullProjectBackOrderDate]                             
 @ProjectID varchar(10), @BoDate varchar(22) =null,                            
 @Tickets varchar(4000) ,                    
 @ModifiedBy varchar(16),                    
 @ModifiedDate varchar(22)       
                    
As                              
SET NOCOUNT ON                          
declare @strSql nvarchar(4000)                          
set @strSql= '                          
UPDATE ALP_tblJmSvcTkt                              
SET ALP_tblJmSvcTkt.BoDate = NULL ,                    
ALP_tblJmSvcTkt.ModifiedBy = ''' + @ModifiedBy + ''',                    
ALP_tblJmSvcTkt.ModifiedDate = ''' + @ModifiedDate + '''                       
WHERE (ALP_tblJmSvcTkt.BoDate is null or ALP_tblJmSvcTkt.BoDate='''') and ALP_tblJmSvcTkt.ProjectId ='''+ @ProjectID+'''       
and ALP_tblJmSvcTkt.TicketId in ('+ @Tickets +')'                      
                      
EXECUTE sp_executesql @strSql