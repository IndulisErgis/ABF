
CREATE PROCEDURE dbo.trav_ArPrepareCommission_Calculate_proc
AS

SET NOCOUNT ON
BEGIN TRY
	DECLARE @CutoffDate datetime, @PrecCurr smallint,@CommNetZeroAsPaid bit

	--Retrieve global values
	SELECT @CutoffDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'CutoffDate'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @CommNetZeroAsPaid = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'CommNetZeroAsPaid' 

	IF @CutoffDate IS NULL OR @PrecCurr IS NULL OR @CommNetZeroAsPaid IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	CREATE TABLE #tmp
	(
		[Counter] int, 
		SalesRepId pSalesRep,
		CustId pCustID NULL,
		InvcNum pInvoiceNum,
		InvcDate DateTime,
		AmtPmt pDecimal, 
		BasedOnDtl tinyint, 
		CommRateDtl pDecimal, 
		TotPossComm pDecimal, 
		BaseAmt pDecimal, 
		NetInvcAmt pDecimal,
		AdjInvcAmt pDecimal,
		AdjAmtPmt pDecimal
	)

	-- prepare commissions for all non-held & non-completed invoices (keep BaseAmt unrounded until calcs are completed)
	INSERT INTO #tmp([Counter], SalesRepId, CustId, InvcNum, InvcDate, AmtPmt, BasedOnDtl, CommRateDtl, TotPossComm, BaseAmt, NetInvcAmt, AdjInvcAmt, AdjAmtPmt) 
		SELECT [Counter], c.SalesRepId, c.CustId, c.InvcNum, c.InvcDate
			, AmtPmt - ISNULL(o.ExcludePmts, 0), BasedOnDtl, CommRateDtl, 0 -- exclude payments outside the cutoff date
			, CASE WHEN PctOfDtl = 0 THEN 0 
				WHEN PctOfDtl = 1 THEN (AmtLines * ABS(PayLines) + AmtTax * ABS(PayTax) + AmtFreight * ABS(PayFreight) 
					+ AmtMisc * ABS(PayMisc)) * (PctInvc / 100) 
				WHEN PctOfDtl = 2 THEN (AmtLines * ABS(PayLines) + AmtTax * ABS(PayTax) + AmtFreight * ABS(PayFreight) 
					+ AmtMisc * ABS(PayMisc) - AmtCogs) * (PctInvc /100) END
			, AmtInvc, AmtInvc, AmtPmt - ISNULL(o.ExcludePmts, 0)
		FROM dbo.tblArCommInvc c 
			INNER JOIN dbo.tblArSalesRep s ON c.SalesRepID = s.SalesRepID 
			INNER JOIN #SalesRepList l on s.SalesRepId = l.SalesRepId
			LEFT JOIN (SELECT InvcNum, CustId, SUM(Amt) ExcludePmts 
					FROM dbo.tblArOpenInvoice 
					WHERE RecType = -2 AND TransDate > @CutoffDate 
					GROUP BY InvcNum, CustId) o 
			ON c.InvcNum = o.InvcNum AND c.CustId = o.CustId 
		WHERE c.HoldYn = 0 AND c.CompletedDate IS NULL AND c.InvcDate <= @CutoffDate

	--check for commissions to process - exit when nothing to process
	IF @@RowCount = 0 
	BEGIN
		RETURN 0
	END

	--Calculate an adjusted total invoice amount to properly apply "credits" to "invoices" 
	--	as well as the cumulative total of applied payment (max payment amount) for processing "paid invoices"
	--	group by SalesRepId, CustId, Invoice Number, date and amount to isolate unique trans amounts when using line item commissions
	Update #tmp Set AdjInvcAmt = stot.SumAmtInvc, AdjAmtPmt = stot.MaxAmtPmt
		FROM (Select SalesRepId, CustId, InvcNum, Sum(NetInvcAmt) SumAmtInvc, Max(AmtPmt) MaxAmtPmt
			From (Select SalesRepId, CustId, InvcNum, NetInvcAmt, AmtPmt
				From #tmp 
				Group By SalesRepId, CustId, InvcNum, InvcDate, NetInvcAmt, AmtPmt
			) tmp 
			Group By SalesRepId, CustId, InvcNum
		) stot 
	Where #tmp.SalesRepId = stot.SalesRepId And ISNULL(#tmp.CustId, '') = ISNULL(stot.CustId, '') And #tmp.InvcNum = stot.InvcNum

	UPDATE #tmp SET TotPossComm = CASE WHEN NetInvcAmt = 0 AND BasedOnDtl = 1 AND @CommNetZeroAsPaid=0 THEN 0  
		ELSE ROUND(ROUND(BaseAmt, @PrecCurr) * (CommRateDtl /100), @PrecCurr) END, BaseAmt = ROUND(BaseAmt, @PrecCurr) --PET:229236


	--reset all previously prepared commissions
	UPDATE dbo.tblArCommInvc SET AmtPrepared = 0

	--update the newly prepared commissions
	--	all of the remaining amount due when fully paid
	--	otherwise a percentage based on the amount paid
	UPDATE dbo.tblArCommInvc 
	SET AmtPrepared = CASE WHEN AdjInvcAmt = 0 OR (AdjInvcAmt - AdjAmtPmt) <= 0
		THEN TotPossComm + AmtAdjust - CommPaid
		ELSE ROUND(TotPossComm * (AdjAmtPmt / AdjInvcAmt), @PrecCurr) + AmtAdjust - CommPaid
		END
	FROM dbo.tblArCommInvc c INNER JOIN #tmp ON c.[Counter] = #tmp.Counter
	WHERE c.BasedOnDtl = 1

	UPDATE dbo.tblArCommInvc SET AmtPrepared = TotPossComm + AmtAdjust - CommPaid 
		FROM dbo.tblArCommInvc c INNER JOIN #tmp ON c.[Counter] = #tmp.Counter
		WHERE c.BasedOnDtl = 0


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPrepareCommission_Calculate_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPrepareCommission_Calculate_proc';

