
CREATE PROCEDURE dbo.trav_BrTransactionJournal_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD',
@SortBy tinyint = 0, -- 0, Transaction Number; 1, Fiscal Year/Period/GL Account; 2, Bank Account;
@BaseCurrency pCurrency = 'USD'
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpBrJrnlRpt
	(
		TransID pTransId NOT NULL,
		BankID pBankId NOT NULL,
		TransType smallint NOT NULL,
		SourceID nvarchar(10) NULL,
		Descr pDescription NULL,
		TransDate datetime NULL,
		GLPeriod smallint NOT NULL,
		FiscalYear smallint NOT NULL,
		Reference nvarchar(255) NULL,
		EntryNum int NULL,
		GLAcct pGlAcct NULL,
		DrAmount pDecimal NOT NULL,
		CrAmount pDecimal NOT NULL,
		VoidYn bit NOT NULL,
		VoidAmount pDecimal NOT NULL,
		Header pDecimal NOT NULL,
		XferToBankID pBankId NULL,
		AcctType tinyint NOT NULL
	)

	--BankIDXferTo
	INSERT INTO #tmpBrJrnlRpt (TransID, BankID, TransType, SourceID, Descr, TransDate, GLPeriod,
		FiscalYear, Reference, EntryNum, GLAcct, DrAmount, CrAmount, VoidYn,
		VoidAmount, Header, XferToBankID,AcctType)
	SELECT h.TransID, h.BankID, h.TransType,h.SourceID, d.Descr, h.TransDate, h.GLPeriod,
		h.FiscalYear, d.Reference, d.EntryNum, d.GLAcct,
		CASE WHEN @PrintAllInBase = 1 OR @BaseCurrency = @ReportCurrency THEN d.DebitAmt ELSE d.DebitAmtFgn END AS DrAmount,
		CASE WHEN @PrintAllInBase = 1 OR @BaseCurrency = @ReportCurrency THEN d.CreditAmt ELSE d.CreditAmtFgn END AS DrAmount,
		h.VoidYn, 0, 0 AS Header, CASE WHEN TransType = -3 THEN BankIDXferTo ELSE NULL END AS XferToBankID,b.AcctType
	FROM #tmpTransactionList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.TransId
		INNER JOIN dbo.tblSmBankAcct b ON h.BankId = b.BankId
		INNER JOIN dbo.tblBrJrnlDetail d ON h.TransID = d.TransID
	WHERE (@PrintAllInBase = 1 OR h.CurrencyID = @ReportCurrency)

	INSERT INTO #tmpBrJrnlRpt (TransID, BankID, TransType, SourceID, Descr, TransDate, GLPeriod,
		FiscalYear, Reference, EntryNum, GLAcct, DrAmount, CrAmount, VoidYn,
		VoidAmount, Header, XferToBankID,AcctType)
	SELECT h.TransID, h.BankID, h.TransType, h.SourceID, h.Descr, h.TransDate, h.GLPeriod,
		h.FiscalYear, h.Reference, 0 AS EntryNum, b.GlCashAcct,
		CASE WHEN h.VoidYn = 1 THEN 0 ELSE CASE WHEN @PrintAllInBase = 1 THEN
			CASE WHEN (TransType * Amount) >= 0 THEN ABS(Amount)ELSE 0 END
		ELSE
			CASE WHEN (TransType * AmountFgn) >= 0 THEN ABS(AmountFgn)ELSE 0 END
		END END AS DrAmount,
		CASE WHEN h.VoidYn = 1 THEN 0 ELSE CASE WHEN @PrintAllInBase = 1 THEN
			CASE WHEN (TransType * Amount) < 0 THEN ABS(Amount)ELSE 0 END
		ELSE
			CASE WHEN (TransType * AmountFgn) < 0 THEN ABS(AmountFgn)ELSE 0 END
		END END AS CrAmount, h.VoidYn,
		CASE WHEN h.VoidYn = 1 THEN
			CASE WHEN @PrintAllInBase = 1 THEN ABS(Amount)ELSE ABS(AmountFgn)END
		ELSE 0 END AS VoidAmount, -1 AS Header, NULL, b.AcctType
	FROM #tmpTransactionList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.TransId
		INNER JOIN dbo.tblSmBankAcct b ON h.BankId = b.BankId
	WHERE (@PrintAllInBase = 1 OR h.CurrencyID = @ReportCurrency)

	SELECT CASE @SortBy 
			WHEN 0 THEN TransId
			WHEN 1 THEN RIGHT('0000' + CAST(FiscalYear AS nvarchar), 4) + RIGHT('000' + CAST(GlPeriod AS nvarchar), 3)
			ELSE BankId	END GrpId1,
		CASE @SortBy WHEN 0 THEN BankId	WHEN 1 THEN GlAcct	ELSE STR(TransType)	END GrpId2,
		CASE @SortBy
			WHEN 0 THEN RIGHT('0000' + CAST(FiscalYear AS nvarchar), 4) + RIGHT('000' + CAST(GlPeriod AS nvarchar), 3)
			WHEN 1 THEN TransId	ELSE TransId END GrpId3,
		CASE @SortBy WHEN 0 THEN GlAcct	WHEN 1 THEN BankId	ELSE GlAcct	END GrpId4,
		TransID, BankID, TransType, SourceID, Descr, TransDate, GLPeriod, FiscalYear,
		Reference, EntryNum, GLAcct, DrAmount, CrAmount, VoidYn, VoidAmount, XferToBankID, AcctType
	FROM #tmpBrJrnlRpt

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrTransactionJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrTransactionJournal_proc';

