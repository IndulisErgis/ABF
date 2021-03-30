
CREATE PROCEDURE dbo.trav_SvGeneralEquipmentList_proc
@IncludeServiceDetail bit = 1, 
@IncludeWarrantyDetail bit = 1, 
@IncludePartsList bit = 1, 
@IncludeKnowledgebaseDetail bit = 1

AS
BEGIN TRY
	SET NOCOUNT ON

--DROP TABLE #tmpGeneralEquipmentList
--CREATE TABLE #tmpGeneralEquipmentList(ID bigint NOT NULL PRIMARY KEY CLUSTERED (ID))
--INSERT INTO #tmpGeneralEquipmentList (ID) SELECT ID FROM dbo.tblSvEquipment WHERE [Status] <> 2 AND SiteYN = 0 --{0}

	-- General Equipment resultset
	SELECT tmp.ID, EquipmentNo, [Description], Manufacturer, Model, ItemID, CategoryID, [Status], Usage
		, ServiceContractCharge, AdditionalDescription 
	FROM #tmpGeneralEquipmentList tmp 
		INNER JOIN dbo.tblSvEquipment e ON e.ID = tmp.ID

	-- Service resultset
	SELECT tmp.ID, EquipmentID, WorkToDoID, ScheduleType, ScheduleInterval, ScheduleAutoPrompt 
	FROM #tmpGeneralEquipmentList tmp 
		INNER JOIN dbo.tblSvEquipmentService s ON s.EquipmentID = tmp.ID 
	WHERE @IncludeServiceDetail = 1

	-- Warranty resultset
	SELECT tmp.ID, EquipmentID, CoverageType, IntervalType, Interval, StartDate, EndDate 
	FROM #tmpGeneralEquipmentList tmp 
		INNER JOIN dbo.tblSvEquipmentWarranty w ON w.EquipmentID = tmp.ID 
	WHERE @IncludeWarrantyDetail = 1

	-- Parts resultset
	SELECT tmp.ID, EquipmentID, PartNo, ItemID, [Description], PreferredVendor, Qty, EstimatedCost, LeadTime 
	FROM #tmpGeneralEquipmentList tmp 
		INNER JOIN dbo.tblSvEquipmentParts p ON p.EquipmentID = tmp.ID 
	WHERE @IncludePartsList = 1

	-- Knowledgebase resultset
	SELECT tmp.ID, EquipmentID, [Description], AdditionalDescription, Resolution, WorkOrderNo, EntryDate, EnteredBy 
	FROM #tmpGeneralEquipmentList tmp 
		INNER JOIN dbo.tblSvEquipmentKnowledgebase k ON k.EquipmentID = tmp.ID 
	WHERE @IncludeKnowledgebaseDetail = 1

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvGeneralEquipmentList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvGeneralEquipmentList_proc';

