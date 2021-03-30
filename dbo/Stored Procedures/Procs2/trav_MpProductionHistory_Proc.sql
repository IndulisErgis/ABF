
CREATE PROCEDURE [dbo].[trav_MpProductionHistory_Proc]
@SortBy tinyint = 0,
@DateFrom datetime = null,
@DateThru datetime = null
AS

SET NOCOUNT ON

BEGIN TRY

      SELECT CASE @SortBy WHEN 0 THEN o.CustId WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10)
                 WHEN 2 THEN CAST(CONVERT(nvarchar(8), m.DateCompleted, 112) AS nvarchar) 
                 WHEN 3 THEN CAST(o.AssemblyId AS nvarchar) END AS GrpId1
            , o.PostRun, o.OrderNo, o.ReleaseNo, m.DateStarted, o.Uom, m.DateCompleted
            , o.CustId, o.SalesOrder, o.PurchaseOrder, o.AssemblyId, o.LocId, o.RevisionNo
            , ISNULL(m.QtyCompleted,0) AS QtyCompleted, ISNULL(m.QtyScrapped, 0) AS QtyScrapped
            , ISNULL(m.AvgUnitCost,0) AS AvgUnitCost, ISNULL(m.TotalCost,0) AS TotalCost, o.ReleaseId
      FROM #ProductionHistory t INNER JOIN dbo.tblMpHistoryOrderReleases o ON t.postRun = o.PostRun AND t.ReleaseId = o.ReleaseId
            INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
            LEFT JOIN (SELECT s.PostRun, s.TransId, MIN(d.TransDate) AS DateStarted, MAX(d.TransDate) AS DateCompleted,  
				SUM(d.Qty * d.ConvFactor / CASE s.ConvFactor WHEN 0 THEN 1 ELSE s.ConvFactor END) AS QtyCompleted,
				SUM(d.ActualScrap * d.ConvFactor / CASE s.ConvFactor WHEN 0 THEN 1 ELSE s.ConvFactor END) AS QtyScrapped,
				SUM(d.Qty * d.UnitCost) AS TotalCost,
				CASE WHEN SUM(d.Qty) = 0 THEN 0 
					ELSE SUM(d.Qty * d.UnitCost)/
					(SUM(d.Qty * d.ConvFactor / CASE s.ConvFactor WHEN 0 THEN 1 ELSE s.ConvFactor END)) END AS AvgUnitCost
				FROM dbo.tblMpHistoryMatlSum s INNER JOIN dbo.tblMpHistoryMatlDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
				GROUP BY s.PostRun, s.TransId) m ON r.PostRun = m.PostRun AND r.TransId = m.TransId
	  WHERE r.[Type] = 0 -- main assembly activity only
		AND (@DateFrom IS NULL OR m.DateCompleted >= @DateFrom)
		AND (@DateThru IS NULL OR m.DateCompleted <= @DateThru)
		
      --Serial
      SELECT s.PostRun, o.ReleaseId, s.LotNum, s.SerNum, s.CostUnit 
      FROM #ProductionHistory t INNER JOIN dbo.tblMpHistoryOrderReleases o ON t.postRun = o.PostRun AND t.ReleaseId = o.ReleaseId
            INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
			INNER JOIN dbo.tblMpHistoryMatlSer s ON r.PostRun = s.PostRun AND r.TransId = s.TransId
	  WHERE r.[Type] = 0 -- main assembly activity only	

      --Lot
      SELECT l.PostRun, o.ReleaseId, l.LotNum, l.QtyFilled * d.ConvFactor / CASE s.ConvFactor WHEN 0 THEN 1 ELSE s.ConvFactor END AS QtyFilled
       FROM #ProductionHistory t INNER JOIN dbo.tblMpHistoryOrderReleases o ON t.postRun = o.PostRun AND t.ReleaseId = o.ReleaseId
            INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
            INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
            INNER JOIN dbo.tblMpHistoryMatlDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId 
			INNER JOIN dbo.tblMpHistoryMatlDtlExt l ON d.PostRun = l.PostRun AND d.TransId = l.TransId AND d.SeqNo = l.EntryNum
	  WHERE r.[Type] = 0 AND l.LotNum IS NOT NULL -- main assembly activity only	
            
END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProductionHistory_Proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProductionHistory_Proc';

