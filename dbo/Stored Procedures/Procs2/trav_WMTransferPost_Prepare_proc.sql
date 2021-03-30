
CREATE PROCEDURE [dbo].[trav_WMTransferPost_Prepare_proc]
AS
BEGIN TRY  
 DECLARE @PrecCurr tinyint,@ApplyXferCostAdj tinyint,@PrecUnitCost tinyint
 
 SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'   
 SELECT @ApplyXferCostAdj = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'ApplyXferCostAdj' 
 SELECT @PrecUnitCost = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecUnitCost'   
  
 IF @PrecCurr IS NULL OR @ApplyXferCostAdj IS NULL OR @PrecUnitCost IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END 

--Temp table #PostTransList(Created from BL)- Contains postable Tranfer
--CREATE TABLE #PostTransList( TransId nvarchar(10) NOT NULL PRIMARY KEY CLUSTERED ([TransId]))

--Temp table #WMTranferPost(Created from BL)- Used to load pick and receipt
--create table #WMTranferPost(
--		TranKey int,
--		TranPickKey int,
--		TransType tinyint,/*0=Pick/1=Receipt*/
--		TransDate datetime,
--		ItemId pItemId,
--		LocId pLocId,
--		ExtCost pDecimal,
--		GlPeriod smallint,
--		FiscalYear smallint,
--		AdjLocId pLocId,
--     Status tinyint,
--     QtyBase pDecimal)
	
--Load Pick  	
Insert into #WMTranferPost (TranKey, TranPickKey, TransType, TransDate
	, ItemId, LocId,ExtCost, GlPeriod, FiscalYear, AdjLocId,[Status],QtyBase)
	Select t.TranKey, p.TranPickKey, 0, p.EntryDate
	, p.ItemId, p.LocId
	, isnull(Round(p.Qty * p.UnitCost, @PrecCurr), 0)
	, p.GlPeriod, p.GlYear
	, Case When @ApplyXferCostAdj = 0 Then t.LocId Else t.LocIdTo End -- Use Bus rule  Apply Transfer Cost/Adjustment
	,p.[Status],
	0 -- Pick Qty not used
	From #PostTransList s
	Inner Join dbo.tblWmTransfer t on s.TransId = t.TranKey
	Inner Join dbo.tblWmTransferPick p on t.TranKey = p.TranKey

	
--Load Receipt 
Insert into #WMTranferPost (TranKey, TranPickKey, TransType, TransDate
	, ItemId, LocId,ExtCost, GlPeriod, FiscalYear, AdjLocId,[Status],QtyBase)
	Select t.TranKey, p.TranPickKey, 1, r.EntryDate
	, r.ItemId, r.LocId
	, isnull(Round(r.Qty * r.UnitCost, @PrecCurr), 0)
	, r.GlPeriod, r.GlYear
	, Case When @ApplyXferCostAdj = 0 Then t.LocId Else t.LocIdTo End -- Use Bus rule  Apply Transfer Cost/Adjustment
	,r.[Status]
	, isnull(Round(r.Qty * u.ConvFactor, @PrecUnitCost), 0) -- Receipt Qty in base units
	From #PostTransList s
	Inner Join dbo.tblWmTransfer t on s.TransId = t.TranKey
	Inner Join dbo.tblWmTransferPick p on t.TranKey = p.TranKey
	Inner Join dbo.tblWmTransferRcpt r on p.TranPickKey = r.TranPickKey
	Inner Join dbo.tblInItemUom u On r.ItemId = u.ItemId and r.UOM = u.Uom
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMTransferPost_Prepare_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMTransferPost_Prepare_proc';

