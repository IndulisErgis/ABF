  
CREATE VIEW dbo.ALP_lkpArAlpGetItemIdByLoc      
AS      
SELECT     dbo.tblInItem.ItemId, dbo.tblInItem.Descr, dbo.tblInItem.ItemType,     
 dbo.tblInItem.ItemStatus, dbo.tblInItemLoc.LocId, dbo.tblInItemLoc.CostBase,    
	----mah 06/19/14 - send back acct code based on whether part or service       
    -- GLAcctCode = CASE WHEN ItemType = 3 THEN dbo.ALP_tblInItem.AlpAcctCode    
    --    ELSE dbo.tblInItemLoc.GLAcctCode    
    --    END as GLAcctCode,   
    --mah temp change to always send back account code from Alp table:  
    dbo.ALP_tblInItem.AlpAcctCode as GLAcctCode,    
    dbo.tblInItemLocUomPrice.PriceBase, dbo.tblInItemLocUomPrice.Uom,     
    dbo.tblInGLAcct.GLAcctSales, dbo.tblInGLAcct.GLAcctCogs, dbo.tblInItem.SalesCat, dbo.tblInItem.TaxClass    
    --MAH 06/19/14 - added GL info from ArSalesAcct Table    
    ,dbo.ALP_tblInItem.AlpAcctCode    
    ,dbo.tblArSalesAcct.GlAcctSales AS ArGlAcctSales    
    ,dbo.tblArSalesAcct.GlAcctCOGS AS ArGlAcctCOGS    
FROM         dbo.tblInItem INNER JOIN      
                      dbo.tblInItemLoc ON dbo.tblInItem.ItemId = dbo.tblInItemLoc.ItemId INNER JOIN      
                      dbo.tblInItemLocUomPrice     
      ON dbo.tblInItem.ItemId = dbo.tblInItemLocUomPrice.ItemId     
       AND  dbo.tblInItemLoc.LocId = dbo.tblInItemLocUomPrice.LocId     
                      INNER JOIN      
                      dbo.tblInGLAcct ON dbo.tblInItemLoc.GLAcctCode = dbo.tblInGLAcct.GLAcctCode    
                      INNER JOIN dbo.ALP_tblInItem ON dbo.tblInItem.ItemId = dbo.ALP_tblInItem.AlpItemId    
                      LEFT OUTER JOIN      
                      dbo.tblArSalesAcct ON dbo.tblInItemLoc.GLAcctCode = dbo.tblArSalesAcct.AcctCode