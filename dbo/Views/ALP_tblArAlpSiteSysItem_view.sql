CREATE VIEW dbo.ALP_tblArAlpSiteSysItem_view
AS
SELECT     dbo.ALP_tblArAlpSiteSysItem.SysItemId, dbo.ALP_tblArAlpSiteSysItem.SysId, dbo.ALP_tblArAlpSiteSysItem.ItemId, dbo.ALP_tblArAlpSiteSysItem.[Desc], 
                      dbo.ALP_tblArAlpSiteSysItem.LocId, dbo.ALP_tblArAlpSiteSysItem.PanelYN, dbo.ALP_tblArAlpSiteSysItem.SerNum, dbo.ALP_tblArAlpSiteSysItem.EquipLoc, 
                      dbo.ALP_tblArAlpSiteSysItem.Qty, dbo.ALP_tblArAlpSiteSysItem.UnitCost, dbo.ALP_tblArAlpSiteSysItem.WarrPlanId, dbo.ALP_tblArAlpSiteSysItem.WarrTerm, 
                      dbo.ALP_tblArAlpSiteSysItem.WarrStarts, dbo.ALP_tblArAlpSiteSysItem.WarrExpires, dbo.ALP_tblArAlpSiteSysItem.Comments, 
                      dbo.ALP_tblArAlpSiteSysItem.RemoveYN, dbo.ALP_tblArAlpSiteSysItem.Zone, dbo.ALP_tblArAlpSiteSysItem.TicketId, dbo.ALP_tblArAlpSiteSysItem.WorkOrderId, 
                      dbo.ALP_tblArAlpSiteSysItem.RepPlanId, dbo.ALP_tblArAlpSiteSysItem.LeaseYN, dbo.ALP_tblArAlpSiteSysItem.ts, dbo.ALP_tblArAlpSiteSysItem.ModifiedBy, 
                      dbo.ALP_tblArAlpSiteSysItem.ModifiedDate, dbo.ALP_tblArAlpSiteSys.SysDesc, dbo.ALP_tblArAlpSysType.SysType, dbo.ALP_tblArAlpSiteSys.SiteId, 
                      dbo.ALP_tblArAlpSysType.SysTypeId
FROM         dbo.ALP_tblArAlpSysType RIGHT OUTER JOIN
                      dbo.ALP_tblArAlpSiteSys ON dbo.ALP_tblArAlpSysType.SysTypeId = dbo.ALP_tblArAlpSiteSys.SysTypeId RIGHT OUTER JOIN
                      dbo.ALP_tblArAlpSiteSysItem ON dbo.ALP_tblArAlpSiteSys.SysId = dbo.ALP_tblArAlpSiteSysItem.SysId