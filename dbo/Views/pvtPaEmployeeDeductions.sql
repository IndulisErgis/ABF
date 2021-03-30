
CREATE VIEW dbo.pvtPaEmployeeDeductions
AS

SELECT d.PaYear, d.PaMonth, d.EmployeeId, d.DeductionCode, c.Description
	, CASE WHEN PaMonth = 1 THEN d.Amount ELSE 0 END AS DedAmtJanuary
	, CASE WHEN PaMonth = 2 THEN d.Amount ELSE 0 END AS DedAmtFebruary
	, CASE WHEN PaMonth = 3 THEN d.Amount ELSE 0 END AS DedAmtMarch
	, CASE WHEN PaMonth = 4 THEN d.Amount ELSE 0 END AS DedAmtApril
	, CASE WHEN PaMonth = 5 THEN d.Amount ELSE 0 END AS DedAmtMay
	, CASE WHEN PaMonth = 6 THEN d.Amount ELSE 0 END AS DedAmtJune
	, CASE WHEN PaMonth = 7 THEN d.Amount ELSE 0 END AS DedAmtJuly
	, CASE WHEN PaMonth = 8 THEN d.Amount ELSE 0 END AS DedAmtAugust
	, CASE WHEN PaMonth = 9 THEN d.Amount ELSE 0 END AS DedAmtSeptember
	, CASE WHEN PaMonth = 10 THEN d.Amount ELSE 0 END AS DedAmtOctober
	, CASE WHEN PaMonth = 11 THEN d.Amount ELSE 0 END AS DedAmtNovember
	, CASE WHEN PaMonth = 12 THEN d.Amount ELSE 0 END AS DedAmtDecember 
FROM dbo.tblPaEmpHistDeduct d 
	INNER JOIN dbo.tblPaDeductCode c ON d.DeductionCode = c.DeductionCode
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaEmployeeDeductions';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaEmployeeDeductions';

