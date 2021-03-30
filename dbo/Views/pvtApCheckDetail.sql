
CREATE VIEW dbo.pvtApCheckDetail
AS

SELECT i.VendorID, v.Name, i.InvoiceNum, i.InvoiceDate, i.GrossAmtDue, i.DiscTaken
FROM dbo.tblApPrepChkInvc i INNER JOIN  dbo.tblApVendor v ON i.VendorID = v.VendorID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApCheckDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApCheckDetail';

