

CREATE Procedure dbo.ALP_qryJmSvcTktAppendTransDetail
/*
	 Modified by NP for EFI#1869 on 05/05/10 
	 Added '=null' for @AddnlDesc,@CatId,@AcctCode,@GLAcctSales,@GLAcctCOGS,@GLAcctInv,@UnitPriceSellFgn,@UnitCostSell,@UnitCostSellFgn,@ExtCost
*/
	@TransId pTransId,
	@EntryNum smallint,
	@PartId pItemId,
	@Desc varchar(35),
	@AddnlDesc text=null,
	@CatId varchar(2)= null,
	@WhseId pLocId,
	@TaxClass tinyint,
	@AcctCode pGLAcctCode=null,
	@GLAcctSales pGLAcct =null,
	@GLAcctCOGS pGLAcct =null,
	@GLAcctInv pGLAcct=null,
	@QtyOrdSell pdec,
	@QtyShipSell pdec,
	@QtyShipBase pdec,
	@UnitsSell pUom,
	@UnitsBase pUom,
	@UnitPriceSell pdec,
	@UnitPriceSellFgn pdec=null,
	@UnitCostSell pdec=null,
	@UnitCostSellFgn pdec=null,
	@ExtCost pDec =null,
	@AlpUseRecBillYn bit
AS
SET NOCOUNT ON
BEGIN TRY
BEGIN TRAN

INSERT INTO tblArTransDetail ( TransId, EntryNum, PartId, [Desc], AddnlDesc, CatId, WhseId, TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv, 
		QtyOrdSell, QtyShipSell, QtyShipBase, UnitsSell, UnitsBase, UnitPriceSell, UnitPriceSellFgn, UnitCostSell, UnitCostSellFgn, ExtCost )
VALUES(@TransId,@EntryNum, @PartId, @Desc , @AddnlDesc ,@CatId ,@WhseId ,@TaxClass ,
	@AcctCode ,@GLAcctSales ,@GLAcctCOGS,@GLAcctInv,@QtyOrdSell ,@QtyShipSell ,@QtyShipBase, @UnitsSell, @UnitsBase,  @UnitPriceSell,
	@UnitPriceSellFgn, @UnitCostSell, @UnitCostSellFgn, @ExtCost)

INSERT into ALP_tblArTransDetail(AlpTransID,AlpEntryNum,AlpUseRecBillYn) Values( @TransId,@EntryNum,@AlpUseRecBillYn)

Commit
END TRY
BEGIN CATCH
ROLLBACK
END CATCH