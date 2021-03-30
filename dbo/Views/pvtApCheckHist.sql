
CREATE VIEW dbo.pvtApCheckHist
AS

SELECT c.VendorID, v.Name, c.CheckNum, c.CheckDate, c.GrossAmtDue, c.DiscTaken, 
	CASE WHEN c.VoidYn = 0 THEN 'Not Voided' ELSE 'Voided' END AS [VoidStat$]
FROM dbo.tblApCheckHist c INNER JOIN dbo.tblApVendor v ON c.VendorID = v.VendorID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApCheckHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApCheckHist';

