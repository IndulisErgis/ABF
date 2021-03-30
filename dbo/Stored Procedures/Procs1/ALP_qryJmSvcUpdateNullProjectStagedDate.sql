CREATE PROCEDURE dbo.ALP_qryJmSvcUpdateNullProjectStagedDate                                
 @ID varchar(10), @StagedDate varchar(10) =null,                              
 @Tickets varchar(4000) ,                      
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
FROM  ALP_tblJmResolution INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId                                 
inner join ALP_tblJmSvcTkt on ALP_tblJmSvcTktItem.TicketId=ALP_tblJmSvcTkt.TicketId                              
WHERE ALP_tblJmSvcTkt.ProjectId ='''+ @ID+''' AND (ALP_tblJmResolution.[Action] =''Add'' Or ALP_tblJmResolution.[Action] =''Replace'')                                
and ALP_tblJmSvcTktItem.TicketId in ('+ @Tickets +')           
and ALP_tblJmSvcTktItem.TicketItemId in ('+ @TicketItemId +')'                        
                        
EXECUTE sp_executesql @strSql