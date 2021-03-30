
CREATE VIEW dbo.ALP_stpJm0003SvcActionsOtherItems
AS
SELECT     TicketId, ROUND(SUM(Price * Qty), 2) AS OtherPriceExt, ROUND(SUM(Cost * Qty), 0) AS OtherCostExt
FROM         dbo.ALP_stpJm0001SvcActionsAll
WHERE     (Type = 'Other')
GROUP BY TicketId