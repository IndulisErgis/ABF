
CREATE PROCEDURE [dbo].[trav_InItemCostChange_proc] 
AS
BEGIN TRY

	DECLARE @AdjBase tinyint, @AdjType tinyint, @AdjAmt pDecimal

	--Retrieve global values
	SELECT @AdjBase = CAST([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'AdjBase'
	SELECT @AdjType = CAST([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'AdjType'
	SELECT @AdjAmt = CAST([Value] AS decimal(28,10)) FROM #GlobalValues WHERE [Key] = 'AdjAmt'

	--Clear log table
	DELETE FROM #ItemCostChangeLog
	INSERT INTO #ItemCostChangeLog (ItemId, LocId, Uom, ItemIDDescr, ProductLine,
	AdjBase, AdjType, CostStd, CostBase, NewPrice)
	SELECT t.ItemId, t.LocId, i.UomDflt, i.Descr, i.ProductLine, @AdjBase, @AdjType, l.CostStd, l.CostBase, 0
	FROM #ItemLocationList t
	INNER JOIN dbo.tblInItem i ON t.ItemId = i.ItemId
	INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId

	IF @AdjType = 0
		UPDATE #ItemCostChangeLog SET NewPrice = CASE @AdjBase WHEN 1 THEN CostStd ELSE CostBase END + @AdjAmt
	ELSE
		UPDATE #ItemCostChangeLog SET NewPrice = CASE @AdjBase WHEN 1 THEN CostStd ELSE CostBase END * (1+@AdjAmt*.01)

	--Update the Cost Information
	IF @AdjBase = 1
		UPDATE dbo.tblInItemLoc SET CostStd = NewPrice
		FROM dbo.tblInItemLoc l INNER JOIN #ItemCostChangeLog t
		ON t.LocId = l.LocId AND t.ItemId = l.ItemId
	ELSE
		UPDATE dbo.tblInItemLoc SET CostBase = NewPrice
		FROM dbo.tblInItemLoc l INNER JOIN #ItemCostChangeLog t
		ON t.LocId = l.LocId AND t.ItemId = l.ItemId
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemCostChange_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemCostChange_proc';

