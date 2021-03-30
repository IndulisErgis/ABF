
--PET:http://problemtrackingsystem.osas.com/view.php?id=263034

CREATE PROCEDURE [dbo].[trav_WmProductionConfirmList]  
@PrecQty Tinyint = NULL
AS  
BEGIN TRY  
SET NOCOUNT ON  
	SELECT Cast(0 AS  bit) as Completed, d.ComponentID,d.LocID,h.OrderNo,h.ReleaseNo,d.Uom,d.EstQtyRequired,req.EstStartDate as RequiredDate,req.ReqId,
	ISNULL(r.QtyConfirmTot,0) +  t.QtyRcptTot AS QtyRcptTot, d.TransId
	,d.ComponentType,u.Convfactor, 
	CASE WHEN ISNULL(r.QtyConfirmTot,0) +  t.QtyRcptTot - d.EstQtyRequired > = 0 THEN Cast(1 AS  bit) ELSE Cast(0 AS  bit) END  As QuantitySatisfied
	FROM dbo.tblMpOrderReleases h (NOLOCK)
	INNER JOIN tblMpRequirements req ON h.Id=req.ReleaseId
	INNER JOIN dbo.tblMpMatlSum d (NOLOCK) ON req.TransId =d.TransId 
	INNER JOIN dbo.tblInItemUom u (NOLOCK) ON d.ComponentId = u.ItemId AND d.Uom = u.Uom
	INNER JOIN
	(
	SELECT s.TransId, SUM(ROUND(d.Qty * du.Convfactor / su.Convfactor,@PrecQty) ) QtyRcptTot FROM dbo.tblMpMatlSum s 
	INNER JOIN dbo.tblWmRcpt d (NOLOCK) ON s.TransId = d.EntryNum  
	LEFT JOIN dbo.tblInItemUom du (NOLOCK) ON d.ItemId = du.ItemId AND d.Uom = du.Uom
	LEFT JOIN dbo.tblInItemUom su (NOLOCK) ON s.ComponentId = su.ItemId AND d.Uom = su.Uom 
	WHERE d.Source = 2 AND d.Status <> 2  GROUP BY s.TransID) t ON d.TransId = t.TransId 
	LEFT JOIN 
	(
	SELECT s.TransId, SUM(ROUND(d.Qty * du.Convfactor / su.Convfactor,@PrecQty) ) QtyConfirmTot FROM dbo.tblMpMatlSum s 
	INNER JOIN dbo.tblMpMatlDtl d (NOLOCK) 
	ON s.TransId = d.TransId 
	LEFT JOIN dbo.tblInItemUom su (NOLOCK) ON s.ComponentId= su.ItemId AND s.Uom = su.Uom
	LEFT JOIN dbo.tblInItemUom du (NOLOCK) ON d.ComponentId = du.ItemId AND d.Uom = du.Uom 
	GROUP BY s.TransID 
	) r ON d.TransId = r.TransId 
	WHERE  h.Status <> 6 AND((d.ComponentType = 5 AND d.Status <> 6) OR d.ComponentType = 0)
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc   
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmProductionConfirmList';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmProductionConfirmList';

