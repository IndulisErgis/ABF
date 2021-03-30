
CREATE PROCEDURE dbo.trav_ArCashReceiptPost_History_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun, @WrkStnDate datetime

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'

	IF @PostRun IS NULL OR @WrkStnDate IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	--append customer addresses
	INSERT INTO dbo.tblArHistAddress (PostRun, CustId, [Name]
		, Contact, Attn, Address1, Address2, City, Region, Country, PostalCode, 
		Phone, Fax, Email, Internet)
	SELECT @PostRun, c.CustId, c.CustName
		, c.Contact, c.Attn, c.Addr1, c.Addr2, c.City, c.Region, c.Country, c.PostalCode
		, c.Phone, c.Fax, c.Email, c.Internet
	FROM dbo.tblArCust c
	INNER JOIN (SELECT h.CustId From dbo.tblArCashRcptHeader h INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId GROUP BY h.CustId) t on c.CustId = t.CustId


	--append prepayments into payment history
	INSERT dbo.tblArHistPmt (PostRun, PostDate, RecType
		, CustId, TransId, DepNum, InvcNum
		, CheckNum, CcNum, CcHolder, CcAuth, CcExpire
		, BankID, BankName, BankRoutingCode, BankAcctNum
		, PmtMethodId, CurrencyId, ExchRate
		, PmtDate, PmtAmt, DiffDisc, PmtAmtFgn, DiffDiscFgn
		, PmtType, SumHistPeriod, GLPeriod, FiscalYear
		, GLRecvAcct, GlAcctGainLoss, GlAcctDebit
		, Rep1Id, Rep2Id, DistCode, CalcGainLoss
		, Note, SourceId, VoidYn, CF) 
	SELECT @PostRun, @WrkStnDate, CASE WHEN ISNULL(h.InvcTransID, '') = '' THEN 0 ELSE 3 END --0=Payment/3=Prepayment
		, h.CustId, CAST(d.RcptDetailId as nvarchar), h.DepositId, d.InvcNum
		, h.CheckNum, h.CcNum, h.CcHolder, h.CcAuth, h.CcExpire
		, h.BankId, h.BankName, h.BankRoutingCode, h.BankAcctNum
		, h.PmtMethodId, h.CurrencyId, h.ExchRate
		, h.PmtDate, d.PmtAmt, d.[Difference], d.PmtAmtFgn, d.DifferenceFgn
		, p.PmtType, h.SumHistPeriod, h.GlPeriod, h.FiscalYear
		, ISNULL(h.GlAcct, dc.GlAcctReceivables), d.GlAcctGainLoss  --default to distcode acct when not provided in pmt
		, CASE WHEN p.PmtType IN (1, 2, 6) THEN b.GlCashAcct ELSE p.GLAcctDebit END --ues the bank gl account for Cash, Check and Direct Debit 
		, c.SalesRepId1, c.SalesRepId2, d.DistCode, d.CalcGainLoss
		, h.Note, h.SourceId, 0, d.CF
	FROM dbo.tblArCashRcptHeader h 
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
	INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId 
	LEFT JOIN dbo.tblArPmtMethod p on h.PmtMethodId = p.PmtMethodId
	LEFT JOIN dbo.tblSmBankAcct b on p.BankId = b.BankId
	LEFT JOIN dbo.tblArCust c on h.CustId = c.CustId
	LEFT JOIN dbo.tblArDistCode dc on d.DistCode = dc.DistCode

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_History_proc';

