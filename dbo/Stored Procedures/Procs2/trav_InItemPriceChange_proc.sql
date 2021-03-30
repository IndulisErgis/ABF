
CREATE PROCEDURE [dbo].[trav_InItemPriceChange_proc] 
AS
BEGIN TRY
	DECLARE @AdjBase tinyint, @AdjType tinyint, @AdjAmt pDecimal
	--Retrieve global values
	SELECT @AdjBase = CAST([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'AdjBase'  --Base = 1, List = 2, Min = 3
	SELECT @AdjType = CAST([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'AdjType'  --Amount = 0, Percent = 1
	SELECT @AdjAmt = CAST([Value] AS decimal(28,10)) FROM #GlobalValues WHERE [Key] = 'AdjAmt'

	--Clear log table
	DELETE FROM #ItemPriceChangeLog
	INSERT INTO #ItemPriceChangeLog (ItemId, LocId, Uom, ItemIDDescr, ProductLine, AdjBase, AdjType,
	PriceBase, PriceList, PriceMin, NewPrice)
	SELECT t.ItemId, t.LocId, l.Uom, i.Descr, i.ProductLine,@AdjBase, @AdjType,
	l.PriceBase, l.PriceList, l.PriceMin, 0
	FROM #ItemLocationList t
	INNER JOIN dbo.tblInItem i ON t.ItemId = i.ItemId
	INNER JOIN dbo.tblInItemLocUomPrice l ON t.ItemId = l.ItemId AND t.LocId = l.LocId

	IF @AdjType = 0
		UPDATE #ItemPriceChangeLog SET NewPrice = CASE @AdjBase WHEN 1 THEN PriceBase WHEN 2 THEN PriceList ELSE PriceMin END + (@AdjAmt * ConvFactor) From tblInItemUom t, #ItemPriceChangeLog l WHERE t.ItemId = l.ItemId AND t.Uom = l.Uom
	ELSE
		UPDATE #ItemPriceChangeLog SET NewPrice = CASE @AdjBase WHEN 1 THEN PriceBase WHEN 2 THEN PriceList ELSE PriceMin END * (1+@AdjAmt*.01)

	--Update the price Information
	IF @AdjBase = 1
		UPDATE dbo.tblInItemLocUomPrice SET PriceBase = NewPrice
		FROM dbo.tblInItemLocUomPrice l INNER JOIN #ItemPriceChangeLog t
		ON t.LocId = l.LocId AND t.ItemId = l.ItemId AND l.Uom = t.Uom
	ELSE IF @AdjBase = 2
		UPDATE dbo.tblInItemLocUomPrice SET PriceList = NewPrice
		FROM dbo.tblInItemLocUomPrice l INNER JOIN #ItemPriceChangeLog t
		ON t.LocId = l.LocId AND t.ItemId = l.ItemId AND l.Uom = t.Uom
	ELSE
		UPDATE dbo.tblInItemLocUomPrice SET PriceMin = NewPrice
		FROM dbo.tblInItemLocUomPrice l INNER JOIN #ItemPriceChangeLog t
		ON t.LocId = l.LocId AND t.ItemId = l.ItemId AND l.Uom = t.Uom

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemPriceChange_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemPriceChange_proc';

