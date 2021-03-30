
CREATE VIEW [dbo].[trav_ApRecurrEntry_view]
AS

	SELECT  v.VendorID, Name, PriorityCode, VendorHoldYN, VendorClass, DivisionCode, v.DistCode, [Status],
			RecurID, RunCode, EndingDate
	FROM  dbo.tblApVendor v INNER JOIN dbo.tblApRecurHeader  r ON v.VendorID = r.VendorID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApRecurrEntry_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApRecurrEntry_view';

