
CREATE PROCEDURE [dbo].[trav_MbBomWorksheets_Proc]

@QtyToBuild pDecimal = 1	--Quantity to build 

AS
SET NOCOUNT ON

BEGIN TRY

      SELECT h.AssemblyId, h.RevisionNo, h.[Description], h.Instructions, r.RtgType
            , r.Step, r.Descr AS RoutingDesc, r.Notes, r.OperationId, r.MachineGroupId          
            , CASE WHEN r.OperationType = 3 THEN @QtyToBuild / CASE WHEN r.MachRunTime = 0 THEN 1.0 ELSE ISNULL(r.MachRunTime, 1.0) END ELSE ISNULL(r.MachRunTime, 1.0) END AS MachRunTime, r.MachRunTimeIn        
            , r.LaborTypeId, CASE WHEN r.OperationType = 3 THEN @QtyToBuild / CASE WHEN  r.LaborRunTime = 0 THEN 1.0 ELSE ISNULL(r.LaborRunTime, 1) END ELSE ISNULL(r.LaborRunTime, 1.0) END AS LaborRunTime
            , r.LaborRunTimeIn, d.Sequence, d.ComponentID, d.LocId
            , d.Qty * (CASE WHEN d.UsageType = 1 THEN 1.0 ELSE @QtyToBuild END) AS Qty, d.ScrapPct                                
            , (CASE WHEN d.UsageType = 1 THEN 1.0 ELSE @QtyToBuild END) * (d.Qty + ((CASE WHEN d.DetailType = 5 THEN -1.0 ELSE 1.0 END) 
                        * (CASE WHEN d.ScrapPct <= 0 OR d.ScrapPct >= 100 THEN 0 ELSE (d.Qty * (100.00 / (100.00 - d.ScrapPct))) - d.Qty END))) AS ExtQty   
            , d.UOM AS ComponentUOM, d.DetailType, d.[Description] AS ComponentDesc
      FROM dbo.tblMbAssemblyHeader h INNER JOIN dbo.tblMbAssemblyRouting r ON h.Id = r.HeaderId
            LEFT JOIN dbo.tblMbAssemblyDetail d ON r.Id = d.RoutingId
            LEFT JOIN dbo.tblInItem i ON d.ComponentID = i.ItemId
            INNER JOIN #tmpBomWorksheets tmp ON tmp.Id = h.Id 
		
	--BOM Worksheets Tooling		
	SELECT o.OperationID, o.ToolingId, t.Descr 
	FROM #tmpBomWorksheets m INNER JOIN dbo.tblMbAssemblyHeader h ON m.Id = h.Id
		INNER JOIN dbo.tblMbAssemblyRouting r ON h.Id = r.HeaderId
		INNER JOIN dbo.tblMrOperationsTooling o ON r.OperationId = o.OperationId
		INNER JOIN dbo.tblMrTooling t ON o.ToolingId = t.ToolingId		
	GROUP BY o.OperationID, o.ToolingId, t.Descr 
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbBomWorksheets_Proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbBomWorksheets_Proc';

