CREATE PROCEDURE Alp_UpdateArTransPayment_SP(
	@pTransId pTransId, 
	@pDepositId pBatchID,  
	@pExchRate PDec ,
   @pGlPeriod smallint,
   @pFiscalYear smallint,
	@pSumHistPeriod smallint,
	@pSourceId uniqueidentifier,
	@pInvcNum pInvoiceNum,
	@pInvcType smallint,
	@pSiteID int ,
	@pTicketId int,
	@pCompID pCustId=null,
	@pDistCode PDistCode
)AS
BEGIN
Declare @RcptHeaderID int,@CustId varchar;
		
		INSERT INTO tblArCashRcptHeader (PmtAmt, BankID, CheckNum,CustId, 
													PmtMethodId, CcHolder, CcNum, CcExpire, 
													CcAuth, [Note],CurrencyID, InvcTransID, DepositID, GLPeriod, 
													FiscalYear, SumHistPeriod, InvcAppID, GLAcct, AgingPd,PmtDate,SourceId    )  
		SELECT ALP_tblJmSvcTktPmt.PmtAmt, ALP_tblJmSvcTktPmt.BankID, ALP_tblJmSvcTktPmt.CheckNum, ALP_tblJmSvcTkt.CustId,
		       ALP_tblJmSvcTktPmt.PmtMethodId,ALP_tblJmSvcTktPmt.CcHolder, ALP_tblJmSvcTktPmt.CcNum, ALP_tblJmSvcTktPmt.CcExpire,
		       ALP_tblJmSvcTktPmt.CcAuth, ALP_tblJmSvcTktPmt.Note, ALP_tblJmSvcTktPmt.CurrencyID, @pTransId , @pDepositId ,@pGlPeriod ,   
				 @pFiscalYear , @pSumHistPeriod, 'AR' AS Expr1, tblArPmtMethod.GLAcctDebit, Null AS Expr2  ,ALP_tblJmSvcTktpmt.PmtDate,@pSourceId 
		FROM   ALP_tblJmSvcTkt  INNER JOIN ALP_tblJmSvcTktPmt INNER JOIN tblArPmtMethod ON ALP_tblJmSvcTktPmt.PmtMethodId = tblArPmtMethod.PmtMethodID   
		ON     ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktPmt.TicketId  
		WHERE ALP_tblJmSvcTkt.TicketId =@pTicketId  AND CashRcptCreated=0

		SELECT @RcptHeaderID=IDENT_CURRENT('tblArCashRcptHeader') ;
		
		SELECT @CustId =CustId  FROM ALP_tblJmSvcTkt WHERE ALP_tblJmSvcTkt.TicketId =@pTicketId   
		
	   EXEC ALP_qryJmSvcTktAppendPmtDetail @pTicketId,@pInvcNum  ,@pCompID,@CustId,@RcptHeaderID,@pDistCode,@pSiteID
		
		INSERT INTO  tblArTransPmt (TransId,DepositId,LinkId,PmtMethodId,PmtDate,
											 PmtAmt,PmtAmtFgn,CurrencyId,ExchRate, GlPeriod,
											 FiscalYear,CheckNum,CcNum,CcHolder,
											 CcExpire,CcAuth ,Note    )
		SELECT @pTransId,@pDepositId,@RcptHeaderID,ALP_tblJmSvcTktPmt.PmtMethodId,ALP_tblJmSvcTktpmt.PmtDate,
				 ALP_tblJmSvcTktPmt.PmtAmt, ALP_tblJmSvcTktPmt.PmtAmt,ALP_tblJmSvcTktPmt.CurrencyID,@pExchRate ,@pGlPeriod,
			    @pFiscalYear , ALP_tblJmSvcTktPmt.CheckNum,ALP_tblJmSvcTktPmt.CcNum,		 ALP_tblJmSvcTktPmt.CcHolder,
			    ALP_tblJmSvcTktPmt.CcExpire, ALP_tblJmSvcTktPmt.CcAuth,ALP_tblJmSvcTktPmt .Note 
		FROM   ALP_tblJmSvcTkt  INNER JOIN ALP_tblJmSvcTktPmt INNER JOIN tblArPmtMethod ON ALP_tblJmSvcTktPmt.PmtMethodId = tblArPmtMethod.PmtMethodID   
		ON     ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktPmt.TicketId  
		WHERE  ALP_tblJmSvcTkt.TicketId =@pTicketId  AND CashRcptCreated=0
		
		UPDATE ALP_tblJmSvcTktPmt SET ArCashRcptHeaderID = @RcptHeaderID , CashRcptCreated= 1 
		WHERE  TicketId = @pTicketId and  CashRcptCreated= 0
END