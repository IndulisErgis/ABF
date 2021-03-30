
CREATE VIEW [dbo].[trav_ArRecurrEntry_view]
AS

	SELECT  c.CustId, CustName, ClassId, GroupCode, AcctType, PriceCode, c.DistCode, TerrId, c.CustLevel, [Status],
			RecurID, RunCode, EndingDate
	FROM  dbo.tblArCust c INNER JOIN dbo.tblArRecurHeader   r ON c.CustId = r.CustId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArRecurrEntry_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArRecurrEntry_view';

