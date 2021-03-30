
CREATE PROCEDURE [dbo].[ALP_qryRptJmProjectPickListItems]        
 @ID varchar(10),    
 @Tickets varchar(4000)        
As        
SET NOCOUNT ON    
declare @strSql nvarchar(4000)    
set @strSql= '    
Select * from ALP_rptJmProjectPickListItems 
where ProjectId='''+ @ID+''' and 
TicketId in('+@Tickets+')'

EXECUTE sp_executesql @strSql