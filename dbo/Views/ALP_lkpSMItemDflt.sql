CREATE VIEW dbo.ALP_lkpSMItemDflt AS
SELECT AlpDfltPts, AlpCopyToListYN, AlpPanelYN, AlpKittedYN, AlpDfltHours, AlpVendorKitYn,Units,ItemCode
 FROM ALP_tblSmItem_view