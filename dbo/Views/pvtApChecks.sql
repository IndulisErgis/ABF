
CREATE VIEW dbo.pvtApChecks
AS

SELECT c.VendorID, c.DiscLost, c.DiscTaken, c.CheckAmt, c.CheckDate, c.[Counter], v.Name
FROM dbo.tblApPrepChkCheck c INNER JOIN dbo.tblApVendor v ON c.VendorID = v.VendorID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApChecks';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApChecks';

