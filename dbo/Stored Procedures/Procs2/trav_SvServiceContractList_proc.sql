
CREATE PROCEDURE dbo.trav_SvServiceContractList_proc
@IncludeEquipmentDetail bit = 1

AS
BEGIN TRY
	SET NOCOUNT ON
-- creating temp table for testing (will remove once testing is completed)
--DROP TABLE #tmpServiceContractList
--CREATE TABLE #tmpServiceContractList(ID bigint NOT NULL PRIMARY KEY CLUSTERED (ID))
--INSERT INTO #tmpServiceContractList (ID) 
--SELECT ID FROM 
--(
-- SELECT h.ID, h.ContractNo, h.CustID, h.[Description], h.StartDate, h.EndDate, h.OriginalContractDate
--  , h.Notes, h.RecurID, h.BillingType, h.NextBillingDate, h.BillingAmount, h.BillingInterval
--  , h.LastBillingDate, c.CustName 
-- FROM dbo.tblSvServiceContractHeader h 
--  LEFT JOIN dbo.tblArCust c ON h.CustID = c.CustId 
--) tmp --{0}

	-- Service Contract resultset
	SELECT tmp.ID, ContractNo, h.CustID, [Description], StartDate, EndDate, OriginalContractDate, Notes
		, h.RecurID, h.BillingType, h.NextBillingDate, h.BillingAmount, h.BillingInterval, h.LastBillingDate
		, d.TotalContractAmount 	
	FROM #tmpServiceContractList tmp 
		INNER JOIN dbo.tblSvServiceContractHeader h ON h.ID = tmp.ID
		LEFT JOIN 
			( 
				SELECT ContractID, SUM(ContractAmount) AS TotalContractAmount 
				FROM dbo.tblSvServiceContractDetail GROUP BY ContractID
			) d ON d.ContractID = tmp.ID		

	-- Equipment resultset
	SELECT tmp.ID, ContractID, EquipmentNo, CoverageType, ContractAmount
		, SiteID, ItemID, SerialNumber, TagNumber 
	FROM #tmpServiceContractList tmp 
		INNER JOIN dbo.tblSvServiceContractDetail d ON d.ContractID = tmp.ID 
		LEFT JOIN dbo.tblSvEquipment e ON e.ID = d.EquipmentID 
	WHERE @IncludeEquipmentDetail = 1

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceContractList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceContractList_proc';

