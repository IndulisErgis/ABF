CREATE VIEW dbo.ALP_lkpCommercialPts AS  
SELECT ALP_tblInItemLocation_view.AlpDfltCommercialPts as Points, AlpCopyToListYn, AlpPanelYN, ALP_tblInItem_view.KittedYN ,  
 GLAcctCode, ALP_tblInItemLocation_view.AlpDfltCommercialHours as Hours, AlpVendorKitYn, ALP_tblInItem_view.UomDflt, AlpPrintOnInvoice,
 ALP_tblInItem_view.ItemId,ALP_tblInItemLocation_view.LocId  
 ,ALP_tblInItemLocation_view.DfltBinNum --DfltBinNum added by NSK on 10 Jul 2020 for bug id 1067
 FROM ALP_tblInItem_view INNER JOIN ALP_tblInItemLocation_view ON 
 ALP_tblInItem_view.ItemId = ALP_tblInItemLocation_view.ItemId