
CREATE VIEW dbo.ALP_stpJmSvcTktProjectJobsHrs
AS
SELECT     TicketId, SUM((EndTime - StartTime) / 60.00) AS ActualHrs
FROM         dbo.ALP_tblJmTimeCard
GROUP BY TicketId
HAVING      (TicketId IS NOT NULL)