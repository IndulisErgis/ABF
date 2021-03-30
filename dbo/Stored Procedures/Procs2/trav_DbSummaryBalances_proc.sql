
CREATE PROCEDURE dbo.trav_DbSummaryBalances_proc
@Prec tinyint = 2, 
@Foreign bit = 0, 
@Wksdate datetime =   null

AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @FiscalYear smallint, @Period smallint
DECLARE @GlPostedCash pDecimal, @GlUnpostedCash pDecimal, @ApGrossAmtDue pDecimal, @ApRegCheckTotal pDecimal
	DECLARE @ArPmtAmt pDecimal, @ArPmtDifference pDecimal, @ArOpenInvcAmt pDecimal, @ArTaxable pDecimal, @ArNonTaxable pDecimal
	DECLARE @InValue pDecimal, @PcTimeTickets pDecimal
	DECLARE @PaTotInProcess pDecimal, @PaTimeTickets pDecimal, @TotInvoiced pDecimal

	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	/*  GlAccountDetail  */
	SELECT @GlPostedCash = ROUND(SUM(CASE WHEN d.[Year] = @FiscalYear AND d.Period <= @Period 
			AND (AcctTypeId BETWEEN 5 AND 10) 
		THEN (CASE BalType WHEN -1 THEN ISNULL(-d.Actual, 0) ELSE ISNULL(d.Actual, 0) END) ELSE 0 END), @Prec) 
	FROM dbo.tblGlAcctHdr h 
		LEFT JOIN dbo.tblGlAcctDtl d ON h.AcctId = d.AcctId 

	/*  GlJournal  */
	SELECT @GlUnpostedCash = GlUnpostedCash 
	FROM 
	(
		SELECT ROUND(SUM(CASE WHEN PostedYn = 0 AND [Year] = @FiscalYear AND Period <= @Period 
				AND (AcctTypeId BETWEEN 5 AND 10) 
			THEN (SIGN(BalType) * (DebitAmt - CreditAmt)) ELSE 0 END), @Prec) AS GlUnpostedCash 
		FROM dbo.tblGlJrnl j LEFT JOIN dbo.tblGlAcctHdr h ON j.AcctId = h.AcctId
	) tmp

	/*  ApOpenInvoices  */
	SELECT @ApGrossAmtDue = ApGrossAmtDue 
	FROM 
	(
		SELECT ROUND(SUM(CASE WHEN Status IN (0, 1, 2) AND InvoiceDate <= @WksDate 
			THEN (CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) 
			ELSE 0 END), @Prec) AS ApGrossAmtDue 
		FROM dbo.tblApOpenInvoice
	) tmp

	/*  ApPrepChkCtrl  */
	SELECT @ApRegCheckTotal = ApRegCheckTotal 
	FROM 
	(
		SELECT ROUND(SUM(CASE WHEN CheckDate <= @WksDate 
			THEN (CASE WHEN @Foreign = 0 THEN CheckAmountTotal ELSE CheckAmountTotalFgn END) 
			ELSE 0 END), @Prec) AS ApRegCheckTotal 
		FROM dbo.tblApPrepChkCntl
	) tmp

	/*  ArCashReceipts  */
	SELECT @ArPmtAmt = ArPmtAmt, @ArPmtDifference = ArPmtDifference 
	FROM 
	(
		SELECT ISNULL(SUM(d.PmtAmt + d.CalcGainLoss), 0) AS ArPmtAmt
			, ISNULL(SUM([Difference]), 0) AS ArPmtDifference 
		FROM dbo.tblArCashRcptHeader h 
			LEFT JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderId = d.RcptHeaderId 
			LEFT JOIN dbo.tblArPmtMethod p ON h.PmtMethodId = p.PmtMethodId
	) tmp

	/*  ArOpenInvoices  */
	SELECT @ArOpenInvcAmt = ArOpenInvcAmt 
	FROM 
	(
		SELECT ROUND(SUM(CASE WHEN TransDate <= @WksDate 
			THEN (CASE WHEN @Foreign = 0 THEN (SIGN(i.RecType) * i.Amt) 
				ELSE (SIGN(i.RecType) * i.AmtFgn) END) 
			ELSE 0 END), @Prec) AS ArOpenInvcAmt 
		FROM dbo.tblArOpenInvoice i INNER JOIN dbo.tblArCust c ON i.CustId = c.CustId
	) tmp

	/*  ArTransHeader  */
	SELECT @ArTaxable = ArTaxable, @ArNonTaxable = ArNonTaxable 
	FROM 
	(
		SELECT ROUND(SUM(CASE WHEN OrderDate <= @WksDate 
				THEN (SIGN(TransType) * TaxSubtotal) ELSE 0 END), @Prec) AS ArTaxable
			, ROUND(SUM(CASE WHEN OrderDate <= @WksDate 
				THEN (SIGN(TransType) * NonTaxSubtotal) ELSE 0 END), @Prec) AS ArNonTaxable 
		FROM dbo.tblArTransHeader WHERE VoidYn = 0
	) tmp

	/*  InItem  */
	SELECT @InValue = InValue 
	FROM 
	(
		SELECT SUM(ISNULL(CASE WHEN i.ItemType = 2 THEN s.Cost ELSE q.Cost END, 0)) AS InValue 
		FROM dbo.tblInItem i 
			INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId 
			LEFT JOIN dbo.tblInItemUOM u ON i.ItemId = u.ItemId And i.UomBase = u.UOM 
			LEFT JOIN 
				(
					SELECT ItemId, LocId, CAST(SUM((Qty - InvoicedQty - RemoveQty) * Cost) AS float) AS Cost 
					FROM dbo.tblInQtyOnHand 
					GROUP BY ItemId, LocId
				) q 
				ON l.ItemId = q.ItemId AND l.LocId = q.LocId 
			LEFT JOIN 
				(
					SELECT ItemId, LocId
						, CAST(SUM(CASE SerNumStatus WHEN 5 THEN 0 ELSE CostUnit END) AS float) AS Cost 
					FROM dbo.tblInItemSer 
					WHERE (SerNumStatus = 1) OR (SerNumStatus = 2) OR (SerNumStatus = 5) 
					GROUP BY ItemId, LocId
				) s 
				ON l.ItemId = s.ItemId AND l.LocId = s.LocId
	) tmp


