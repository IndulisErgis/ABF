
CREATE VIEW dbo.ALP_stpJmSvcTktProjectJobsEstHrs
AS
SELECT     TicketId, ROUND(SUM(UnitHrs * Qty), 2) AS EstHrs
FROM         dbo.ALP_stpJm0001SvcActionsAll
GROUP BY TicketId