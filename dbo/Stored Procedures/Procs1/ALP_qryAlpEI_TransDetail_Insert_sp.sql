CREATE  Procedure [dbo].[ALP_qryAlpEI_TransDetail_Insert_sp]          
          
/*          
  Created By Ravi for EFI#1962 on 10/03/2013        
  Modified by Ravi added following param for EFI#1962 on 11/01/2013  @PriceExt pdec=null , @PriceExtFgn pdec=null , @CostExt pdec=null, @CostExtFg       
  Modified by MAH, 12/2/15:  Detailed Tax records now created in separate procedure, called by EI once all Transaction detail records have been created.     
  Modified by ravi 12.04.2015: PartType parameter added  
  Modified by MAH, 08/04/2016: All Cost values are now assigned 0 in the AR transaction.  
		This is necessary since all costs associated with JM activity will be posted to the 
		appropriate GL accounts using Job Costing reports, rathert han through the AR posting. ( this change approved by JCP and Bob N. )
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
 @AlpSiteId int,          
 @AlpUseRecBillYn bit,          
 @PriceExt pdec=null ,      
 @PriceExtFgn pdec=null ,      
 @CostExt pdec=null,      
 @CostExtFgn pdec=null,
 --Below parttype param added by ravi on 12.04.2015
 @PartType tinyint =null      
AS          
SET NOCOUNT ON          
INSERT INTO tblArTransDetail  (           
    TransId,   EntryNum,  PartId,   [Desc],  AddnlDesc,  CatId,           
    WhseId,   TaxClass,  AcctCode,   GLAcctSales,  GLAcctCOGS,  GLAcctInv,           
    QtyOrdSell,   QtyShipSell,  QtyShipBase,   UnitsSell,  UnitsBase,  UnitPriceSell,           
    UnitPriceSellFgn,  UnitCostSell,  UnitCostSellFgn,  ExtCost  ,      
    --Below code added by ravi on 11/01/2013      
    --To calculate trav11 sales tax      
     PriceExt ,PriceExtFgn ,CostExt ,CostExtFgn,LineSeq ,      
     --mah added: 01/22/14:      
     UnitPriceSellBasis, UnitPriceSellBasisFgn  ,PartType      
     )         
     VALUES          
    (          
    @TransId,  @EntryNum,  @PartId,   @Desc ,  @AddnlDesc ,  @CatId ,          
    @WhseId ,  @TaxClass , @AcctCode,  @GLAcctSales , @GLAcctCOGS,  @GLAcctInv,          
    @QtyOrdSell,  @QtyShipSell, @QtyShipBase,   @UnitsSell,  @UnitsBase,    @UnitPriceSell,          
    @UnitPriceSellFgn,  0,  0,  0 ,      
    @QtyOrdSell * @UnitPriceSell,@QtyOrdSell * @UnitPriceSellFgn , --PriceExt, PriceExtFgn      
    0,0,@EntryNum,  --CostExt, CostExtFgn, LineSeq      
    --UnitPriceSellBasis, UnitPriceSellBasisFgn       
    @UnitPriceSell, @UnitPriceSellFgn  ,@PartType   
    )        
    --VALUES          
    --(          
    --@TransId,  @EntryNum,  @PartId,   @Desc ,  @AddnlDesc ,  @CatId ,          
    --@WhseId ,  @TaxClass , @AcctCode,  @GLAcctSales , @GLAcctCOGS,  @GLAcctInv,          
    --@QtyOrdSell,  @QtyShipSell, @QtyShipBase,   @UnitsSell,  @UnitsBase,    @UnitPriceSell,          
    --@UnitPriceSellFgn,  @UnitCostSell,  @UnitCostSellFgn,  @ExtCost    ,      
    --@QtyOrdSell * @UnitPriceSell,@QtyOrdSell * @UnitPriceSellFgn , --PriceExt, PriceExtFgn      
    --@QtyOrdSell * @UnitCostSell,@QtyOrdSell * @UnitCostSellFgn,@EntryNum,  --CostExt, CostExtFgn, LineSeq      
    ----UnitPriceSellBasis, UnitPriceSellBasisFgn       
    --@UnitPriceSell, @UnitPriceSellFgn  ,@PartType    
    --)          
          
  insert into ALP_tblArTransDetail (AlpEntryNum, AlpTransID , AlpUseRecBillYn,AlpSiteId )        
  values(@EntryNum , @TransId,  @AlpUseRecBillYn, @AlpSiteId)