
CREATE VIEW dbo.ALP_stpJmSvcTktItemsCompleteJob AS
 SELECT dbo.ALP_tblJmSvcTktItem.SysItemId, dbo.ALP_tblJmSvcTkt.SysId, dbo.ALP_tblJmSvcTktItem.ItemId,
 dbo.ALP_tblJmSvcTktItem.[Desc], dbo.ALP_tblJmSvcTktItem.SerNum, dbo.ALP_tblJmSvcTktItem.EquipLoc, CASE WHEN [Action] = 'Remove' 
THEN QtyRemoved WHEN [Action] = 'Service' THEN QtyServiced ELSE QtyAdded END AS Qty,
 ALP_tblJmSvcTktItem.UnitCost, ALP_tblJmSvcTktItem.Comments, ALP_tblJmSvcTktItem.Zone, ALP_tblJmSvcTkt.TicketId,
 CASE WHEN WarrExpDate IS NULL AND WarrTerm = 0 THEN InstallDate WHEN WarrExpDate IS NULL AND WarrTerm <> 0 
THEN DateAdd(month, [WarrTerm], [InstallDate]) ELSE WarrExpDate END AS ExpDate, CASE WHEN WarrTerm IS NOT NULL THEN 
WarrTerm ELSE 0 END AS Term, ALP_tblArAlpSiteSys.InstallDate, ALP_tblJmSvcTktItem.WhseID, ALP_tblJmSvcTktItem.PanelYN, 
ALP_tblJmSvcTkt.LseYn, ALP_tblArAlpSiteSys.RepPlanId, ALP_tblArAlpSiteSys.WarrPlanId, [Action], KittedYn,
 ALP_tblJmSvcTktItem.AlpVendorKitYn ,ALP_tblJmSvcTktItem.TicketItemId 
FROM dbo.ALP_tblJmResolution INNER JOIN dbo.ALP_tblJmSvcTkt INNER JOIN dbo.ALP_tblArAlpSiteSys ON 
dbo.ALP_tblJmSvcTkt.SysId = dbo.ALP_tblArAlpSiteSys.SysId INNER JOIN dbo.ALP_tblJmSvcTktItem ON 
dbo.ALP_tblJmSvcTkt.TicketId = dbo.ALP_tblJmSvcTktItem.TicketId ON 
dbo.ALP_tblJmResolution.ResolutionId = dbo.ALP_tblJmSvcTktItem.ResolutionId WHERE CopyToYn = 1