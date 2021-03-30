
CREATE PROCEDURE dbo.trav_SoReturnedItemPost_History_proc

AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @PostRun pPostRun, @WrkStnDate datetime, @FiscalYear smallint, @FiscalPeriod smallint

	--retrieve global values
	SELECT @PostRun = CAST([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WrkStnDate = CAST([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @FiscalYear = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'

	IF (@PostRun IS NULL OR @WrkStnDate IS NULL OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL)
	BEGIN
		RAISERROR(90025,16,1)
	END

	INSERT INTO dbo.tblSoHistReturnedItem (PostRun, PostDate, GlPeriod, FiscalYear
		, [Status], ResCode, ResCodeDescr, RMANumber, CustId, r.TransId, EntryNum, ItemId, ItemDescr
		, LocId, ExtLocA, ExtLocAId, ExtLocB, ExtLocBId, EntryDate, TransDate, Units, QtyReturn
		, LotNum, SerNum, UnitCost, CostExt, UnitPrice, PriceExt, GLAcctCOGS, GLAcctInv, Notes, CF, ReturnID) 
	SELECT @PostRun AS PostRun, @WrkStnDate AS PostDate, @FiscalPeriod AS GlPeriod, @FiscalYear AS FiscalYear
		, [Status], r.ResCode, c.Descr AS ResCodeDescr, RMANumber, CustId, r.TransId, EntryNum, r.ItemId, i.Descr AS ItemDescr
		, r.LocId, ExtLocA, a.ExtLocID AS ExtLocAId, ExtLocB, b.ExtLocID AS ExtLocBId, EntryDate, TransDate, Units, QtyReturn
		, LotNum, SerNum, UnitCost, CostExt, UnitPrice, PriceExt, GLAcctCOGS, GLAcctInv, Notes, r.CF, [Counter] 
	FROM #PostTransList l 
		INNER JOIN dbo.tblSoReturnedItem r ON l.TransId = r.[Counter]
		LEFT JOIN dbo.tblInItem i ON r.ItemId = i.ItemId 
		LEFT JOIN dbo.tblSoReasonCode c ON r.ResCode = c.ResCode 
		LEFT JOIN dbo.tblWmExtLoc a ON r.ExtLocA = a.Id 
		LEFT JOIN dbo.tblWmExtLoc b ON r.ExtLocB = b.Id 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemPost_History_proc';

