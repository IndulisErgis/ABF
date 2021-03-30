
CREATE VIEW dbo.ALP_lkpJmTimeCard AS SELECT Min(StartDate) AS StDate,TicketId FROM dbo.ALP_tblJmTimeCard  GROUP BY StartDate,TicketId