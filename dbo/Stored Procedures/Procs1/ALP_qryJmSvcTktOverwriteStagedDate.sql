﻿CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktOverwriteStagedDate]                    
 @ProjID varchar(10) ,                  
 @Tickets varchar(4000) ,          
 @StagedDate  varchar(22),          
 --Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
 @ModifiedBy varchar(50) ,         
 @ModifiedDate varchar(22)                  
As                    
SET NOCOUNT ON                
declare @strSql nvarchar(4000)                
set @strSql= '                
UPDATE ALP_tblJmSvcTkt                    
SET ALP_tblJmSvcTkt.StagedDate = ''' + @StagedDate + ''',          
ModifiedBy=''' + @ModifiedBy + ''',ModifiedDate=''' + @ModifiedDate +'''          
FROM   ALP_tblJmSvcTkt                  
WHERE ALP_tblJmSvcTkt.ProjectId ='''+ @ProjID+'''                    
and ALP_tblJmSvcTkt.TicketId in ('+ @Tickets +') '            
            
EXECUTE sp_executesql @strSql