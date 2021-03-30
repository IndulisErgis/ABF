
CREATE PROCEDURE dbo.trav_InTransactionJournal_proc 
@CurrencyPrecision tinyint = 2,
@SortBy tinyint = 0 -- 0, Item ID/Location ID; 1, Location ID/Item ID; 2, Transaction Type; 3, Batch/Transaction Number
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #InTransJrnl
	(
		BatchId pBatchId Not Null,
		TransId int NOT NULL, 
		LineType tinyint NOT NULL DEFAULT(1),
		ItemId nvarchar(24) NULL, 
		Descr nvarchar (255) NULL, 
		LocId nvarchar (10) NULL, 
		ItemType tinyint NOT NULL DEFAULT(1), 
		LottedYN bit DEFAULT(0), 
		Cmnt nvarchar (35) NULL, 
		TransType tinyint NULL,
		TransDate datetime NULL, 
		Uom nvarchar(5) NULL, 
		SumYear smallint DEFAULT(0), 
		GlPeriod smallint DEFAULT(0), 
		PriceId nvarchar(10) NULL, 
		Qty pDecimal DEFAULT(0), 
		PriceUnit pDecimal NULL, 
		CostUnit pDecimal NULL, 
		CostUnitStd pDecimal NULL, 
		LotNum nvarchar(16) NULL, 
		SerNum nvarchar(35) NULL,
		PPVAmt pDecimal NULL
	)

	INSERT INTO #InTransJrnl (BatchId,LineType,TransId,ItemId,Descr,LocId,TransType,ItemType,LottedYN,
		TransDate,Uom,SumYear,GlPeriod,PriceId,Qty,PriceUnit,CostUnit,CostUnitStd,cmnt,PPVAmt) 
	SELECT t.BatchId,1,t.TransId,t.ItemId,i.Descr,t.LocId,t.TransType,i.ItemType,i.LottedYN,
		t.TransDate,t.Uom,t.SumYear,t.GlPeriod,t.PriceId,t.Qty,t.PriceUnit,t.CostUnitTrans,l.CostStd * u.ConvFactor,t.Cmnt,
		CASE WHEN t.TransType IN (12,14,25,31) THEN 1 ELSE 0 END 
			* (ROUND(t.Qty * t.CostUnitTrans,@CurrencyPrecision) - ROUND(t.Qty * l.CostStd * u.ConvFactor,@CurrencyPrecision))
	FROM #tmpTransactionList m INNER JOIN dbo.tblInTrans t ON m.TransId = t.TransId 
		INNER JOIN dbo.tblInItem i ON t.ItemId = i.ItemId 
		INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId 
		INNER JOIN dbo.tblInItemUom u ON t.ItemId = u.ItemId AND t.Uom = u.Uom

	INSERT INTO #InTransJrnl (BatchId, TransId,ItemId,LocId,TransType,ItemType,LottedYN,LineType,LotNum,CostUnit,Qty,Cmnt)
	SELECT t.BatchId, t.TransId, t.ItemId, t.LocId, t.TransType, 
		t.ItemType, t.LottedYN, 2, l.LotNum, l.CostUnit, 
		CASE WHEN transType = 11 or TransType = 21 THEN QtyOrder ELSE QtyFilled END,t.Cmnt
	FROM tblInTransLot l INNER JOIN #InTransJrnl t ON l.TransID = t.TransId 
	WHERE t.LineType = 1

	INSERT INTO #InTransJrnl (BatchId, TransId,ItemId,LocId,TransType,ItemType,LottedYN,LineType,LotNum,SerNum,CostUnit,PriceUnit,Qty,Cmnt)
	SELECT t.BatchId, t.TransId, t.ItemId, t.LocId, t.TransType, 
		t.ItemType, t.LottedYN, 3, s.LotNum, s.SerNum, s.CostUnit, s.PriceUnit, 1 , t.Cmnt
	FROM tblInTransSer s INNER JOIN #InTransJrnl t ON s.TransID = t.TransId 
	WHERE t.LineType = 1

	SELECT CASE @SortBy WHEN 0 THEN LEFT(ItemId + REPLICATE(' ',24),24) + LocId WHEN 1 THEN LEFT(LocId + REPLICATE(' ',10),10) + ItemId 
			WHEN 2 THEN CAST(TransType AS nvarchar) + LEFT(ItemId + REPLICATE(' ',24),24) + LocId 
			WHEN 3 THEN LEFT(BatchId + REPLICATE(' ',6),6) + RIGHT(REPLICATE(' ',10) + CAST(TransId AS nvarchar),10) + LEFT(ItemId + REPLICATE(' ',24),24) + LocId END AS SortBy,
		BatchId,LineType,TransId,ItemId,Descr,LocId,TransType,ItemType,LottedYN,
		TransDate,Uom,SumYear,GlPeriod,PriceId,Qty,PriceUnit,CostUnit,CostUnitStd,
		LotNum,SerNum,Cmnt,PPVAmt
	FROM #InTransJrnl

	SELECT p.TransType,ISNULL(t.ExtCost , 0) ExtCost, ISNULL(t.ExtPrice, 0) ExtPrice,
		CASE WHEN p.TransType IN (15,23,24,32) THEN -1 WHEN p.TransType IN (12,14,25,31) THEN 1 ELSE 0 END * ISNULL(t.ExtCost , 0) AS InValue,
		CASE p.TransType WHEN 31 THEN 1 WHEN 32 THEN 2 WHEN 21 THEN 3 WHEN 23 THEN 4 WHEN 24 THEN 5 WHEN 25 THEN 6 WHEN 11 THEN 7 WHEN 12 THEN 8 WHEN 14 THEN 9 WHEN 15 THEN 10 END SortBy
	FROM 
		(
			 SELECT 11 AS TransType UNION ALL
			 SELECT 12 UNION ALL	 
			 SELECT 14 UNION ALL
			 SELECT 15 UNION ALL
			 SELECT 21 UNION ALL
			 SELECT 23 UNION ALL
			 SELECT 24 UNION ALL
			 SELECT 25 UNION ALL
			 SELECT 31 UNION ALL
			 SELECT 32 
		) p 
		LEFT JOIN 
		(
			SELECT t.TransType , SUM(ROUND(t.CostUnitTrans * t.Qty, @CurrencyPrecision) ) ExtCost,
				SUM(ROUND(t.PriceUnit * t.Qty, @CurrencyPrecision) ) ExtPrice 
			FROM #tmpTransactionList m INNER JOIN dbo.tblInTrans t ON m.TransId = t.TransId
			GROUP BY t.TransType
		) t ON p.TransType = t.TransType

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransactionJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransactionJournal_proc';

