
CREATE PROCEDURE [dbo].[trav_MpOrderStatus_proc]  
@SortBy  TINYINT
AS
BEGIN TRY
SET NOCOUNT ON

SELECT CASE @SortBy 
          WHEN 0 THEN CAST(h.OrderNo AS nvarchar) 
          WHEN 1 THEN CAST(o.CustId AS nvarchar) 
          WHEN 2 THEN CAST(h.AssemblyId AS nvarchar) END AS SortBy, o.Id,
    h.OrderNo, o.ReleaseNo, h.AssemblyId, o.Qty, o.UOM, o.CustId , o.PurchaseOrder, o.SalesOrder, o.[Status], o.EstCompletionDate
FROM #tmpOrderRelease t INNER JOIN dbo.tblMpOrderReleases o ON t.Id = o.Id  
	INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo 
				
-- Order Status Components
SELECT o.Id, d.ComponentId AS ComponentId, i.Descr, s.Uom, s.EstQtyRequired, s.EstScrap
    , d.Scrap, d.Used, r.ReqId, r.Step
FROM #tmpOrderRelease t INNER JOIN dbo.tblMpOrderReleases o ON t.Id = o.Id 
	INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
	INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId  
	INNER JOIN dbo.tblMpMatlSum s ON r.TransId = s.TransId
	INNER JOIN 
		(SELECT s.TransId, COALESCE(d.ComponentID, s.ComponentId) AS ComponentId, 
			COALESCE(SUM(d.ActualScrap * ISNULL(ud.ConvFactor,1) / COALESCE(us.ConvFactor,1)),0) AS Scrap,
			COALESCE(SUM(d.Qty * COALESCE(ud.ConvFactor,1) / COALESCE(us.ConvFactor,1)),0) AS Used
		 FROM dbo.tblMpMatlSum s LEFT JOIN dbo.tblMpMatlDtl d ON s.TransId = d.TransId
			LEFT JOIN dbo.tblInItemUom us ON s.ComponentId = us.ItemId AND s.UOM = us.Uom
			LEFT JOIN dbo.tblInItemUom ud ON d.ComponentId = ud.ItemId AND d.UOM = ud.Uom
		 GROUP BY s.TransId, d.ComponentID, s.ComponentId) d ON s.TransId = d.TransId
	LEFT JOIN dbo.tblInItem i ON s.ComponentID = i.ItemId       
WHERE d.ComponentId <> h.AssemblyID AND s.ComponentType <> 2 

--Order Status Process
SELECT o.Id, r.ReqID, s.OperationID
	, CASE WHEN o.[Status] = 6 THEN o.[Status] ELSE s.[Status] END AS [Status]
	, p.Descr, s.MachineSetupEst / 60.0 AS MachineSetupEst
    , s.MachineRunEst / 60.0 AS MachineRunEst, s.LaborSetupEst / 60.0 AS LaborSetupEst, s.LaborEst / 60.0 AS LaborRunEst, 
    COALESCE(d.MSetupTot, 0) AS MachineSetupTotal, COALESCE(d.MRunTot, 0) AS MachineRunTotal, 
    COALESCE(d.LSetupTot, 0) AS LaborSetupTotal, COALESCE(d.LaborTot, 0) AS LaborRunTotal
	, CASE WHEN s.QtyProducedEst = 0 THEN 0 ELSE COALESCE(d.QtyProduced, 0) / s.QtyProducedEst * 100 END AS ActualYieldPct
	, s.QtyProducedEst AS QtyPlanned, COALESCE(d.QtyProduced, 0) AS QtyProduced, COALESCE(d.QtyScrapped, 0) AS QtyScrapped 
FROM #tmpOrderRelease t INNER JOIN dbo.tblMpOrderReleases o ON t.Id = o.Id 
	INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId  
	INNER JOIN dbo.tblMpTimeSum s ON r.TransId = s.TransId 
	LEFT JOIN
		(
		SELECT TransId, SUM(MachineSetup / MachineSetupIn) AS MSetupTot, SUM(MachineRun / MachineRunIn) AS MRunTot, 
			SUM(LaborSetup / LaborSetupIn) AS LSetupTot, SUM(Labor / LaborIn) AS LaborTot
			, SUM(QtyProduced) AS QtyProduced, SUM(QtyScrapped) AS QtyScrapped 
		FROM dbo.tblMpTimeDtl
		GROUP BY TransId
		) d ON s.TransId = d.TransId
	LEFT JOIN dbo.tblMrOperations p ON s.OperationID = p.OperationId 

-- Status Subcontracted
SELECT o.Id, s.OperationId, p.Descr, s.EstQtyRequired
      , COALESCE(d.QtySentTotal, 0) AS QtySentTotal, COALESCE(d.QtyReceivedTotal, 0) AS QtyReceivedTotal
	  , CASE WHEN o.[Status] = 6 THEN o.[Status] ELSE s.[Status] END AS [Status] 
FROM #tmpOrderRelease t INNER JOIN dbo.tblMpOrderReleases o ON t.Id = o.Id 
	INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId  
	INNER JOIN dbo.tblMpSubContractSum s ON r.TransId = s.TransId 
	LEFT JOIN 
		(
			SELECT TransId, SUM(QtySent) AS QtySentTotal, SUM(QtyReceived) AS QtyReceivedTotal
			FROM dbo.tblMpSubContractDtl
			GROUP BY TransId
		) d ON s.TransId = d.TransId
	LEFT JOIN dbo.tblMrOperations p ON s.OperationID = p.OperationId 

--Status Production
SELECT o.Id, h.AssemblyId, i.[Descr], o.Qty, o.Uom, COALESCE(a.QtyScrapped, 0) / COALESCE(u.ConvFactor, 1) QtyScrapped, 
	COALESCE(a.QtyCompleted, 0) / COALESCE(u.ConvFactor, 1) QtyCompleted 
FROM #tmpOrderRelease t INNER JOIN dbo.tblMpOrderReleases o ON t.Id = o.Id 
	INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo	
	LEFT JOIN 
		(
			SELECT r.ReleaseId, SUM(m.Qty * COALESCE(u.ConvFactor,1)) AS QtyCompleted, SUM(m.ActualScrap * COALESCE(u.ConvFactor,1)) AS QtyScrapped
			FROM dbo.tblMpRequirements r INNER JOIN dbo.tblMpMatlDtl m ON r.TransId = m.TransId
				LEFT JOIN dbo.tblInItemUom u ON m.ComponentId = u.ItemId AND m.UOM = u.Uom 
			WHERE r.[Type] = 0 -- main assembly activity only
			GROUP BY r.ReleaseId
		) a ON o.Id = a.ReleaseId
	LEFT JOIN dbo.tblInItem i ON h.AssemblyId = i.ItemId  
	LEFT JOIN dbo.tblInItemUom u ON h.AssemblyId = u.ItemId AND o.UOM = u.Uom

END TRY
BEGIN CATCH
  EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpOrderStatus_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpOrderStatus_proc';

