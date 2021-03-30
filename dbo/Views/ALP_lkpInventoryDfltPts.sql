CREATE VIEW dbo.ALP_lkpInventoryDfltPts AS
SELECT ALP_tblInItemLocation_view.AlpDfltPts,ALP_tblInItem_view.ItemId,
		ALP_tblInItemLocation_view.LocId 
		FROM ALP_tblInItem_view INNER JOIN ALP_tblInItemLocation_view 
		ON ALP_tblInItem_view.ItemId = ALP_tblInItemLocation_view.ItemId