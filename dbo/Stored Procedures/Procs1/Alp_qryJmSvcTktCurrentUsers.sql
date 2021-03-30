
Create PROCEDURE [dbo].[Alp_qryJmSvcTktCurrentUsers]     
 @TicketID int    
As    
SET NOCOUNT ON    
SELECT *   
FROM ALP_tblJmSvcTktCurrentUsers
WHERE ALP_tblJmSvcTktCurrentUsers.TicketId = @TicketID