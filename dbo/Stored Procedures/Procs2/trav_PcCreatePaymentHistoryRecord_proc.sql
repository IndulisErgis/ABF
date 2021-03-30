CREATE  PROCEDURE [dbo].[trav_PcCreatePaymentHistoryRecord_proc]  
@ProjectDetailId int,  
@Amount pDecimal,  
@FiscalPeriod smallint,  
@FiscalYear smallint,  
@CurrencyID pCurrency,  
@ExchRate pDecimal,  
@DepositDate datetime,  
@PostRun pPostRun,  
@WksDate datetime,
@RcptHdrID pTransID  
AS  

SET NOCOUNT ON

BEGIN TRY    
 
 INSERT INTO tblArHistDeposit(PostRun,TransId,CustId,InvcNum,Amount  
  ,DistCode,FiscalPeriod,FiscalYear,CurrencyId,[Description]  
  ,ExchRate,RecType,GLAcctReceivablesDeposit,GLAcctReceivablesDepositContra,PostDate,TransDate  
  ,[Source])   
 SELECT @PostRun,@RcptHdrID,h.CustId,h.ProjectName,-@Amount  
  ,c.DistCode,@FiscalPeriod,@FiscalYear,@CurrencyID,'Deposit payment'
  ,@ExchRate,2,dc.GLAcctDepositReceivables,dc.GLAcctDepositReceivablesContra,@WksDate,@DepositDate  
  ,3
 FROM tblPcProject h   
  INNER JOIN tblPcProjectDetail d ON h.Id =d.ProjectId AND d.Id=@ProjectDetailId    
  INNER JOIN tblArCust c ON c.CustId=h.CustId  
  INNER JOIN tblArDistCode dc ON dc.DistCode=c.DistCode  
  
 END TRY    
BEGIN CATCH    
 EXEC dbo.trav_RaiseError_proc    
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCreatePaymentHistoryRecord_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCreatePaymentHistoryRecord_proc';

