                     
Create PROCEDURE [dbo].[ALP_qryJmSvcTktAppendPmtDetail](
@ID int,
@InvcNum pInvoiceNum = NULL, -- EFI#1869 ADDED BY SUDHARSON 09/09/2010 for EIJ
@CompID pCustId= NULL, -- EFI#1869 ADDED BY SUDHARSON 09/09/2010 for EIJ Foreign Currency Conversion
@CustId pCustId= NULL ,-- EFI#1869 ADDED BY SUDHARSON 09/09/2010 for EIJ Foreign Currency Conversion
@pRcptHeaderID int,
@pDistCode pDistCode,@pSiteID int --ADDED BY RAVI 10/10/2014 for Ticket pre payment update 
 )

As
SET NOCOUNT ON
Declare @pRcptDetailID int;
if(@InvcNum is null)
Begin
	INSERT INTO tblArCashRcptDetail (  InvcNum, PmtAmt, RcptHeaderID, DistCode, PmtAmtFgn )
	SELECT --Alp_tblJmSvcTkt.SiteId,
	CASE
	WHEN Alp_tblJmSvcTkt.InvcNum Is Null THEN 'Not Yet Issued'
	ELSE @InvcNum
	END AS Expr1,	Alp_tblJmSvcTktPmt.PmtAmt,	@pRcptHeaderID, @pDistCode, Alp_tblJmSvcTktPmt.PmtAmt
	FROM ALP_tblJmSvcTkt  INNER JOIN ALP_tblJmSvcTktPmt  	ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktPmt.TicketId  
	WHERE ALP_tblJmSvcTkt.TicketId =@ID  AND CashRcptCreated=0
	
	  SELECT @pRcptDetailID=IDENT_CURRENT('tblArCashRcptDetail') ;
	
	   INSERT INTO Alp_tblArCashRcptDetail (AlpRcptDetailID,AlpSiteID,AlpComment)
	   SELECT @pRcptDetailID,@pSiteID ,ALP_tblJmSvcTktPmt.Note 
		FROM ALP_tblJmSvcTkt  INNER JOIN ALP_tblJmSvcTktPmt  	ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktPmt.TicketId  
	WHERE ALP_tblJmSvcTkt.TicketId =@ID  AND CashRcptCreated=0
	
	End
else
begin

	--declare @BaseCurrency pCurrency
	--declare @CustCurrencyID pCurrency
	--declare @Multicurrency bit
	declare @PmtDate datetime
	declare @PmtAmtFgn numeric(18,2)
	declare @ExchRate numeric(18,2)

	--set @BaseCurrency = (select BaseCurrency from sys.dbo.tblSmCompInfo where CompID = @CompID)
	--set @Multicurrency = (select Multicurrency from sys.dbo.tblSmCompInfo where CompID = @CompID)
	--SET @CustCurrencyID = (SELECT CurrencyID from tblArCust where custid = @CustID)

	--IF @Multicurrency = 1 AND @BaseCurrency <> @CustCurrencyID
	--BEGIN
	--	set @PmtDate = (SELECT top 1 tblArCashRcptHeader.PmtDate
	--	FROM Alp_tblJmSvcTkt INNER JOIN ((Alp_tblJmSvcTktPmt INNER JOIN tblArTransHeader ON Alp_tblJmSvcTktPmt.TicketId = tblArTransHeader.AlpJobNum)
	--	INNER JOIN tblArCashRcptHeader ON tblArTransHeader.TransId = tblArCashRcptHeader.InvcTransID) ON Alp_tblJmSvcTkt.TicketId = Alp_tblJmSvcTktPmt.TicketId
	--	WHERE Alp_tblJmSvcTktPmt.TicketId = @ID)

	--	set @ExchRate = (Select top 1 ExchRate from lkpSmExchRate
	--	where CurrencyTo = @CustCurrencyID and CurrencyFrom = @BaseCurrency
	--	and EffectDate <= @PmtDate ORDER BY EffectDate Desc)


	--	set @PmtAmtFgn = @ExchRate * (SELECT top 1 Alp_tblJmSvcTktPmt.PmtAmt
	--	FROM Alp_tblJmSvcTkt INNER JOIN ((Alp_tblJmSvcTktPmt INNER JOIN tblArTransHeader ON Alp_tblJmSvcTktPmt.TicketId = tblArTransHeader.AlpJobNum)
	--	INNER JOIN tblArCashRcptHeader ON tblArTransHeader.TransId = tblArCashRcptHeader.InvcTransID) ON Alp_tblJmSvcTkt.TicketId = Alp_tblJmSvcTktPmt.TicketId
	--	WHERE Alp_tblJmSvcTktPmt.TicketId = @ID)


	--	INSERT INTO tblArCashRcptDetail (   InvcNum, PmtAmt, RcptHeaderID, DistCode, PmtAmtFgn )
	--	SELECT  
	--	@InvcNum AS Expr1,
	--	Alp_tblJmSvcTktPmt.PmtAmt,
	--	tblArCashRcptHeader.RcptHeaderID, tblArTransHeader.DistCode, isnull(@PmtAmtFgn, Alp_tblJmSvcTktPmt.PmtAmt)
	--	FROM Alp_tblJmSvcTkt INNER JOIN ((Alp_tblJmSvcTktPmt INNER JOIN tblArTransHeader ON Alp_tblJmSvcTktPmt.TicketId = tblArTransHeader.AlpJobNum)
	--	INNER JOIN tblArCashRcptHeader ON tblArTransHeader.TransId = tblArCashRcptHeader.InvcTransID) ON Alp_tblJmSvcTkt.TicketId = Alp_tblJmSvcTktPmt.TicketId
	--	WHERE Alp_tblJmSvcTktPmt.TicketId = @ID

	--END
	--ELSE
	BEGIN
		INSERT INTO tblArCashRcptDetail (  InvcNum, PmtAmt, RcptHeaderID, DistCode, PmtAmtFgn )
		SELECT 
		@InvcNum AS Expr1,
		Alp_tblJmSvcTktPmt.PmtAmt,
		@pRcptHeaderID, @pDistCode, Alp_tblJmSvcTktPmt.PmtAmt
		FROM ALP_tblJmSvcTkt  INNER JOIN ALP_tblJmSvcTktPmt  	ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktPmt.TicketId  
	   WHERE ALP_tblJmSvcTkt.TicketId =@ID  AND CashRcptCreated=0
		
		
		SELECT @pRcptDetailID=IDENT_CURRENT('tblArCashRcptDetail') ;
	
	   INSERT INTO Alp_tblArCashRcptDetail (AlpRcptDetailID,AlpSiteID,AlpComment)
	   SELECT @pRcptDetailID,@pSiteID ,ALP_tblJmSvcTktPmt.Note 
		FROM ALP_tblJmSvcTkt  INNER JOIN ALP_tblJmSvcTktPmt  	ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktPmt.TicketId  
	WHERE ALP_tblJmSvcTkt.TicketId =@ID  AND CashRcptCreated=0
	
	END
end