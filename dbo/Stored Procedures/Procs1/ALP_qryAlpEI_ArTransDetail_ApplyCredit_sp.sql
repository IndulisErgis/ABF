CREATE   procedure [dbo].[ALP_qryAlpEI_ArTransDetail_ApplyCredit_sp]  
--Below @SiteId param default value assigned 0, the code modified by ravi on 06.24.2015
 @OldTransID varchar(8),  
 @NewTransID1 varchar(8),  
 @NewTransID2 varchar(8),  
 @SiteID  int=0,  
 @EntryNum smallint,  
 @AmtToApply decimal(20,10),  
 @AmtToApplyFgn decimal(20,10)  
  
  
As  
Begin  
 INSERT INTO tblArTransDetail  
 (  
  TransID, EntryNum, ItemJob, WhseId,  PartId,  JobId,  
  PhaseId, JobCompleteYN, [Desc],  LottedYn, PartType, AddnlDesc,  
  CatId,  TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv,  
  QtyOrdSell, UnitsSell, UnitsBase, QtyShipBase, QtyShipSell, QtyBackordSell,  
  PriceCode, UnitPriceSell, UnitCostSell, UnitPriceSellFgn,UnitCostSellFgn,HistSeqNum,  
  ExtCost, ExtFinalInc, ExtOrigInc, TransHistId, TaskId,  PhaseName,  
  ProjName, ExtFinalIncFgn, TaskName, QtySeqNum,  
  PriceExt ,PriceExtFgn ,CostExt ,CostExtFgn,LineSeq ,  
        UnitPriceSellBasis, UnitPriceSellBasisFgn   
   
 )  
    
 Select   
  @NewTransID1, EntryNum, ItemJob, WhseId,  PartId,  JobId,  
  PhaseId, JobCompleteYN, [Desc],  LottedYn, PartType, AddnlDesc,  
  CatId,  TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv,  
  QtyOrdSell, UnitsSell, UnitsBase, QtyShipBase, QtyShipSell, QtyBackordSell,  
  PriceCode, @AmtToApply, @AmtToApply, @AmtToApplyFgn, @AmtToApplyFgn, HistSeqNum,  
  ExtCost, ExtFinalInc, ExtOrigInc, TransHistId, TaskId,  PhaseName,  
  ProjName, ExtFinalIncFgn, TaskName, QtySeqNum,  
  QtyOrdSell * @AmtToApply,  QtyOrdSell * @AmtToApplyFgn , --PriceExt, PriceExtFgn  
  QtyOrdSell * @AmtToApply,  QtyOrdSell * @AmtToApplyFgn ,@EntryNum,  --CostExt, CostExtFgn, LineSeq  
  @AmtToApply, @AmtToApplyFgn  
 from  tblArTransDetail  
 Where  TransID = @OldTransID and EntryNum = @EntryNum  
   
   
   
 INSERT INTO ALP_tblArTransDetail    
 (    
  AlpTransID, AlpEntryNum,AlpUseRecBillYn,AlpFromDate,AlpThruDate,  
  AlpDeferYn, AlpAlarmID, AlpSiteID,AlpRmrItemYn  
  )   
 Select   
  @NewTransID1, AlpEntryNum, AlpUseRecBillYn,AlpFromDate,  
  AlpThruDate, AlpDeferYn, AlpAlarmId, @SiteID, AlpRmrItemYn  
 from  ALP_tblArTransDetail  
 Where  AlpTransID = @OldTransID and AlpEntryNum = @EntryNum    
   
   
  
 INSERT INTO tblArTransDetail  
 (  
  TransID, EntryNum, ItemJob, WhseId,  PartId,  JobId,  
  PhaseId, JobCompleteYN, [Desc],  LottedYn, PartType, AddnlDesc,  
  CatId,  TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv,  
  QtyOrdSell, UnitsSell, UnitsBase, QtyShipBase, QtyShipSell, QtyBackordSell,  
  PriceCode, UnitPriceSell, UnitCostSell, UnitPriceSellFgn,UnitCostSellFgn,HistSeqNum,  
  ExtCost, ExtFinalInc, ExtOrigInc, TransHistId, TaskId,  PhaseName,  
  ProjName, ExtFinalIncFgn, TaskName, QtySeqNum,  
  PriceExt ,PriceExtFgn ,CostExt ,CostExtFgn,LineSeq ,  
        UnitPriceSellBasis, UnitPriceSellBasisFgn   
 )  
     
 Select   
  --@NewTransID, EntryNum, ItemJob, WhseId,  PartId,  JobId,  
  @NewTransID2, EntryNum, ItemJob, WhseId,  PartId,  JobId,  
  PhaseId, JobCompleteYN, [Desc],  LottedYn, PartType, AddnlDesc,  
  CatId,  TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv,  
  QtyOrdSell, UnitsSell, UnitsBase, QtyShipBase, QtyShipSell, QtyBackordSell,  
  PriceCode, @AmtToApply*-1, @AmtToApply*-1, @AmtToApplyFgn*-1, @AmtToApplyFgn*-1, HistSeqNum,  
  ExtCost, ExtFinalInc, ExtOrigInc, TransHistId, TaskId,  PhaseName,  
  ProjName, ExtFinalIncFgn, TaskName, QtySeqNum,  
  QtyOrdSell * @AmtToApply * -1,  QtyOrdSell * @AmtToApplyFgn * -1, --PriceExt, PriceExtFgn  
  QtyOrdSell * @AmtToApply * -1,  QtyOrdSell * @AmtToApplyFgn * -1, @EntryNum,  --CostExt, CostExtFgn, LineSeq  
  @AmtToApply * -1, @AmtToApplyFgn * -1  
  
 from  tblArTransDetail  
 Where  TransID = @OldTransID and EntryNum = @EntryNum  
   
     
 INSERT INTO ALP_tblArTransDetail    
 (    
  AlpTransID, AlpEntryNum,AlpUseRecBillYn,AlpFromDate,AlpThruDate,  
  AlpDeferYn, AlpAlarmID, AlpSiteID,AlpRmrItemYn  
  )   
 Select   
  @NewTransID2, AlpEntryNum, AlpUseRecBillYn,AlpFromDate,  
  AlpThruDate, AlpDeferYn, AlpAlarmId, @SiteID, AlpRmrItemYn  
 from  ALP_tblArTransDetail  
 Where  AlpTransID = @OldTransID and AlpEntryNum = @EntryNum    
  
End