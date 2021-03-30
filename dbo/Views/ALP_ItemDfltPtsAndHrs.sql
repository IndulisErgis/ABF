CREATE VIEW dbo.ALP_ItemDfltPtsAndHrs AS  
SELECT ALP_tblInItemLocation_view.AlpDfltCommercialPts  , AlpCopyToListYn, AlpPanelYN,
 ALP_tblInItem_view.KittedYN ,   GLAcctCode, ALP_tblInItemLocation_view.AlpDfltCommercialHours ,
  AlpVendorKitYn, ALP_tblInItem_view.UomDflt, AlpPrintOnInvoice,ALP_tblInItem_view.ItemId,
  ALP_tblInItemLocation_view.LocId ,ALP_tblInItemLocation_view.AlpDfltPts,ALP_tblInItemLocation_view.AlpDfltHours
 FROM ALP_tblInItem_view INNER JOIN ALP_tblInItemLocation_view 
 ON ALP_tblInItem_view.ItemId = ALP_tblInItemLocation_view.ItemId