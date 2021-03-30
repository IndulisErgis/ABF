
CREATE VIEW dbo.trav_WmReceiveGoodsDocument_view
AS
	SELECT TransId, 0 AS [Source], VendorId AS [ContactId] FROM dbo.tblPoTransHeader WHERE TransType > 0 
	UNION 
	SELECT ISNULL(PackNum, BatchId), 1, NULL FROM dbo.tblWmTransfer WHERE [Status] IN (0, 1) GROUP BY ISNULL(PackNum, BatchId)
	UNION 
	SELECT ReqNum, 8, ReqstdBy FROM dbo.tblWmMatReq WHERE ReqType = -1 GROUP BY ReqNum, ReqstdBy
	UNION
	SELECT ISNULL(InvcNum, TransId), 16, NULL FROM dbo.tblSoTransHeader WHERE TransType = -2 AND [VoidYn] = 0 GROUP BY ISNULL(InvcNum, TransId)
	UNION
	SELECT p.ProjectName, 32, p.CustId
		FROM dbo.tblPcTrans t 
		INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		WHERE t.TransType = 1 --Material Return
		GROUP BY p.ProjectName, p.CustId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_WmReceiveGoodsDocument_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_WmReceiveGoodsDocument_view';

