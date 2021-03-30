Create PROCEDURE [dbo].[ALP_qryIMPReplaceSvcTicketKitInfo](@pTicketId int,@pTicketItemId int, @pKitLineNumber varchar(250),@pKitRef int)
  AS
  BEGIN
  UPDATE ALP_tblJmSvcTktItem  SET LineNumber =@pKitLineNumber,KitRef=@pKitRef
  WHERE TicketId =@pTicketId AND TicketItemId =@pTicketItemId 
  END