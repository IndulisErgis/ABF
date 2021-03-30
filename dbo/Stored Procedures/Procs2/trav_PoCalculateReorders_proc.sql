
CREATE PROCEDURE dbo.trav_PoCalculateReorders_proc 
@StartOver bit = 0, 
@ReplaceOverlap bit = 1,
@FiscalYear smallint = 2009,
@FiscalPeriod smallint = 3,
@PeriodsPerYear smallint = 12,
@IncludeTransferOut bit = 1,
@IncludeMatReq bit = 1,
@IncludeQuantityOnOrder bit = 0,
@CalculateQuantity tinyint = 0, --0, Quantity On Hand; 1, Quantity Available;
@PrecUnitCost tinyint = 4,
@PrecQty tinyint = 4
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #ReorderQty
	(	
		ItemId nvarchar(24) NOT NULL, 
		LocId nvarchar(10) NOT NULL, 
		ExtCost Decimal(28,10) NULL DEFAULT(0), 
		Qty Decimal(28,10) NULL DEFAULT(0), 
		PRIMARY KEY (ItemId, LocId)
	) 

	CREATE TABLE #Reorder 
	(
		ItemId nvarchar (24) NOT NULL ,
		LocId nvarchar (10) NOT NULL , 
		AutoReorderYN bit NOT NULL DEFAULT(0),
		GLAcctInv nvarchar (40) NULL ,
		CostLast Decimal(28,10) NULL DEFAULT(0),
		QtyCmtd Decimal(28,10) NULL DEFAULT(0),
		QtyOnOrder Decimal(28,10) NULL DEFAULT(0),
		UomDflt nvarchar (5) NULL ,
		QtyOrderMin Decimal(28,10) NULL DEFAULT(0),
		QtyOnHandMax Decimal(28,10) NULL DEFAULT(0),
		SafetyStockType tinyint NULL DEFAULT(0),
		QtySafetyStock Decimal(28,10) NULL DEFAULT(0),
		OrderPointType tinyint NULL DEFAULT(0),
		QtyOrderPoint Decimal(28,10) NULL DEFAULT(0),
		EoqType tinyint NULL ,
		Eoq Decimal(28,10) NULL DEFAULT(0),
		ItemType tinyint NULL ,
		ExtCost Decimal(28,10) NULL DEFAULT(0),
		Qty Decimal(28,10) NULL DEFAULT(0), 
		ItemStatus tinyint NULL ,
		ForecastId nvarchar (10) NULL ,
		DfltLeadTime Decimal(28,10) NULL DEFAULT(0),
		LocCarrCostPct Decimal(28,10) NULL DEFAULT(0),
		LocOrderCostAmt Decimal(28,10) NULL DEFAULT(0),
		ItemLocCarrCostPct Decimal(28,10) NULL DEFAULT(0),
		ItemLocOrderCostAmt Decimal(28,10) NULL DEFAULT(0), 
		PRIMARY KEY (ItemId, LocId) 
	)

	CREATE TABLE #Forecast 
	(
		ItemId nvarchar (24) NOT NULL,
		LocId nvarchar (10) NOT NULL, 
		AdjustmentFactor Decimal(28,10) NULL, 
		UsageAnnual Decimal(28,10) NULL, 
		UsageForecast Decimal(28,10) NULL,  
		OrderPoint Decimal(28,10) NULL, 
		FM smallint NULL, 
		HM smallint NULL 
	)

	INSERT INTO #Reorder (ItemId, LocId) 
	SELECT l.ItemID,l.LocID
	FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId
		INNER JOIN dbo.tblInItem i ON l.itemId = i.ItemId
	WHERE i.ItemType <> 3 AND i.ItemStatus = 1 AND l.ItemLocStatus = 1 AND i.KittedYN = 0 

	IF @ReplaceOverlap = 0 
	BEGIN
		DELETE #Reorder 
		FROM #Reorder INNER JOIN dbo.tblPoItemLocReorder r ON #Reorder.ItemId = r.ItemId AND #Reorder.LocId = r.LocId 
	END

	IF EXISTS(SELECT * FROM #Reorder)
	BEGIN
		UPDATE #Reorder 
		SET AutoReorderYN = i.AutoReorderYN, ItemType = i.ItemType, ItemStatus = i.ItemStatus 
		FROM #Reorder INNER JOIN dbo.tblInItem i ON #Reorder.ItemId = i.ItemId 

		UPDATE #Reorder 
		SET LocCarrCostPct = l.CarrCostPct, LocOrderCostAmt = l.OrderCostAmt 
		FROM #Reorder INNER JOIN dbo.tblInLoc l ON #Reorder.LocId = l.LocId 

		UPDATE #Reorder      
		SET CostLast = m.CostLast, QtyOrderMin = m.QtyOrderMin*p.ConvFactor, 
			QtyOnHandMax = m.QtyOnHandMax*p.ConvFactor, SafetyStockType = m.SafetyStockType,
			QtySafetyStock = m.QtySafetyStock*p.ConvFactor, OrderPointType = m.OrderPointType, 
			QtyOrderPoint = m.QtyOrderPoint*p.ConvFactor, EoqType = m.EoqType, Eoq = m.Eoq*p.ConvFactor, 
			ForecastId = m.ForecastId, DfltLeadTime = m.DfltLeadTime, 
			ItemLocCarrCostPct = m.CarrCostPct, ItemLocOrderCostAmt = m.OrderCostAmt,
			UomDflt = m.OrderQtyUOM 
		FROM #Reorder INNER JOIN dbo.tblInItemLoc m ON #Reorder.ItemId = m.ItemId AND #Reorder.LocId = m.LocId
		INNER JOIN dbo.tblInItemUom p On m.ItemId = p.ItemId AND p.Uom = m.OrderQtyUom

		UPDATE #Reorder 
		SET QtyCmtd = q.QtyCmtd, QtyOnOrder = q.QtyOnOrder 
		FROM #Reorder INNER JOIN dbo.trav_InItemQtys_view q ON #Reorder.ItemId = q.ItemId AND #Reorder.LocId = q.LocId 

		UPDATE #Reorder 
		SET GLAcctInv = g.GLAcctInv 
		FROM #Reorder INNER JOIN dbo.tblInItemLoc m ON #Reorder.ItemId = m.ItemId AND #Reorder.LocId = m.LocId
		INNER JOIN dbo.tblInGLAcct g ON m.GLAcctCode = g.GLAcctCode 

		INSERT INTO #ReorderQty (ItemId, LocId, ExtCost, Qty) 
		SELECT q.ItemId, q.LocId, Cost, q.QtyOnHand 
		FROM dbo.trav_InItemOnHand_view q INNER JOIN #Reorder r 
		ON q.ItemId = r.ItemId AND q.LocId = r.LocId 
		WHERE r.ItemType <> 2 

		INSERT INTO #ReorderQty (ItemId, LocId, ExtCost, Qty) 
		SELECT q.ItemId, q.LocId, SUM(q.CostUnit), COUNT(*) 
		FROM dbo.tblInItemSer q INNER JOIN #Reorder r
		ON q.ItemId = r.ItemId AND q.LocId = r.LocId 
		WHERE SerNumStatus < 3 GROUP BY q.ItemId, q.LocId 

		UPDATE #Reorder 
		SET ExtCost = u.ExtCost, Qty = u.Qty 
		FROM #Reorder INNER JOIN #ReorderQty u ON #Reorder.ItemId = u.ItemId AND #Reorder.LocId = u.LocId 

		UPDATE #Reorder SET CostLast = ExtCost / Qty WHERE Qty > 0 

		INSERT INTO dbo.tblPoItemLocReorder (ItemId, LocId)
		SELECT ItemId, LocId FROM #Reorder t 
		WHERE NOT EXISTS (SELECT * FROM dbo.tblPoItemLocReorder 
		WHERE dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId)
		GROUP BY ItemId, LocId

		UPDATE dbo.tblPoItemLocReorder 
		SET UomDflt = t.UomDflt, AutoReorderYN = t.AutoReorderYN, 
			GLInvAcct = t.GlAcctInv, QtyOnOrder = t.QtyOnOrder, 
			QtyOnHand = CASE When @CalculateQuantity = 0 Then t.Qty	 ELSE (t.Qty - t.QtyCmtd) END
		FROM dbo.tblPoItemLocReorder INNER JOIN #Reorder t 
		ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId 

		UPDATE dbo.tblPoItemLocReorder 
		SET OrderPointEoq = t.QtyOrderPoint, OrderPointFrcst = t.QtyOrderPoint, 
			OrderPointMinMax = t.QtyOrderPoint,	FrozenEoq = 1, 
			SafetyStock = (CASE WHEN SafetyStockType = 2 THEN QtySafetyStock ELSE CONVERT(Decimal(28,10), QtyOrderPoint /3) END),
			FrozenFrcst = (CASE WHEN SafetyStockType = 2 THEN 1 ELSE 0 END) 
		FROM dbo.tblPoItemLocReorder INNER JOIN #Reorder t 
		ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId 
		WHERE t.OrderPointType = 2 

		INSERT INTO #Forecast 
		SELECT t.ItemId, t.LocId, ISNULL(MIN(x.AdjFactor),0), 
			SUM(QtySold - QtyRetSold + 
			(CASE WHEN @IncludeTransferOut = 1 THEN QtyXferOut - QtyXferIn ELSE 0 END) + 
			(CASE WHEN @IncludeMatReq = 1 THEN QtyMatReq ELSE 0 END)), 
			SUM((QtySold - QtyRetSold + 
			(CASE WHEN @IncludeTransferOut = 1 THEN QtyXferOut - QtyXferIn ELSE 0 END) + 
			(CASE WHEN @IncludeMatReq = 1 THEN QtyMatReq ELSE 0 END)) / 100 * WeightFactor),
			SUM((QtySold - QtyRetSold + 
			(CASE WHEN @IncludeTransferOut = 1 THEN QtyXferOut - QtyXferIn ELSE 0 END) + 
			(CASE WHEN @IncludeMatReq = 1 THEN QtyMatReq ELSE 0 END)) / 100 * WeightFactor),
			ISNULL(MIN(v.FC),0), COUNT(h.SumPeriod)
		FROM (#Reorder t LEFT JOIN (SELECT f.ForecastType, f.AdjFactor, d.Period, d.WeightFactor
			FROM dbo.tblPoForecastType f INNER JOIN dbo.tblPoForecastTypeDetail d 
			ON f.ForecastType = d.ForecastType) x ON t.ForecastId = x.ForecastType)
			LEFT JOIN 
			(SELECT f.ForecastType, COUNT(f.ForecastType) AS FC
			FROM dbo.tblPoForecastType f INNER JOIN dbo.tblPoForecastTypeDetail d 
			ON f.ForecastType = d.ForecastType GROUP BY f.ForecastType) v ON t.ForecastId = v.ForecastType
			LEFT JOIN dbo.trav_InHistoryByYearPeriodItemLocation_view h 
				ON t.ItemId = h.ItemId AND t.LocId = h.LocId AND h.SumPeriod = ISNULL(x.Period,h.SumPeriod)
		WHERE ((SumYear = @FiscalYear AND h.SumPeriod < @FiscalPeriod) OR (SumYear = @FiscalYear - 1 AND h.SumPeriod >= @FiscalPeriod ))
		GROUP BY t.ItemId, t.LocId 

		UPDATE #Forecast SET UsageForecast = 0 
		WHERE UsageForecast IS NULL OR UsageForecast < 0 

		UPDATE #Forecast SET UsageAnnual = 0 
		WHERE UsageAnnual IS NULL  

		UPDATE #Forecast SET OrderPoint = 0 
		WHERE OrderPoint IS NULL  

		UPDATE dbo.tblPoItemLocReorder SET NotesEoq = 'HM'
		FROM dbo.tblPoItemLocReorder INNER JOIN #Forecast t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId 
		WHERE HM < @PeriodsPerYear 

		UPDATE dbo.tblPoItemLocReorder SET NotesFrcst = 'FM' 
		FROM dbo.tblPoItemLocReorder INNER JOIN #Forecast t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId 
		WHERE FM < @PeriodsPerYear

		UPDATE #Forecast SET UsageForecast = CONVERT(int, UsageForecast + UsageForecast * (AdjustmentFactor / 100))
		WHERE AdjustmentFactor > 0 

		UPDATE dbo.tblPoItemLocReorder	SET UsageForecast = t.UsageForecast
		FROM dbo.tblPoItemLocReorder INNER JOIN #Forecast t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId 

		UPDATE #Forecast SET UsageForecast = UsageForecast - CASE @IncludeQuantityOnOrder WHEN 1 THEN r.QtyOnOrder ELSE 0 END - r.Qty + r.QtyCmtd 
		FROM #Forecast INNER JOIN #Reorder r ON #Forecast.ItemId = r.ItemId AND #Forecast.LocId = r.LocId 
		WHERE UsageForecast <> 0 

		UPDATE #Forecast SET UsageAnnual = ROUND(CONVERT(Decimal(28,10),UsageAnnual + UsageAnnual * (AdjustmentFactor / 100)),0)

		UPDATE #Forecast SET OrderPoint = CASE WHEN r.DfltLeadTime > 0 
			THEN CONVERT(int, r.DfltLeadTime / 30 * OrderPoint) ELSE 0 END 
		FROM #Forecast INNER JOIN #Reorder r ON #Forecast.ItemId = r.ItemId AND #Forecast.LocId = r.LocId 

		UPDATE #Forecast 
			SET OrderPoint = ROUND(CONVERT(Decimal(28,10),OrderPoint + OrderPoint * (AdjustmentFactor / 100)),0)
		WHERE AdjustmentFactor <> 0 AND OrderPoint <> 0 

		UPDATE #Forecast SET OrderPoint = 0 
		WHERE OrderPoint < 0 

		UPDATE #Forecast SET OrderPoint = OrderPoint * 1.5

		UPDATE dbo.tblPoItemLocReorder 
			SET OrderPointEoq = t.OrderPoint, OrderPointFrcst = t.OrderPoint , OrderPointMinMax = t.OrderPoint 
		FROM dbo.tblPoItemLocReorder INNER JOIN #Forecast t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId
		WHERE dbo.tblPoItemLocReorder.FrozenEoq <> 1 

		UPDATE dbo.tblPoItemLocReorder 
			SET OrderQtyMinMax = CASE WHEN (CASE @IncludeQuantityOnOrder WHEN 1 THEN t.QtyOnOrder ELSE 0 END + dbo.tblPoItemLocReorder.QtyOnHand ) <= dbo.tblPoItemLocReorder.OrderPointMinMax 
				THEN (CASE WHEN (t.QtyOnHandMax - (CASE @IncludeQuantityOnOrder WHEN 1 THEN t.QtyOnOrder ELSE 0 END + dbo.tblPoItemLocReorder.QtyOnHand )) > t.QtyOrderMin THEN 
				(t.QtyOnHandMax - (CASE @IncludeQuantityOnOrder WHEN 1 THEN t.QtyOnOrder ELSE 0 END + dbo.tblPoItemLocReorder.QtyOnHand )) ELSE t.QtyOrderMin END ) ELSE 0 END
		FROM dbo.tblPoItemLocReorder INNER JOIN #Reorder t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId 

		UPDATE dbo.tblPoItemLocReorder SET OrderQtyMinMax = 0
		WHERE OrderQtyMinMax < 0

		UPDATE dbo.tblPoItemLocReorder 
			SET SafetyStock = t.QtySafetyStock, FrozenFrcst = 1 
		FROM dbo.tblPoItemLocReorder INNER JOIN #Reorder t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId 
		WHERE t.SafetyStockType = 2 

		UPDATE dbo.tblPoItemLocReorder 
			SET SafetyStock = ROUND(CONVERT(Decimal(28,10),dbo.tblPoItemLocReorder.OrderPointEoq / 3), 0)  
		FROM dbo.tblPoItemLocReorder INNER JOIN #Reorder t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId 
		WHERE t.SafetyStockType <> 2 

		UPDATE dbo.tblInItemLoc 
			SET SafetyStockType = 1 
		FROM dbo.tblInItemLoc INNER JOIN #Reorder t 
			ON dbo.tblInItemLoc.ItemId = t.ItemId AND dbo.tblInItemLoc.LocId = t.LocId 
		WHERE t.SafetyStockType <> 2 

		UPDATE dbo.tblPoItemLocReorder 
			SET OrderQtyFrcst = CASE WHEN t.UsageForecast + dbo.tblPoItemLocReorder.SafetyStock <= 0 THEN 0 ELSE t.UsageForecast + dbo.tblPoItemLocReorder.SafetyStock END, 
				UsageAnnual = ISNULL(t.UsageAnnual,0)
		FROM dbo.tblPoItemLocReorder INNER JOIN #Forecast t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId  

		UPDATE dbo.tblPoItemLocReorder 
			SET OrderQtyEoq = CASE WHEN (CASE @IncludeQuantityOnOrder WHEN 1 THEN t.QtyOnOrder ELSE 0 END + QtyOnHand ) > t.QtyOrderPoint THEN 0 ELSE t.Eoq END, NotesEoq = 'FQ' 
		FROM dbo.tblPoItemLocReorder INNER JOIN #Reorder t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId  
		WHERE t.EoqType = 2 

		UPDATE dbo.tblPoItemLocReorder 
			SET OrderQtyEoq = 0 
		FROM dbo.tblPoItemLocReorder INNER JOIN #Reorder t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId  
		WHERE t.EoqType <> 2 AND dbo.tblPoItemLocReorder.UsageAnnual < 1 

		UPDATE dbo.tblPoItemLocReorder 
		SET OrderQtyEoq = dbo.tblPoItemLocReorder.UsageAnnual 
		FROM dbo.tblPoItemLocReorder INNER JOIN #Reorder t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId  
		WHERE t.EoqType <> 2 AND dbo.tblPoItemLocReorder.UsageAnnual >= 1 
			AND (t.LocCarrCostPct + t.ItemLocCarrCostPct = 0 OR CostLast = 0)

		UPDATE dbo.tblPoItemLocReorder 
		SET OrderQtyEoq = 1 
		FROM dbo.tblPoItemLocReorder INNER JOIN #Reorder t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId  
		WHERE t.EoqType <> 2 AND dbo.tblPoItemLocReorder.UsageAnnual >= 1 
			AND t.LocCarrCostPct + t.ItemLocCarrCostPct <> 0 AND CostLast <> 0
			AND ItemLocOrderCostAmt = 0 AND LocOrderCostAmt = 0 

		UPDATE dbo.tblPoItemLocReorder 
			SET OrderQtyEoq = 0  
		FROM dbo.tblPoItemLocReorder INNER JOIN #Reorder t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId  
		WHERE t.EoqType <> 2 AND dbo.tblPoItemLocReorder.UsageAnnual >= 1 
			AND t.LocCarrCostPct + t.ItemLocCarrCostPct <> 0 AND CostLast <> 0
			AND (ItemLocOrderCostAmt <> 0 OR LocOrderCostAmt <> 0) 
			AND CostLast * (t.LocCarrCostPct + t.ItemLocCarrCostPct) <= 0 

		UPDATE dbo.tblPoItemLocReorder SET OrderQtyEoq = ROUND(CONVERT(Decimal(28,10),SQRT(2 * dbo.tblPoItemLocReorder.UsageAnnual * 
			(CASE WHEN ItemLocOrderCostAmt = 0 THEN LocOrderCostAmt ELSE ItemLocOrderCostAmt END) 
			/(CostLast * (t.LocCarrCostPct + t.ItemLocCarrCostPct)/100))), 0)
		FROM dbo.tblPoItemLocReorder INNER JOIN #Reorder t 
			ON dbo.tblPoItemLocReorder.ItemId = t.ItemId AND dbo.tblPoItemLocReorder.LocId = t.LocId  
		WHERE t.EoqType <> 2 AND dbo.tblPoItemLocReorder.UsageAnnual >= 1 
			AND t.LocCarrCostPct + t.ItemLocCarrCostPct <> 0 AND CostLast <> 0
			AND (ItemLocOrderCostAmt <> 0 OR LocOrderCostAmt <> 0) 
			AND CostLast * (t.LocCarrCostPct + t.ItemLocCarrCostPct) > 0 

		/* Determine flags to print item on report
		   AboveEoqOrdPt, AboveFrcstOrdPt, AboveMinMaxOrdPt, AboveAllOrdPt */
		UPDATE dbo.tblPoItemLocReorder 
			SET AboveEoqOrdPt = CASE WHEN OrderQtyEoq + SafetyStock - (CASE @IncludeQuantityOnOrder WHEN 1 THEN QtyOnOrder ELSE 0 END + QtyOnHand ) <= 0 THEN 0 ELSE 1 END,
				AboveFrcstOrdPt = CASE WHEN OrderQtyFrcst <= 0 THEN 0 ELSE 1 END, 
				AboveMinMaxOrdPt = CASE WHEN OrderQtyMinMax <= 0 THEN 0 ELSE 1 END, 
				AboveAllOrdPt = CASE WHEN (CASE WHEN (CASE WHEN OrderQtyFrcst > OrderQtyMinMax THEN OrderQtyFrcst ELSE OrderQtyMinMax END) <= 0 
					THEN OrderQtyEoq + SafetyStock - (CASE @IncludeQuantityOnOrder WHEN 1 THEN QtyOnOrder ELSE 0 END + QtyOnHand ) ELSE (CASE WHEN OrderQtyFrcst > OrderQtyMinMax THEN OrderQtyFrcst ELSE OrderQtyMinMax END) END)
					<= 0 THEN 0 ELSE 1 END

		/* Update Minimim Quantities for Generating Requisitions */
		/* Update Maximum Quantities for Generating Requisitions */
		UPDATE dbo.tblPoItemLocReorder
			SET MinOrderQty = OrderQtyMinMax, MaxOrderQty = OrderQtyMinMax 
		WHERE OrderPointEoq < (CASE @IncludeQuantityOnOrder WHEN 1 THEN QtyOnOrder ELSE 0 END + QtyOnHand ) - SafetyStock 

		UPDATE dbo.tblPoItemLocReorder 
			SET MinOrderQty = CASE WHEN OrderQtyEoq < OrderQtyFrcst THEN OrderQtyEoq
					ELSE OrderQtyFrcst END, 
				MaxOrderQty = CASE WHEN OrderQtyEoq > OrderQtyFrcst THEN OrderQtyEoq 
					ELSE OrderQtyFrcst END 
		WHERE OrderPointEoq >= (CASE @IncludeQuantityOnOrder WHEN 1 THEN QtyOnOrder ELSE 0 END + QtyOnHand ) - SafetyStock 

		UPDATE dbo.tblPoItemLocReorder 
			SET MinOrderQty = OrderQtyMinMax 
		WHERE OrderPointEoq >= (CASE @IncludeQuantityOnOrder WHEN 1 THEN QtyOnOrder ELSE 0 END + QtyOnHand ) - SafetyStock 
			AND OrderQtyMinMax > 0 AND MinOrderQty > OrderQtyMinMax

		UPDATE dbo.tblPoItemLocReorder 
			SET MaxOrderQty = OrderQtyMinMax 
		WHERE OrderPointEoq >= (CASE @IncludeQuantityOnOrder WHEN 1 THEN QtyOnOrder ELSE 0 END + QtyOnHand ) - SafetyStock 
			AND OrderQtyMinMax > 0 AND MinOrderQty < OrderQtyMinMax

		UPDATE dbo.tblPoItemLocReorder SET OrderQtyMinMax = ROUND(OrderQtyMinMax / u.ConvFactor, @PrecQty),
			QtyOnHand = ROUND(QtyOnHand / u.ConvFactor, @PrecQty), QtyOnOrder = ROUND(QtyOnOrder / u.ConvFactor, @PrecQty),
			SafetyStock = ROUND(SafetyStock / u.ConvFactor, @PrecQty), UsageForecast = ROUND(UsageForecast / u.ConvFactor, @PrecQty),
			UsageAnnual = ROUND(UsageAnnual / u.ConvFactor, @PrecQty), OrderPointEoq = ROUND(OrderPointEoq / u.ConvFactor, @PrecQty),
			OrderPointFrcst = ROUND(OrderPointFrcst / u.ConvFactor, @PrecQty), OrderPointMinMax = ROUND(OrderPointMinMax / u.ConvFactor, @PrecQty),
			OrderQtyEoq = ROUND(OrderQtyEoq / u.ConvFactor, @PrecQty), OrderQtyFrcst = ROUND(OrderQtyFrcst / u.ConvFactor, @PrecQty),
			MinOrderQty = ROUND(MinOrderQty / u.ConvFactor, @PrecQty), MaxOrderQty = ROUND(MaxOrderQty / u.ConvFactor, @PrecQty)
		FROM dbo.tblPoItemLocReorder INNER JOIN dbo.tblInItemUom u 
			ON dbo.tblPoItemLocReorder.ItemId = u.ItemId AND dbo.tblPoItemLocReorder.UomDflt = u.Uom

		/*Include PO Requisitions and PO Request (Transaction Type = 0) */
		UPDATE dbo.tblPoItemLocReorder SET
			OrderQtyEoq = CASE WHEN (OrderQtyEoq > ROUND(temp.Qty / um.ConvFactor, @PrecQty))
				THEN (OrderQtyEoq - ROUND(temp.Qty / um.ConvFactor, @PrecQty)) ELSE 0 END,

			OrderQtyFrcst =CASE @IncludeQuantityOnOrder WHEN 1 THEN (CASE WHEN (OrderQtyFrcst > ROUND(temp.Qty / um.ConvFactor, @PrecQty))
				THEN (OrderQtyFrcst - ROUND(temp.Qty / um.ConvFactor, @PrecQty)) ELSE 0 END) ELSE OrderQtyFrcst END,

			OrderQtyMinMax = CASE WHEN (OrderQtyMinMax > ROUND(temp.Qty / um.ConvFactor, @PrecQty))
				THEN (OrderQtyMinMax - ROUND(temp.Qty / um.ConvFactor, @PrecQty)) ELSE 0 END
		FROM dbo.tblPoItemLocReorder re
		INNER JOIN (
			    SELECT ItemId,LocId,SUM(Qty) Qty FROM(
				SELECT rq.ItemId, rq.LocId, SUM(ROUND(rq.Qty * u.ConvFactor, @PrecQty)) AS Qty
				FROM dbo.tblPoPurchaseReq rq
				INNER JOIN dbo.tblInItem i ON rq.ItemId = i.ItemId
				INNER JOIN dbo.tblInItemUom u ON rq.ItemId = u.ItemId AND rq.Uom = u.Uom
				WHERE rq.Seq = 0
				GROUP BY rq.ItemId, rq.LocId
				UNION ALL
				SELECT d.ItemId, d.LocId, SUM(ROUND(d.QtyOrd * u.ConvFactor, @PrecQty)) AS Qty
				FROM dbo.tblPoTransHeader h
				INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransID
				INNER JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
				INNER JOIN dbo.tblInItemUom u ON d.ItemId = u.ItemId AND d.Units = u.Uom
				WHERE h.TransType = 0
				GROUP BY d.ItemId, d.LocId ) Req GROUP BY ItemId,LocId
		) temp
		ON re.ItemId = temp.ItemId AND re.LocId = temp.LocId
		INNER JOIN dbo.tblInItemUom um ON re.ItemId = um.ItemId AND re.UomDflt = um.Uom

		UPDATE dbo.tblInItemLoc SET SafetyStockType = 1, QtySafetyStock = r.SafetyStock 
		FROM dbo.tblInItemLoc INNER JOIN dbo.tblPoItemLocReorder r 
			ON dbo.tblInItemLoc.ItemId = r.ItemId AND dbo.tblInItemLoc.LocId = r.LocId 
		WHERE SafetyStockType <> 2 

		UPDATE dbo.tblInItemLoc SET OrderPointType = 1, QtyOrderPoint = r.OrderPointEoq 
		FROM dbo.tblInItemLoc INNER JOIN dbo.tblPoItemLocReorder r 
			ON dbo.tblInItemLoc.ItemId = r.ItemId AND dbo.tblInItemLoc.LocId = r.LocId 
		WHERE OrderPointType <> 2 

		UPDATE dbo.tblInItemLoc SET EoqType = 1, Eoq = r.OrderQtyEoq 
		FROM dbo.tblInItemLoc INNER JOIN dbo.tblPoItemLocReorder r 
			ON dbo.tblInItemLoc.ItemId = r.ItemId AND dbo.tblInItemLoc.LocId = r.LocId 
		WHERE dbo.tblInItemLoc.EoqType <> 2 
	END 

	SELECT * FROM #Reorder
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoCalculateReorders_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoCalculateReorders_proc';

