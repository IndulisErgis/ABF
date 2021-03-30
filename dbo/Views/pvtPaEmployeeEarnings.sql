
CREATE VIEW dbo.pvtPaEmployeeEarnings
AS

SELECT e.PaYear, e.PaMonth, e.EmployeeId, e.EarningCode
	, CASE WHEN PaMonth = 1 THEN e.Hours ELSE 0 END AS HoursJanuary
	, CASE WHEN PaMonth = 2 THEN e.Hours ELSE 0 END AS HoursFebruary
	, CASE WHEN PaMonth = 3 THEN e.Hours ELSE 0 END AS HoursMarch
	, CASE WHEN PaMonth = 4 THEN e.Hours ELSE 0 END AS HoursApril
	, CASE WHEN PaMonth = 5 THEN e.Hours ELSE 0 END AS HoursMay
	, CASE WHEN PaMonth = 6 THEN e.Hours ELSE 0 END AS HoursJune
	, CASE WHEN PaMonth = 7 THEN e.Hours ELSE 0 END AS HoursJuly
	, CASE WHEN PaMonth = 8 THEN e.Hours ELSE 0 END AS HoursAugust
	, CASE WHEN PaMonth = 9 THEN e.Hours ELSE 0 END AS HoursSeptember
	, CASE WHEN PaMonth = 10 THEN e.Hours ELSE 0 END AS HoursOctober
	, CASE WHEN PaMonth = 11 THEN e.Hours ELSE 0 END AS HoursNovember
	, CASE WHEN PaMonth = 12 THEN e.Hours ELSE 0 END AS HoursDecember
	, CASE WHEN PaMonth = 1 THEN e.Amount ELSE 0 END AS AmountJanuary
	, CASE WHEN PaMonth = 2 THEN e.Amount ELSE 0 END AS AmountFebruary
	, CASE WHEN PaMonth = 3 THEN e.Amount ELSE 0 END AS AmountMarch
	, CASE WHEN PaMonth = 4 THEN e.Amount ELSE 0 END AS AmountApril
	, CASE WHEN PaMonth = 5 THEN e.Amount ELSE 0 END AS AmountMay
	, CASE WHEN PaMonth = 6 THEN e.Amount ELSE 0 END AS AmountJune
	, CASE WHEN PaMonth = 7 THEN e.Amount ELSE 0 END AS AmountJuly
	, CASE WHEN PaMonth = 8 THEN e.Amount ELSE 0 END AS AmountAugust
	, CASE WHEN PaMonth = 9 THEN e.Amount ELSE 0 END AS AmountSeptember
	, CASE WHEN PaMonth = 10 THEN e.Amount ELSE 0 END AS AmountOctober
	, CASE WHEN PaMonth = 11 THEN e.Amount ELSE 0 END AS AmountNovember
	, CASE WHEN PaMonth = 12 THEN e.Amount ELSE 0 END AS AmountDecember
	, c.Description AS [Description] 
FROM dbo.tblPaEmpHistEarn e 
	INNER JOIN dbo.tblPaEarnCode c ON e.EarningCode = c.Id
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaEmployeeEarnings';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaEmployeeEarnings';

