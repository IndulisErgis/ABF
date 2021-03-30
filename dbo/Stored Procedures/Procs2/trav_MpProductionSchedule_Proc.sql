
CREATE PROCEDURE [dbo].[trav_MpProductionSchedule_Proc]
@SortBy tinyint = 1 

AS
SET NOCOUNT ON

BEGIN TRY

	SELECT Case @SortBy When 0 Then r.OrderNo When 1 Then r.CustId When 2 then convert(nvarchar(8), r.EstStartDate, 112) Else o.AssemblyId End GrpId1,
		r.OrderNo, r.ReleaseNo, r.CustId, r.SalesOrder, r.PurchaseOrder, r.EstStartDate, r.EstCompletionDate, d.DateStarted, 
		CASE WHEN r.[Status] = 6 THEN d .DateCompleted ELSE NULL END AS DateCompleted, r.Status, r.Routing, r.Qty, r.UOM, 
		ISNULL(a.QtyCompleted,0) AS QtyCompleted, r.Priority, ISNULL(a.QtyScrapped,0) AS QtyScrapped, r.OrderSource, r.OrderCode, 
		r.Notes, o.AssemblyId, o.RevisionNo, o.LocID, o.Planner, c.CustName, m.[Description]
	FROM #tempMpProductionSchedule t INNER JOIN dbo.tblMpOrderReleases r ON t.Id = r.Id
		INNER JOIN dbo.tblMpOrder o ON r.OrderNo = o.OrderNo 
		LEFT JOIN ( SELECT r.ReleaseId, SUM(m.Qty * u.ConvFactor) AS QtyCompleted, 
						  SUM(m.ActualScrap * u.ConvFactor) AS QtyScrapped
					FROM dbo.tblMpRequirements r INNER JOIN dbo.tblMpMatlDtl m ON r.TransId = m.TransId
						LEFT JOIN dbo.tblInItemUom u ON m.ComponentId = u.ItemId AND m.UOM = u.Uom 
					WHERE r.Type = 0 -- main assembly activity only
					GROUP BY r.ReleaseId
				) a ON r.Id = a.ReleaseId
		LEFT JOIN ( SELECT r2.ReleaseId, MIN(d2.DateStarted) AS DateStarted, MAX(d2.DateCompleted) AS DateCompleted
					FROM   dbo.tblMpRequirements AS r2 
						INNER JOIN ( SELECT TransId, MIN(TransDate) AS DateStarted, MAX(TransDate) AS DateCompleted FROM dbo.tblMpMatlDtl GROUP BY TransId
									 UNION ALL
									 SELECT TransId, MIN(TransDate) AS DateStarted, MAX(TransDate) AS DateCompleted FROM dbo.tblMpTimeDtl GROUP BY TransId
									 UNION ALL
									 SELECT TransId, MIN(TransDate) AS DateStarted, MAX(TransDate) AS DateCompleted FROM dbo.tblMpSubContractDtl GROUP BY TransId
									) AS d2 ON r2.TransId = d2.TransId
					GROUP BY r2.ReleaseId
					) AS d ON r.Id = d.ReleaseId
		LEFT JOIN dbo.tblArCust c ON r.CustId = c.CustId 
		LEFT JOIN dbo.tblMbAssemblyHeader m ON o.AssemblyId = m.AssemblyId AND o.RevisionNo = m.RevisionNo
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProductionSchedule_Proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProductionSchedule_Proc';

