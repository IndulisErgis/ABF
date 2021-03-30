CREATE PROCEDURE [dbo].[ALP_qry_AlpGetInventoryItemInfo_sp]  
 @PartID VARCHAR(24) = NULL,  
 @WhseID VARCHAR(10) = NULL  
AS  
 /*  
  Created by JM for EFI#1893 on 06/08/2010
  modified 10/30/15 - remove access to view.  access tables directly.  
 */  
   
SELECT     dbo.tblInItem.ItemId, dbo.tblInItem.Descr, dbo.tblInItem.ItemType,     
 dbo.tblInItem.ItemStatus, dbo.tblInItemLoc.LocId, dbo.tblInItemLoc.CostBase,    
 ----mah 06/19/14 - send bacl acct code based on whether part or service       
 --   --GLAcctCode = CASE WHEN ItemType = 3 THEN dbo.ALP_tblInItem.AlpAcctCode    
 --   -- ELSE dbo.tblInItemLoc.GLAcctCode    
 --   -- END as GLAcctCode,   
 --   --mah temp change to always send back account code from Alp table:  
 --   dbo.ALP_tblInItem.AlpAcctCode as GLAcctCode,   
  --mah 10/31/15:     
    GLAcctCode = CASE WHEN ItemType = 3 THEN dbo.ALP_tblInItem.AlpAcctCode    
     ELSE dbo.tblInItemLoc.GLAcctCode    
     END,   
    dbo.tblInItemLocUomPrice.PriceBase, dbo.tblInItemLocUomPrice.Uom,     
    dbo.tblInGLAcct.GLAcctSales, dbo.tblInGLAcct.GLAcctCogs, dbo.tblInItem.SalesCat, dbo.tblInItem.TaxClass    
    --MAH 06/19/14 - added GL info from ArSalesAcct Table    
    ,dbo.ALP_tblInItem.AlpAcctCode    
    ,dbo.tblArSalesAcct.GlAcctSales AS ArGlAcctSales    
    ,dbo.tblArSalesAcct.GlAcctCOGS AS ArGlAcctCOGS    
FROM   dbo.tblInItem 
		INNER JOIN dbo.tblInItemLoc ON dbo.tblInItem.ItemId = dbo.tblInItemLoc.ItemId 
        INNER JOIN dbo.tblInItemLocUomPrice ON dbo.tblInItemLocUomPrice.ItemId = dbo.tblInItem.ItemId     
							AND  dbo.tblInItemLocUomPrice.LocId = dbo.tblInItemLoc.LocId     
        INNER JOIN dbo.tblInGLAcct ON dbo.tblInGLAcct.GLAcctCode = dbo.tblInItemLoc.GLAcctCode    
        INNER JOIN dbo.ALP_tblInItem ON dbo.ALP_tblInItem.AlpItemId = dbo.tblInItem.ItemId    
        LEFT OUTER JOIN dbo.tblArSalesAcct ON dbo.tblArSalesAcct.AcctCode = dbo.tblInItemLoc.GLAcctCode 
WHERE dbo.tblInItem.ItemID = @PartID AND dbo.tblInItemLoc.LocId = @WhseID