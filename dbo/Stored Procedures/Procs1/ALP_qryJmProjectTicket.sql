
CREATE PROCEDURE [dbo].[ALP_qryJmProjectTicket]                                      
 @ProjectId varchar(10)                             
                                    
As                         
                                 
Select  ALP_tblJmSvcTkt.*,ALP_tblArAlpSiteSys.SysDesc,ALP_tblJmWorkCode.WorkCode    
from  ALP_tblJmSvcTkt     
Left Outer Join ALP_tblArAlpSiteSys ON  ALP_tblJmSvcTkt.SysId=ALP_tblArAlpSiteSys.SysId    
INNER JOIN dbo.ALP_tblJmWorkCode ON dbo.ALP_tblJmSvcTkt.WorkCodeId = dbo.ALP_tblJmWorkCode.WorkCodeId          
where ProjectId=@ProjectId and Status <> 'Completed' and Status <> 'Cancelled' and Status<>'Closed' 
and Status <> 'Canceled'