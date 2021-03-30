
CREATE VIEW dbo.pvtInMatReq
AS

SELECT d.LocId, d.ItemId, h.TransId, h.ReqNum, d.Descr, d.UomBase, d.QtyReqstd, d.QtyFilled, d.CostUnitStd,
	CASE WHEN h.ReqType = 1 THEN 'Requisition' ELSE 'Requisition Return' END AS [ReqType] 
FROM dbo.tblInMatReqHeader h INNER JOIN dbo.tblInMatReqDetail d ON h.TransId = d.TransId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInMatReq';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInMatReq';

