
CREATE PROCEDURE dbo.trav_SvSiteEquipmentList_proc
@IncludeServiceDetail bit = 1, 
@IncludeWarrantyDetail bit = 1, 
@IncludeActivityDetail bit = 1, 
@IncludePartsList bit = 1, 
@IncludeKnowledgebaseDetail bit = 1

AS
BEGIN TRY
	SET NOCOUNT ON

-- creating temp table for testing (will remove once testing is completed)
--DROP TABLE #tmpSiteEquipmentList
--CREATE TABLE #tmpSiteEquipmentList(ID bigint NOT NULL PRIMARY KEY CLUSTERED (ID))
--INSERT INTO #tmpSiteEquipmentList (ID) SELECT ID FROM dbo.tblSvEquipment WHERE [Status] <> 2 AND SiteYN = 1 --{0}

	-- Site Equipment resultset
	SELECT tmp.ID, EquipmentNo, [Description], SerialNumber, TagNumber, CustID, SiteID
		, Manufacturer, Model, ItemID, CategoryID, [Status], Usage, [Ownership], GLAcctExpense, AssetID
		, AdditionalDescription 
	FROM #tmpSiteEquipmentList tmp 
		INNER JOIN dbo.tblSvEquipment e ON e.ID = tmp.ID

	-- Service resultset
	SELECT tmp.ID, EquipmentID, WorkToDoID, ScheduleType, ScheduleInterval
		, ScheduleAutoPrompt, ScheduleStartDate, ScheduleEndDate, ScheduleNextDate 
	FROM #tmpSiteEquipmentList tmp 
		INNER JOIN dbo.tblSvEquipmentService s ON s.EquipmentID = tmp.ID 
	WHERE @IncludeServiceDetail = 1

	-- Warranty resultset
	SELECT tmp.ID, EquipmentID, CoverageType, IntervalType, Interval, StartDate, EndDate 
	FROM #tmpSiteEquipmentList tmp 
		INNER JOIN dbo.tblSvEquipmentWarranty w ON w.EquipmentID = tmp.ID 
	WHERE @IncludeWarrantyDetail = 1

	-- Activity resultset
		SELECT tmp.ID, EquipmentID, [Type], [Description], SiteID, ContactID, ContactName, Address1, Address2
			, City, Region, Country, PostalCode, ShipDate, OrderNumber, Price, Phone, Fax, OrderDate, InvoiceDate
			, InvoiceNumber 
		FROM #tmpSiteEquipmentList tmp 
			INNER JOIN dbo.tblSvEquipmentActivity a ON a.EquipmentID = tmp.ID 
		WHERE @IncludeActivityDetail = 1

	-- Parts resultset
	SELECT e.ID, EquipmentID, PartNo, p.ItemID, p.[Description], PreferredVendor, Qty, EstimatedCost, LeadTime 
	FROM dbo.tblSvEquipment e 
		INNER JOIN dbo.tblSvEquipmentParts p ON p.EquipmentID = e.GeneralEquipmentID 
	WHERE @IncludePartsList = 1 AND e.ID IN (SELECT * FROM #tmpSiteEquipmentList)

	-- Knowledgebase resultset
	SELECT e.ID, EquipmentID, k.[Description], k.AdditionalDescription, Resolution, WorkOrderNo, EntryDate, EnteredBy 
	FROM dbo.tblSvEquipment e 
		INNER JOIN dbo.tblSvEquipmentKnowledgebase k ON k.EquipmentID = e.GeneralEquipmentID 
	WHERE @IncludeKnowledgebaseDetail = 1 AND e.ID IN (SELECT * FROM #tmpSiteEquipmentList)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvSiteEquipmentList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvSiteEquipmentList_proc';

