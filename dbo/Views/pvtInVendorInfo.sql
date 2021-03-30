
CREATE VIEW dbo.pvtInVendorInfo
AS

SELECT LocId, ItemId, VendId, VendName, LastPODate, BrkId, LastPOUnitCost, LastPOQty, LeadTime
FROM dbo.tblInItemLocVend
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInVendorInfo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInVendorInfo';

