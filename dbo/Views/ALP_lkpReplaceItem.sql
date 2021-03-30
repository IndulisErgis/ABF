
CREATE VIEW dbo.ALP_lkpReplaceItem AS
SELECT ItemId,[Desc] as Descr, SerNum, EquipLoc,WarrExpires, Qty, SysItemId,SysId,RemoveYN
 FROM dbo.ALP_tblArAlpSiteSysItem