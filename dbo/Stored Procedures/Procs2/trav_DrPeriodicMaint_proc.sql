
CREATE PROCEDURE [dbo].[trav_DrPeriodicMaint_proc]
	@DelDRRuns datetime = NULL,
	@DelSalesFrcst datetime = NULL,
	@DelMstrSched datetime = NULL,
	@DelClosedSaleBlanket datetime = NULL,
	@PrecQty tinyint = 4
AS
BEGIN TRY
	SET NOCOUNT ON
	
	-- Purge old run code info
	IF (@DelDRRuns IS NOT NULL)
	BEGIN
		Delete dbo.tblDRRunInfo Where RunDate < @DelDRRuns
		
		Delete dbo.tblDRRunData
		Where not exists(Select 1 From dbo.tblDRRunInfo i
			Where i.RunId = dbo.tblDRRunData.RunId
			Group By i.RunId)
			
		Delete dbo.tblDRRunItemLoc
		Where not exists(Select 1 From dbo.tblDRRunInfo i
			Where i.RunId = dbo.tblDRRunItemLoc.RunId
			Group By i.RunId)
	END
   
   -- Purge Sales forecasts
   IF (@DelSalesFrcst IS NOT NULL)
	BEGIN
		--purge the detail records
		Delete dbo.tblDrFrcstDtl Where FrcstDate < @DelSalesFrcst
		
		--purge any headers that no longer have detail records
		Delete dbo.tblDrFrcst 
		Where not exists(Select 1 From dbo.tblDrFrcstDtl d 
			Where d.FrcstId = dbo.tblDRFrcst.Id 
			Group By d.FrcstId)
	END
	
	-- Purge Master schedule
	IF (@DelMstrSched IS NOT NULL)
	BEGIN
		--purge the detail records
		Delete dbo.tblDrMstrSchedDtl Where ProdDate < @DelMstrSched
		
		--purge any headers that no longer have detail records
		Delete dbo.tblDrMstrSched
			Where not exists(Select 1 From dbo.tblDrMstrSchedDtl d 
				Where d.MstrSchedId = dbo.tblDRMstrSched.Id
				Group By d.MstrSchedId)		
				
		--regenerate details for any remaining master schedules
		--exec dbo.qryMfPdDefUpdMstrSched Null, Null, Null, Null, 0, 1, @PrecQty
	END
	
	-- Purge Closed Sales Blankets
	IF(@DelClosedSaleBlanket IS NOT NULL)
	BEGIN
		-- Purge the header records
		Delete dbo.tblSoSaleBlanket Where CloseDate < @DelClosedSaleBlanket
		
		-- Purge activity records
		Delete dbo.tblSoSaleBlanketActivity
			Where not exists(Select 1 From dbo.tblSoSaleBlanket h
				Where h.BlanketRef = dbo.tblSoSaleBlanketActivity.BlanketRef
				Group by h.BlanketRef)
		
		-- Purge the detail records
		Delete dbo.tblSoSaleBlanketDetail
			Where not exists(Select 1 From dbo.tblSoSaleBlanket h
				Where h.BlanketRef = dbo.tblSoSaleBlanketDetail.BlanketRef
				Group by h.BlanketRef)
		
		-- Purge the detail scheduled records
		Delete dbo.tblSoSaleBlanketDetailSch
			Where not exists (Select 1 From dbo.tblSoSaleBlanketDetail d
				Where d.BlanketDtlRef = dbo.tblSoSaleBlanketDetailSch.BlanketDtlRef
				Group by d.BlanketDtlRef)
	END
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrPeriodicMaint_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrPeriodicMaint_proc';

