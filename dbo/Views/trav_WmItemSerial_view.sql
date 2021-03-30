
CREATE VIEW dbo.trav_WmItemSerial_view
AS
SELECT s.ItemId, s.SerNum, s.LocId, s.LotNum
	, Case When p.SerNum is null Or p.[Status] = 2 Then s.SerNumStatus Else 9 End SerNumStatus --use 9 as Picked / ignore completed (2) pick entries
	, s.CostUnit, s.PriceUnit, s.InitialDate, s.Cmnt
	, s.[Source], s.ExtLocA, s.ExtLocB
FROM dbo.tblInItemSer s 
	Left Join dbo.tblWmPick p 
	on s.ItemId = p.ItemId and s.LocId = p.LocId and s.SerNum = p.SerNum
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_WmItemSerial_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_WmItemSerial_view';

