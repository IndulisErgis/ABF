
CREATE PROCEDURE [dbo].[trav_MpSubcontractStatus_proc] 
@SortBy tinyint = 0,
@NotStarted bit = 0,
@InProcess bit = 1,
@Completed bit = 0
AS
BEGIN TRY
SET NOCOUNT ON

SELECT CASE @SortBy WHEN 0 THEN s.DefaultVendorId WHEN 1 THEN o.OrderNo END AS SortBy,
	s.TransId, o.OrderNo, o.ReleaseNo, r.ReqID, s.DefaultVendorID, s.OperationID, s.EstQtyRequired AS QtyPlanned
	, s.[Description], d.ActualQtySent AS QtySent, d.ActualReceived AS QtyReceived, d.ActualScrapped AS QtyScrapped, v.[Name],
	CASE WHEN d.ActualQtySent = 0 THEN 0 WHEN (d.ActualQtySent > 0) AND (d.ActualReceived < EstQtyRequired) THEN 1 
		WHEN (d.ActualQtySent > 0) AND (d.ActualReceived >= EstQtyRequired) THEN 2 END AS RecType 
FROM #tmpSubcontractStatus t INNER JOIN dbo.tblMpSubContractSum s ON t.TransId = s.TransId
	INNER JOIN ( SELECT  s1.TransId, 
				  SUM(ISNULL(d1.QtySent, 0)) ActualQtySent
				, SUM(ISNULL(d1.QtyReceived, 0))  ActualReceived
				, SUM(ISNULL(d1.QtyScrapped, 0))  ActualScrapped 
				FROM dbo.tblMpSubContractSum s1 LEFT JOIN dbo.tblMpSubContractDtl d1 ON s1.TransId = d1.TransId 
				GROUP BY s1.TransId 
			   ) d ON s.TransId = d.TransId
	INNER JOIN dbo.tblApVendor v ON  s.DefaultVendorID = v.VendorID 	
	INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId
	INNER JOIN dbo.tblMpOrderReleases o ON r.ReleaseId = o.Id
WHERE (@NotStarted = 1 AND d.ActualQtySent = 0) OR
	(@InProcess = 1 AND d.ActualQtySent > 0 AND d.ActualReceived < EstQtyRequired) OR
	(@Completed = 1 AND d.ActualQtySent > 0 AND d.ActualReceived >= EstQtyRequired)
END TRY
BEGIN CATCH
EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpSubcontractStatus_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpSubcontractStatus_proc';

