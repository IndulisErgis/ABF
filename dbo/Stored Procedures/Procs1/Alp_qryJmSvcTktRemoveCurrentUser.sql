
Create PROCEDURE [dbo].[Alp_qryJmSvcTktRemoveCurrentUser]     
 @TicketID int    
As    
SET NOCOUNT ON    
Delete    
FROM ALP_tblJmSvcTktCurrentUsers
WHERE ALP_tblJmSvcTktCurrentUsers.TicketId = @TicketID