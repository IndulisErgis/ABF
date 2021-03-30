    
CREATE PROCEDURE  UpdateSvcTktItemRepSysItemId (@pSysItemId INT,@pTicketitemId INT,@pModifiedBy VARCHAR (50))AS    
BEGIN    
UPDATE  ALP_tblJmSvcTktItem  SET SysItemId= @pSysItemId,ModifiedBy= @pModifiedBy WHERE ticketitemid= @pTicketitemId    
END