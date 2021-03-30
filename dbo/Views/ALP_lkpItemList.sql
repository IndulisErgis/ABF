CREATE VIEW dbo.ALP_lkpItemList AS
SELECT [ALP_tblInItem_view].[ItemId] as ItemCode, [ALP_tblInItem_view].[Descr] as [Desc], 
[ALP_tblInItemLocation_view].[AlpDfltPts], [ALP_tblInItem_view].[ItemType], [ALP_tblInItemLocation_view].[GLAcctCode], 
[ALP_tblInItemLocation_view].[LocId], [ALP_tblInItem_view].[AlpServiceType],[ALP_tblInItemLocation_view].ItemLocStatus,
 [ALP_tblInItem_view].SuperId, [ALP_tblInItem_view].[UomDflt] FROM ALP_tblInItem_view INNER JOIN ALP_tblInItemLocation_view ON [ALP_tblInItem_view].[ItemId]=[ALP_tblInItemLocation_view].[ItemId]