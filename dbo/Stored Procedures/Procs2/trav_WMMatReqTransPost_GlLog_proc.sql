
CREATE PROCEDURE  [dbo].[trav_WMMatReqTransPost_GlLog_proc]                      
AS                      
BEGIN TRY      

 SET NOCOUNT ON                     
 
 DECLARE @PrecCurr tinyint,                      
  @gWMPostDtlGlYn bit,@WrkStnDate datetime,  @PostRun pPostRun,                      
  @CurrBase pCurrency,@CompId nvarchar(3)                  
    
  Create table #tmpGlAcctInv 
  (  
      TranKey int,  
      LineNum int,  
      GLAcctInv pGlAcct  
  )                  
 SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'                      
 SELECT @gWMPostDtlGlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlGlYn'                      
 SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'                    
 SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'                      
 SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'                      
 SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'                      
                      
 IF @gWMPostDtlGlYn IS NULL OR @PrecCurr IS NULL                       
  OR @WrkStnDate IS NULL OR @PostRun IS NULL OR @CurrBase IS NULL OR @CompId IS NULL                      
 BEGIN                      
  RAISERROR(90025,16,1)                      
 END                    
   
   
 Insert into #tmpGLAcctInv (TranKey, LineNum, GlAcctInv)  
      SELECT h.TranKey, d.LineNum, g.GLAcctInv  
      FROM  tblWmMatReq h         
      INNER JOIN #PostTransList t   
   ON h.TranKey  = t.TransId     
      INNER JOIN  tblWmMatReqRequest d   
            ON h.TranKey = d.TranKey  
      INNER JOIN  tblWmMatReqFilled f  
            on d.TranKey = f.TranKey and d.LineNum = f.LineNum AND f.[Status]=0 --limit to trans with filled quantities  
      INNER JOIN  tblInItemLoc l   
            ON d.ItemId = l.ItemId AND d.LocId = l.LocId   
      Left JOIN  tblInGLAcct g   
            ON l.GLAcctCode = g.GLAcctCode         
      --Where d.Qty <= d.QtyFilled    
      --GL log entries for filled quantity should be generated only if its status is un-posted.        
      Group by h.TranKey, d.LineNum, g.GlAcctInv  
   
  
INSERT INTO  #MatReqPostLog (ReqType, TranKey, LineNum, GlPeriod, GLYear, GlAcct, ReqNum  
      , Descr, SumDescr, DRAmt, CRAmt, TransDate, PostDate, SourceCode, GroupRef)  
SELECT h.ReqType, h.TranKey, r.LineNum  
      , f.GLPeriod, f.GlYear, r.GLAcctNum, h.ReqNum  
      , SUBSTRING(CASE WHEN GLDescr IS NULL THEN  (r.ItemId + ' ' + isnull(i.Descr, '')) ELSE GLDescr END, 1,30)  
      , GLDescr  
      , CASE WHEN ReqType > 0 THEN ROUND(f.Qty * f.UnitCost, @PrecCurr) ELSE 0 END  
      , CASE WHEN ReqType < 0 THEN ROUND(f.Qty * f.UnitCost, @PrecCurr) ELSE 0 END  
      , f.TransDate, @WrkStnDate, 'WM', 100  
FROM  tblWmMatReq h   
INNER JOIN  tblWmMatReqRequest r   
      on h.TranKey = r.TranKey  
INNER JOIN  tblWmMatReqFilled f  
      on r.TranKey = f.TranKey and r.LineNum = f.LineNum AND f.[Status]=0  
INNER JOIN #tmpGLAcctInv l --limit to selected records  
      on r.TranKey = l.TranKey and r.LineNum = l.LineNum  
Left Join  tblInItem i  
      on r.ItemId = i.ItemId       
        
  
INSERT INTO  #MatReqPostLog (ReqType, TranKey, LineNum, GlPeriod, GLYear, GlAcct, ReqNum  
      , Descr, SumDescr, DRAmt, CRAmt, TransDate, PostDate, SourceCode, GroupRef)  
      SELECT  a.ReqType, a.TranKey, a.LineNum, a.GLPeriod, a.GlYear, b.GLAcctInv, 'Mtrl Inv'  
      , CASE WHEN a.ReqType > 0 THEN 'Amount from Material Inventory' ELSE 'Amount to Material Inventory' END  
      , CASE WHEN a.ReqType > 0 THEN 'Amount from Material Inventory' ELSE 'Amount to Material Inventory' END  
      , CASE WHEN CRAmt - DRAmt > 0 THEN CRAmt - DRAmt ELSE 0 END  
      , CASE WHEN DRAmt - CRAmt > 0 THEN DRAmt - CRAmt ELSE 0 END  
      , TransDate, PostDate, SourceCode, 200  
      FROM  #MatReqPostLog a   
      INNER JOIN #tmpGLAcctInv b   
            ON a.TranKey = b.TranKey AND a.LineNum = b.LineNum       
--Generate the GL log entries            
IF @gWMPostDtlGlYn = 1  
BEGIN  
      --Post Detail to GL
      INSERT INTO  #GlPostLogs (CompId, PostDate, TransDate,[Description]  
            , SourceCode, Reference, GlAccount,AmountFgn, DebitAmount, CreditAmount, FiscalPeriod, FiscalYear, PostRun  
            , ExchRate, CurrencyId, DebitAmountFgn, CreditAmountFgn,[Grouping])    
      SELECT @CompId, PostDate, TransDate, Descr  
            , SourceCode, ReqNum, GLAcct,ABS(DRAmt-CRAmt), DRAmt, CRAmt, GlPeriod, GlYear, @PostRun  
            , 1.0, @CurrBase, DRAmt, CRAmt,GroupRef    
      FROM  #MatReqPostLog          
END  
ELSE  
BEGIN  
      --Post Summary to GL
      INSERT INTO  #GlPostLogs (CompId, PostDate, TransDate, [Description]  
            , SourceCode, Reference, GlAccount,AmountFgn, DebitAmount, CreditAmount,FiscalPeriod, FiscalYear, PostRun  
            , ExchRate, CurrencyId, DebitAmountFgn, CreditAmountFgn,[Grouping])    
      SELECT @CompId, PostDate, MIN(TransDate), SumDescr  
            , SourceCode, MIN(ReqNum), GlAcct,ABS(SUM(DRAmt)-SUM(CRAmt)),SUM(DRAmt), SUM(CRAmt), GlPeriod, GlYear, @PostRun  
            , 1.0, @CurrBase, SUM(DRAmt), SUM(CRAmt),GroupRef  
      FROM  #MatReqPostLog  
             
      GROUP BY PostDate, SumDescr, SourceCode, GlAcct, GlPeriod, GlYear, GroupRef --include groupref so accts offset properly by section  
      HAVING SUM(DRAmt) <> 0 OR SUM(CRAmt) <> 0           
End                      
END TRY                      
BEGIN CATCH                      
 EXEC  trav_RaiseError_proc                      
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMMatReqTransPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMMatReqTransPost_GlLog_proc';

