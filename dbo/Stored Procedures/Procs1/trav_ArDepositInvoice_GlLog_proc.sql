
CREATE PROCEDURE  [dbo].[trav_ArDepositInvoice_GlLog_proc]                    
AS                            
BEGIN TRY       
      
SET NOCOUNT ON         
 DECLARE @PostRun pPostRun,@CompId nvarchar(3),@TransId pTransID,@RecType tinyint,@PrecCurr tinyint,@CurrBase pCurrency      
    
 SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'    
 SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'    
 SELECT @TransId = Cast([Value] AS nvarchar(8)) FROM #GlobalValues WHERE [Key] = 'TransId'    
 SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'    
 SELECT @RecType = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'RecType'   
 SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'      
       
   IF @TransId IS NULL OR @RecType IS NULL  OR @PrecCurr IS NULL                           
   OR @PostRun IS NULL OR @CompId IS NULL OR @CurrBase IS NULL                         
 BEGIN                            
  RAISERROR(90025,16,1)                            
 END         
    
if(@RecType=0)-- Invoice    
 Begin    
  INSERT INTO  #GlPostLogs (CompId, PostDate, TransDate,[Description]        
     , SourceCode, Reference, GlAccount,AmountFgn, DebitAmount, CreditAmount, FiscalPeriod, FiscalYear, PostRun        
     , ExchRate, CurrencyId, DebitAmountFgn, CreditAmountFgn,DistCode, LinkID, LinkIDSub, [Grouping], LinkIDSubLine )          
       
     SELECT @CompId, PostDate, TransDate, [Description]       
     , 'JC', CustId, GLAcctReceivablesDeposit,Amount, ROUND((Amount/(CASE WHEN g.CurrencyID <> @CurrBase THEN 1.0 ELSE ExchRate END)),@PrecCurr), 0 
     ,FiscalPeriod, FiscalYear, @PostRun        
     , CASE WHEN g.CurrencyID <> @CurrBase THEN 1.0 ELSE ExchRate END, g.CurrencyId, Amount, 0,DistCode,TransId,InvcNum ,100, -2        
     FROM  tblArHistDeposit d LEFT JOIN tblGlAcctHdr g ON g.AcctId=d.GLAcctReceivablesDeposit where TransId =@TransId and PostRun =@PostRun    
            
  INSERT INTO  #GlPostLogs (CompId, PostDate, TransDate,[Description]        
     , SourceCode, Reference, GlAccount,AmountFgn, DebitAmount, CreditAmount, FiscalPeriod, FiscalYear, PostRun        
     , ExchRate, CurrencyId, DebitAmountFgn, CreditAmountFgn,DistCode, LinkID, LinkIDSub,[Grouping], LinkIDSubLine )          
     
    SELECT @CompId, PostDate, TransDate, [Description]       
     , 'JC', CustId, GLAcctReceivablesDepositContra,Amount, 0, ROUND((Amount/(CASE WHEN g.CurrencyID <> @CurrBase THEN 1.0 ELSE ExchRate END)),@PrecCurr), FiscalPeriod, FiscalYear, @PostRun        
     , CASE WHEN g.CurrencyID <> @CurrBase THEN 1.0 ELSE ExchRate END, g.CurrencyId, 0, Amount ,DistCode,TransId,InvcNum,100, -2         
     FROM  tblArHistDeposit d LEFT JOIN tblGlAcctHdr g ON g.AcctId=d.GLAcctReceivablesDepositContra  where TransId =@TransId and PostRun =@PostRun    
 END    
else if(@RecType=1)---Credit    
 Begin    
 INSERT INTO  #GlPostLogs (CompId, PostDate, TransDate,[Description]        
    , SourceCode, Reference, GlAccount,AmountFgn, DebitAmount, CreditAmount, FiscalPeriod, FiscalYear, PostRun        
    , ExchRate, CurrencyId, DebitAmountFgn, CreditAmountFgn,DistCode, LinkID, LinkIDSub,[Grouping], LinkIDSubLine )          
      
    SELECT @CompId, PostDate, TransDate, [Description]       
    , 'JC', CustId, GLAcctReceivablesDeposit,ABS(Amount), 0, ABS(ROUND((Amount/(CASE WHEN g.CurrencyID <> @CurrBase THEN 1.0 ELSE ExchRate END)),@PrecCurr)), FiscalPeriod, FiscalYear, @PostRun        
    , CASE WHEN g.CurrencyID <> @CurrBase THEN 1.0 ELSE ExchRate END, g.CurrencyId, 0, ABS(Amount) ,DistCode,TransId,CredMemNum,100, -2     
    FROM  tblArHistDeposit d LEFT JOIN tblGlAcctHdr g ON g.AcctId=d.GLAcctReceivablesDeposit where TransId =@TransId and PostRun =@PostRun    
           
 INSERT INTO  #GlPostLogs (CompId, PostDate, TransDate,[Description]        
    , SourceCode, Reference, GlAccount,AmountFgn, DebitAmount, CreditAmount, FiscalPeriod, FiscalYear, PostRun        
    , ExchRate, CurrencyId, DebitAmountFgn, CreditAmountFgn,DistCode, LinkID, LinkIDSub,[Grouping], LinkIDSubLine )          
     
   SELECT @CompId, PostDate, TransDate, [Description]       
    , 'JC', CustId, GLAcctReceivablesDepositContra,ABS(Amount), ABS(ROUND((Amount/(CASE WHEN g.CurrencyID <> @CurrBase THEN 1.0 ELSE ExchRate END)),@PrecCurr)), 0, FiscalPeriod, FiscalYear, @PostRun        
    , CASE WHEN g.CurrencyID <> @CurrBase THEN 1.0 ELSE ExchRate END, g.CurrencyId, ABS(Amount), 0,DistCode,TransId,CredMemNum,100, -2     
    FROM  tblArHistDeposit d LEFT JOIN tblGlAcctHdr g ON g.AcctId=d.GLAcctReceivablesDepositContra where TransId =@TransId and PostRun =@PostRun    
 END    
END TRY                            
BEGIN CATCH                            
 EXEC  trav_RaiseError_proc                            
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArDepositInvoice_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArDepositInvoice_GlLog_proc';

