
CREATE PROCEDURE dbo.trav_InMatReqTransPost_GlLog_proc
AS
BEGIN TRY

	DECLARE @UserID nvarchar(20), @WrkStnID nvarchar(20),@PrecCurr tinyint,
		@gInPostDtlGlYn bit,@WrkStnDate datetime, @InJcYn bit, @PostRun pPostRun,
		@CurrBase pCurrency,@CompId nvarchar(3)

	CREATE TABLE #tmpInMatReq
	(
		[TransID] [int] NULL,
		[LineNum] [int] NULL,
		[GlPeriod] [smallint] NULL,
		[GlAcct] [nvarchar](24) NULL,
		[ReqNum] [nvarchar](10) NULL,
		[Descr] [nvarchar](30) NULL,
		[DRAmt] pDecimal NOT NULL DEFAULT (0),
		[CRAmt] pDecimal  NOT NULL DEFAULT (0),
		[SourceCode] [nvarchar](2) NULL,
		[TransDate] [datetime] NULL,
		[PostDate] [datetime] NULL,
		[Year] [smallint] NULL,
		[Source] [smallint] NULL
	)

	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @gInPostDtlGlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlGlYn'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @InJcYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'JcYn'
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'

	IF @gInPostDtlGlYn IS NULL OR @PrecCurr IS NULL 
		OR @WrkStnDate IS NULL OR @InJcYn IS NULL OR @PostRun IS NULL OR @CurrBase IS NULL OR @CompId IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	SELECT h.TransID, d.LineNum, g.GLAcctInv, @UserID UserID, @WrkStnID WrkStnID, h.ReqType 
	INTO #tmpGLAcctInv 
	FROM tblInMatReqHeader h 
		INNER JOIN tblInMatReqDetail d ON h.TransId = d.TransId 
		INNER JOIN tblInItemLoc l ON d.ItemId = l.ItemId AND d.LocId = l.LocId 
		INNER JOIN tblInGLAcct g ON g.GLAcctCode = l.GLAcctCode
		INNER JOIN #PostTransList t ON h.TransId = t.TransId

	IF (@gInPostDtlGlYn = 1)
	BEGIN
		INSERT INTO #tmpInMatReq (TransID, LineNum, GlPeriod, GlAcct, ReqNum
			, Descr, DRAmt, CRAmt, TransDate, PostDate, [Year], SourceCode, [Source])
		SELECT h.TransID, d.LineNum, h.GLPeriod, d.GLAcctNum, h.ReqNum
			, SUBSTRING(CASE WHEN GLDescr IS NULL THEN (CASE WHEN @InJcYn = 1 AND d.CustId IS NOT NULL 
					THEN d.CustId + '/' + d.ProjId ELSE d.ItemId + ' ' + d.Descr END) 
				ELSE GLDescr END, 1, 30)
			, CASE WHEN SIGN(h.ReqType) * ROUND(QtyFilled * CostUnitStd, @PrecCurr) > 0 
				THEN SIGN(h.ReqType) * ROUND(QtyFilled * CostUnitStd, @PrecCurr) ELSE 0 END
			, CASE WHEN SIGN(h.ReqType) * ROUND(QtyFilled * CostUnitStd, @PrecCurr) > 0 
				THEN 0 ELSE ABS(SIGN(h.ReqType) * ROUND(QtyFilled * CostUnitStd, @PrecCurr)) END
			, h.DatePlaced, @WrkStnDate, h.SumYear, 'IN', CASE WHEN h.ReqType > 0 THEN 75 ELSE 17 END
		FROM dbo.tblInMatReqHeader h INNER JOIN (dbo.tblInMatReqDetail d INNER JOIN dbo.tblInItem i ON d.ItemId = i.ItemId) ON h.TransId = d.TransId 
			INNER JOIN #PostTransList t ON h.TransId = t.TransId
		WHERE (d.QtyFilled * d.CostUnitStd) <> 0

		INSERT INTO #tmpInMatReq (TransID, LineNum, GlPeriod, GlAcct, ReqNum
			, Descr, DRAmt, CRAmt, TransDate, PostDate, [Year], SourceCode, [Source])
		SELECT a.TransID, a.LineNum, GLPeriod, b.GLAcctInv, 	'Mtrl Inv'
			, CASE WHEN b.ReqType > 0 THEN 'Amount from Material Inventory' ELSE 'Amount to Material Inventory' END
			, CASE WHEN CRAmt - DRAmt > 0 THEN CRAmt - DRAmt ELSE 0 END
			, CASE WHEN DRAmt - CRAmt > 0 THEN DRAmt - CRAmt ELSE 0 END
			, TransDate, PostDate, [Year], SourceCode, CASE WHEN b.ReqType > 0 THEN 75 ELSE 17 END 
		FROM #tmpInMatReq a INNER JOIN #tmpGLAcctInv b ON a.TransId = b.TransId AND a.LineNum = b.LineNum 
	END
	ELSE
	BEGIN
		INSERT INTO #tmpInMatReq (GlPeriod, GlAcct, ReqNum
			, Descr, DRAmt, CRAmt, TransDate, PostDate, [Year], SourceCode)
		SELECT h.GLPeriod, b.GLAcctInv, MIN(h.ReqNum)
			, CASE WHEN h.ReqType > 0 THEN 'Amount from Material Inventory' ELSE 'Amount to Material Inventory' END
			, CASE WHEN SUM(SIGN(h.ReqType) * ROUND(QtyFilled * CostUnitStd, @PrecCurr)) > 0 
				THEN 0 ELSE ABS(SUM(SIGN(h.ReqType) * ROUND(QtyFilled * CostUnitStd, @PrecCurr))) END
			, CASE WHEN SUM(SIGN(h.ReqType) * ROUND(QtyFilled * CostUnitStd, @PrecCurr)) > 0 
				THEN SUM(SIGN(h.ReqType) * ROUND(QtyFilled * CostUnitStd, @PrecCurr)) ELSE 0 END
			, MIN(h.DatePlaced), @WrkStnDate, h.SumYear, 'IN' 
		FROM dbo.tblInMatReqHeader h 
			INNER JOIN dbo.tblInMatReqDetail d ON h.TransId = d.TransId 
			INNER JOIN #tmpGLAcctInv b ON d.TransId = b.TransId AND d.LineNum = b.LineNum 
		WHERE (d.QtyFilled * d.CostUnitStd) <> 0 GROUP BY h.GLPeriod, b.GLAcctInv, h.SumYear, h.ReqType

		INSERT INTO #tmpInMatReq (GlPeriod, GlAcct, ReqNum
			, Descr, DRAmt, CRAmt, TransDate, PostDate, [Year], SourceCode)
		SELECT h.GLPeriod, d.GLAcctNum, MIN(h.ReqNum)
			, NULLIF(SUBSTRING(MIN(ISNULL(GLDescr, '')), 1, 30), '')
			, CASE WHEN SUM(SIGN(h.ReqType) * ROUND(QtyFilled * CostUnitStd, @PrecCurr)) > 0 
				THEN SUM(SIGN(h.ReqType) * ROUND(QtyFilled * CostUnitStd, @PrecCurr)) ELSE 0 END
			, CASE WHEN SUM(SIGN(h.ReqType) * ROUND(QtyFilled * CostUnitStd, @PrecCurr)) > 0 
				THEN 0 ELSE ABS(SUM(SIGN(h.ReqType) * ROUND(QtyFilled * CostUnitStd, @PrecCurr))) END
			, MIN(h.DatePlaced), @WrkStnDate, h.SumYear, 'IN' 
		FROM dbo.tblInMatReqHeader h INNER JOIN dbo.tblInMatReqDetail d ON h.TransId = d.TransId 
			INNER JOIN #PostTransList t ON h.TransId = t.TransId
		WHERE (d.QtyFilled * d.CostUnitStd) <> 0 GROUP BY h.GLPeriod, d.GLAcctNum, h.SumYear
	END

	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompID,LinkID,LinkIDSubLine)
	SELECT @PostRun, [Year], GlPeriod, GlAcct,ABS(DRAmt-CRAmt),ReqNum,Descr,DRAmt,
			CRAmt,DRAmt,CRAmt,SourceCode,PostDate,TransDate,@CurrBase,1,@CompId,TransID,[Source]
	FROM  #tmpInMatReq
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InMatReqTransPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InMatReqTransPost_GlLog_proc';

