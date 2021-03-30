
CREATE PROCEDURE  [dbo].[UpdateSvcTktItemSysItemId] (@pTicketitemId INT,@pModifiedBy VARCHAR (50))AS  
BEGIN  
DECLARE @sysid INT;  
DECLARE @itemid pItemID;  
DECLARE @sysItemid INT;  
--Below select itemid and sysid query commentted by ravi on 19 march 2020, the below query is taking long time to execute
 --START 19 march 2020
 -- SELECT  @itemid=itemid,@sysid=b.sysid FROM ALP_tblJmSvcTktItem a INNER JOIN aLP_tblJmSvcTkt b on a.ticketid =b.ticketId  
--print(@itemid)   
--print(@sysid)   
--SELECT  @sysItemid=SysItemId  FROM ALP_tblArAlpSiteSysItem WHERE sysId =@sysid and itemid =@itemid  
--print(@sysItemid) 
--END 19 march 2020
SELECT  @itemid=itemid FROM ALP_tblJmSvcTktItem Where TicketItemId= @pTicketitemId
SELECT @sysid =sysId FROM ALP_tblJmSvcTkt a inner join ALP_tblJmSvcTktItem b  on a.TicketId=b.TicketId  Where TicketItemId= @pTicketitemId
SELECT  @sysItemid=SysItemId  FROM ALP_tblArAlpSiteSysItem WHERE sysId =@sysid and itemid =@itemid  
UPDATE  ALP_tblJmSvcTktItem  SET SysItemId= @sysItemid,ModifiedBy= @pModifiedBy WHERE ItemId =@itemid and ticketitemid= @pTicketitemId  
END