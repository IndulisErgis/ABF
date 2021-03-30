CREATE  PROCEDURE [dbo].[trav_PcCreateInvoiceCreditHistoryRecord_proc]  
@ProjectDetailId int,  
@Amount pDecimal,  
@FiscalPeriod smallint,  
@FiscalYear smallint,  
@CurrencyID pCurrency,  
@ExchRate pDecimal,  
@DepositDate datetime,  
@PostRun pPostRun,  
@WksDate datetime,
@Transid pTransID  
AS  

SET NOCOUNT ON

BEGIN TRY    
 
 INSERT INTO tblArHistDeposit(PostRun,TransId,CustId,InvcNum,Amount  
  ,TermsCode,DistCode,FiscalPeriod,FiscalYear,CurrencyId,[Description]  
  ,ExchRate,RecType,GLAcctReceivablesDeposit,GLAcctReceivablesDepositContra,PostDate,TransDate  
  ,[Source],SourceId,ProjectName,ProjectDescription,PhaseId,PhaseDescription  
  ,TaskId,TaskDescription,PrintOption)  
 SELECT @PostRun,@Transid,h.CustId,h.ProjectName,@Amount  
  ,c.TermsCode,c.DistCode,@FiscalPeriod,@FiscalYear,@CurrencyID,(Case WHEN (@Amount>0) THEN 'Deposit for ' + ISNULL(d.[Description],'') ELSE 'Deposit credit for ' + ISNULL(d.[Description],'') END)  
  ,@ExchRate,(CASE WHEN (@Amount>0) THEN 0 ELSE 1 END),dc.GLAcctDepositReceivables,dc.GLAcctDepositReceivablesContra,@WksDate,@DepositDate  
  ,3,d.Id,h.ProjectName,v.[Description],d.PhaseId,ph.[Description]  
  ,d.TaskId,d.[Description],h.PrintOption  
 FROM tblPcProject h   
  INNER JOIN tblPcProjectDetail d ON h.Id =d.ProjectId AND d.Id=@ProjectDetailId  
  INNER JOIN trav_PcProject_view v ON h.Id=v.Id
  INNER JOIN tblArCust c ON c.CustId=h.CustId  
  INNER JOIN tblArDistCode dc ON dc.DistCode=c.DistCode  
  LEFT JOIN  tblPcPhase ph ON ph.PhaseId=d.PhaseId  
  
 END TRY    
BEGIN CATCH    
 EXEC dbo.trav_RaiseError_proc    
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCreateInvoiceCreditHistoryRecord_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCreateInvoiceCreditHistoryRecord_proc';

