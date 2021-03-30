
--PET:http://problemtrackingsystem.osas.com/view.php?id=263034

CREATE PROCEDURE dbo.trav_MpSubcontractedServices_proc
@SortBy tinyint = 0 -- 0 = Vendor ID, 1 = Order Number
AS
BEGIN TRY
	SET NOCOUNT ON

	-- header info
	-- join with the temp table to return a resultset containing the finish date
	SELECT q.TransId, o.OrderNo, r.ReleaseNo, q.ReqId
		, CASE WHEN @SortBy = 0 THEN s.DefaultVendorId ELSE o.OrderNo END AS GrpId1
		, s.DefaultVendorId AS VendorId, v.[Name], v.Contact, v.Addr1, v.Addr2, v.City, v.Region
		, v.PostalCode, v.Country, o.AssemblyId, o.RevisionNo, r.Routing AS RoutingStep
		, q.EstStartDate AS StartDate, CONVERT(nvarchar, q.EstStartDate, 112) AS StartDateSort
		, q.EstCompletionDate AS FinishDate, s.OperationId, s.[Description], s.Notes, s.EstQtyRequired AS Qty 
	FROM dbo.tblMpOrder o 
		INNER JOIN dbo.tblMpOrderReleases r ON o.OrderNo = r.OrderNo 
		INNER JOIN dbo.tblMpRequirements q ON r.Id = q.ReleaseId 
		INNER JOIN #tmpSubcontractServices b  ON b.TransId = q.TransId 
		INNER JOIN dbo.tblMpSubContractSum s ON q.TransId = s.TransId 		
		LEFT JOIN dbo.tblApVendor v ON s.DefaultVendorID = v.VendorID 

	-- detail info
	SELECT r.ParentId
		, m.ComponentId, m.LocId AS LocationId, m.EstQtyRequired AS EstQty, m.UOM AS Unit 
	FROM #tmpSubcontractServices s 
		INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.ParentId 
		INNER JOIN dbo.tblMpMatlSum m 
			ON r.TransId = m.TransId 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpSubcontractedServices_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpSubcontractedServices_proc';

