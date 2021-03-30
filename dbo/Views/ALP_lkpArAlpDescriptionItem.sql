CREATE VIEW dbo.ALP_lkpArAlpDescriptionItem
AS
SELECT     ItemCode, [Desc], GLAcctExp, GLAcctSales, GLAcctCogs, GLAcctInv, TaxClass, Units, UnitCost, UnitPrice, AddnlDesc, AlpDfltHours, AlpDfltPts, 
                      AlpPrintProposalYn, AlpCopyToListYn, AlpPhaseCodeID, AlpServiceType, AlpAcctCode
FROM         dbo.ALP_tblSmItem_view