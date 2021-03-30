CREATE VIEW dbo.ALP_lkpReplaceSMItem AS
SELECT ItemCode as ItemId, [Desc] as Descr, AlpDfltPts FROM ALP_tblSmItem_view