/*  PcTimeTickets  */
	SELECT @pcTimeTickets = PcTimeTickets 
	FROM 
	(
		SELECT ROUND(SUM(CAST(Qty  * UnitCost AS float)), @Prec) AS PcTimeTickets 
		FROM dbo.tblPcTimeTicket  
	) tmp


	/*  PaChecksWritten  */
SELECT @PaTotInProcess = SUM(CASE WHEN CheckDate <= @WksDate THEN NetPay ELSE 0 END)
	FROM dbo.tblPaCheck
	

	/*  PaTimeTickets  */
	SELECT @PaTimeTickets = SUM(Amount) FROM dbo.tblPaTransEarn

	/*  PoStatistics  */
	SELECT @TotInvoiced = TotInvoiced 
	FROM 
	(
		SELECT ISNULL(ROUND(SUM(CASE WHEN @Foreign = 0 THEN ((Subtotal) * SIGN(TransType)) 
			ELSE ((SubtotalFgn) * SIGN(TransType))END), @Prec), 0) AS TotInvoiced 
		FROM dbo.tblApTransHeader
	) tmp

	-- return resultset
	SELECT ISNULL(@ApGrossAmtDue, 0) + ISNULL(@TotInvoiced, 0) - ISNULL(@ApRegCheckTotal, 0) AS ApBalance
		, ISNULL(@ArOpenInvcAmt, 0) - ISNULL(@ArPmtAmt, 0) - ISNULL(@ArPmtDifference, 0) 
			+ ISNULL(@ArTaxable, 0) + ISNULL(@ArNonTaxable, 0) AS ArBalance
		, ISNULL(@GlPostedCash, 0) + ISNULL(@GlUnpostedCash, 0) + ISNULL(@ArPmtAmt, 0) 
			- ISNULL(@ApRegCheckTotal, 0) - ISNULL(@PaTotInProcess, 0) AS CashBalance
		, ISNULL(@InValue, 0) AS InValue
		, ISNULL(@PcTimeTickets, 0) + ISNULL(@PaTimeTickets, 0) AS TimeTicketTotal
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbSummaryBalances_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbSummaryBalances_proc';

