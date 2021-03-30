CREATE Procedure dbo.ALP_qryArAlpAppendTransDetail_CancelServices  
@TransId pTransId,  
@EntryNum smallint,  
@PartId pItemId,  
@Desc varchar(35),  
@AddnlDesc text,  
@CatId varchar(2),  
@WhseId pLocId,  
@TaxClass tinyint,  
@AcctCode pGLAcctCode,  
@GLAcctSales pGLAcct,  
@GLAcctCOGS pGLAcct,  
@GLAcctInv pGLAcct,  
@QtyOrdSell pdec,  
@QtyShipSell pdec,  
@QtyShipBase pdec,  
@UnitsSell pUom,  
@UnitsBase pUom,  
@UnitPriceSell pdec,  
@UnitPriceSellFgn pdec,  
@UnitCostSell pdec,  
@UnitCostSellFgn pdec,  
@ExtCost pDec,  
@AlpUseRecBillYn bit  
AS  
SET NOCOUNT ON  
INSERT INTO tblArTransDetail ( TransId, EntryNum, PartId, [Desc], AddnlDesc, CatId, WhseId, TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv,   
  QtyOrdSell, QtyShipSell, QtyShipBase, UnitsSell, UnitsBase, UnitPriceSell, UnitPriceSellFgn, UnitCostSell, UnitCostSellFgn, ExtCost) --, AlpUseRecBillYn )  
VALUES(@TransId,@EntryNum, @PartId, @Desc , @AddnlDesc ,@CatId ,@WhseId ,@TaxClass ,  
 @AcctCode ,@GLAcctSales ,@GLAcctCOGS,@GLAcctInv,@QtyOrdSell ,@QtyShipSell ,@QtyShipBase, @UnitsSell, @UnitsBase,  @UnitPriceSell,  
 @UnitPriceSellFgn, @UnitCostSell, @UnitCostSellFgn, @ExtCost)--, @AlpUseRecBillYn)