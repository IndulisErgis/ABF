
--PET:http://problemtrackingsystem.osas.com/view.php?id=263034

CREATE PROCEDURE [dbo].[trav_MpReqirmentsAvailability_Proc]
@SortBy tinyint
AS
SET NOCOUNT ON

BEGIN TRY

	SELECT CASE @SortBy WHEN 0 THEN s.ComponentId WHEN 1 THEN o.OrderNo END AS GrpId1
		, CASE @SortBy WHEN 0 THEN s.LocId WHEN 1 THEN RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) END AS GrpId2
		, CASE @SortBy WHEN 0 THEN i.UomDflt WHEN 1 THEN s.ComponentId END AS GrpId3
		, CASE @SortBy WHEN 0 THEN i.UomDflt WHEN 1 THEN CAST(CONVERT(nvarchar(8), r.EstStartDate,112) AS nvarchar) END AS GrpId4
		, CASE @SortBy WHEN 0 THEN CAST(CONVERT(nvarchar(8), r.EstStartDate,112) AS nvarchar) 
			WHEN 1 THEN CAST(CONVERT(nvarchar(8), r.EstStartDate,112) AS nvarchar) END AS GrpId5,
		o.OrderNo, o.ReleaseNo, o.Priority, r.EstStartDate AS RequiredDate, r.ReqId, h.AssemblyId, h.LocId AS AssemblyLocId,
		o.CustId, o.EstStartDate, s.ComponentId, s.LocId, a.AddlDescr, i.Descr, i.UomDflt AS Uom, l.DfltLeadTime AS LeadTime,
		CASE WHEN s.[Status] <> 6 AND (s.EstQtyRequired * ISNULL(m.ConvFactor,1) - ISNULL(d.QtyFilled,0)) / ISNULL(u.ConvFactor,1) > 0 
			THEN (s.EstQtyRequired * ISNULL(m.ConvFactor,1) - ISNULL(d.QtyFilled,0)) / ISNULL(u.ConvFactor,1) ELSE 0 END AS NetQtyRequired,
		ISNULL(q.QtyOnHand,0) / ISNULL(u.ConvFactor,1) AS Available, ISNULL(v.QtyCmtd,0) / ISNULL(u.ConvFactor,1) AS QtyCmtd, ISNULL(v.QtyOnOrder,0) / ISNULL(u.ConvFactor,1) AS QtyOnOrder
	FROM #tmpRequirementAvailability t INNER JOIN dbo.tblMpMatlSum s ON t.TransId = s.TransId
		INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId
		INNER JOIN dbo.tblMpOrderReleases o ON r.ReleaseId = o.Id     
		INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
		INNER JOIN dbo.tblInItem i ON s.ComponentId = i.ItemId 
		INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId AND s.LocId = l.LocId 
		LEFT JOIN (SELECT s.TransId, SUM(d.Qty * ISNULL(u.ConvFactor, 1)) AS QtyFilled 
					FROM dbo.tblMpMatlSum s INNER JOIN dbo.tblMpMatlDtl d ON s.TransId = d.TransId AND s.ComponentId = d.ComponentId AND s.LocId = d.LocId 
						LEFT JOIN dbo.tblInItemUom u ON d.ComponentId = u.ItemId AND d.UOM = u.Uom 
					GROUP BY s.TransId) d ON s.TransId = d.TransId 
		LEFT JOIN (	SELECT ItemId, LocId, QtyOnHand 
					FROM dbo.trav_InItemOnHand_view
					UNION ALL
					SELECT ItemId, LocId, QtyOnHand 
					FROM dbo.trav_InItemOnHandSer_view) q ON s.ComponentId = q.ItemId AND s.LocId = q.LocId 
		LEFT JOIN dbo.trav_InItemQtys_view v ON s.ComponentId = v.ItemId AND s.LocId = v.LocId
		LEFT JOIN dbo.tblInItemAddlDescr a ON i.ItemId = a.ItemId 
		LEFT JOIN tblInItemUom m ON s.ComponentId = m.ItemId AND s.UOM = m.Uom 
		LEFT JOIN tblInItemUom u ON s.ComponentId = u.ItemId AND i.UomDflt = u.Uom
            
END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpReqirmentsAvailability_Proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpReqirmentsAvailability_Proc';

