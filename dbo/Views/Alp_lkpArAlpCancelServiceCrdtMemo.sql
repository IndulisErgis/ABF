CREATE VIEW dbo.Alp_lkpArAlpCancelServiceCrdtMemo  
AS  
SELECT     TOP 100 PERCENT  ALP_tblInItem_view.ItemId,  ALP_tblInItem_view.Descr, dbo.tblInItemLoc.GLAcctCode, dbo.tblInGLAcct.GLAcctSales, dbo.tblInGLAcct.GLAcctCogs,   
                     ItemType, dbo.tblInItemLoc.LocId  
FROM         dbo.ALP_tblInItem_view  INNER JOIN  
                      dbo.tblInItemLoc ON  ALP_tblInItem_view.ItemId = dbo.tblInItemLoc.ItemId INNER JOIN  
                      dbo.tblInGLAcct ON dbo.tblInItemLoc.GLAcctCode = dbo.tblInGLAcct.GLAcctCode  
WHERE     ( ItemType = 3)  
ORDER BY  ALP_tblInItem_view.ItemId