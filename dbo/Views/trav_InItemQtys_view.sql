

CREATE VIEW [dbo].[trav_InItemQtys_view]
AS
-- SXP altered View to add inner join and check condition on 06/23/2020
SELECT i.ItemId,LocId,Sum(CASE WHEN TransType=0 AND tt.TicketId IS NOT NULL THEN Qty ELSE 0 END ) AS QtyCmtd, -- added 'AND tt.TicketId IS NOT NULL' on 06/23/2020
	Sum(CASE WHEN TransType=2 THEN Qty ELSE 0 END ) AS QtyOnOrder,
	Sum(CASE WHEN TransType=1 THEN Qty ELSE 0 END ) AS QtyInUse
FROM dbo.tblInQty i
LEFT OUTER JOIN  [ALP_tblJmSvcTktItem] tt on tt.ticketitemid = i.linkidSub -- added on 06/23/2020
GROUP BY i.ItemId,LocId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemQtys_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemQtys_view';

