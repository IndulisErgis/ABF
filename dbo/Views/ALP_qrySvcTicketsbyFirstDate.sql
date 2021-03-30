
CREATE VIEW [dbo].[ALP_qrySvcTicketsbyFirstDate]  
AS  
SELECT     TicketId, MIN(StartDate) AS FirstDate ,MAX(EndDate)  as EndDate
FROM         dbo.ALP_tblJmTimeCard  
GROUP BY TicketId  
HAVING      (NOT (TicketId IS NULL))