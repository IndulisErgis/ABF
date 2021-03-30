CREATE VIEW dbo.ALP_glbJmOption  
AS  
SELECT     OptionKey, GlYn, ArYn, InYn, ProductKey, ImYn, SchedYn, EditPricePartsYN, EditPriceOtherYN, EditCostPartsYN, EditCostOtherYN, PrintCompInfoYN,   
                      PlainPaperInstTktsYN, PlainPaperServTktsYN, OnlineInvcYn, ProjJobInvcCommentYn, DfltDeptServ, DfltDeptInst, DfltWorkCodeServ, DfltWorkCodeInst,   
                      DfltBatchCodeServ, DfltBatchCodeInst, DfltItemIdParts, DfltItemIdLabor, DfltItemIdComment, PwordMaster, PwordEditPrice, PwordDelBill, PwordCompTkt,   
                      PwordDeleteTkt, PwordOverride, DfltCosOffsetPartsOh, LockTimeBarsDate, PworkLabMarkupPct, DfltRecJobProcDate, DfltRecJobCycleId, ValidateBillingYN,   
                      GlAcctWIP, CosOffsetParts, CosOffsetOtherItems, CosOffsetPartsOh, RmrExpense, DiscRatePct, CommPaidThruDate, JmWDBUtilitiesYN, ItemIdInJobInvcCommentYn,   
                      ts, JmEnhancedInvoicingYN, DfltItemIdPartsInst, DfltItemIdLaborInst, UseItemGLInBillingYn, AlpEncrypt, JMLockJObsWhenCompletedYN
                      --Added by NSK on 08 May 2017.
                      ,AuditTicketsYN,AuditSitesYN
FROM         dbo.ALP_tblJmOption