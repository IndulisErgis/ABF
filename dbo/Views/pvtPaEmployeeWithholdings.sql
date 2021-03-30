
CREATE VIEW dbo.pvtPaEmployeeWithholdings
AS

SELECT w.PaYear, w.PaMonth, w.EmployeeId, h.TaxAuthority, w.WithholdingCode
	, CASE WHEN PaMonth = 1 THEN w.WithholdAmount ELSE 0 END AS WithholdJanuary
	, CASE WHEN PaMonth = 2 THEN w.WithholdAmount ELSE 0 END AS WithholdFebruary
	, CASE WHEN PaMonth = 3 THEN w.WithholdAmount ELSE 0 END AS WithholdMarch
	, CASE WHEN PaMonth = 4 THEN w.WithholdAmount ELSE 0 END AS WithholdApril
	, CASE WHEN PaMonth = 5 THEN w.WithholdAmount ELSE 0 END AS WithholdMay
	, CASE WHEN PaMonth = 6 THEN w.WithholdAmount ELSE 0 END AS WithholdJune
	, CASE WHEN PaMonth = 7 THEN w.WithholdAmount ELSE 0 END AS WithholdJuly
	, CASE WHEN PaMonth = 8 THEN w.WithholdAmount ELSE 0 END AS WithholdAugust
	, CASE WHEN PaMonth = 9 THEN w.WithholdAmount ELSE 0 END AS WithholdSeptember
	, CASE WHEN PaMonth = 10 THEN w.WithholdAmount ELSE 0 END AS WithholdOctober
	, CASE WHEN PaMonth = 11 THEN w.WithholdAmount ELSE 0 END AS WithholdNovember
	, CASE WHEN PaMonth = 12 THEN w.WithholdAmount ELSE 0 END AS WithholdDecember 
FROM dbo.tblPaEmpHistWithhold w 
	LEFT JOIN dbo.tblPaTaxAuthorityHeader h ON w.TaxAuthorityType = h.Type 
		AND ISNULL(w.State, '') = ISNULL(h.State, '') AND ISNULL(w.Local, '') = ISNULL(h.Local, '')
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaEmployeeWithholdings';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaEmployeeWithholdings';

