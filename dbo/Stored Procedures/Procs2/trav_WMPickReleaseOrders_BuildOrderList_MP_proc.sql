
CREATE PROCEDURE dbo.trav_WMPickReleaseOrders_BuildOrderList_MP_proc
AS
BEGIN TRY
	SET NOCOUNT ON
	DECLARE @PrecQty pDecimal
		
	--Retrieve global values
	SELECT @PrecQty = Cast([Value] AS decimal(28,10)) FROM #GlobalValues WHERE [Key] = 'PrecQty'

	IF @PrecQty IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

Insert into #OrderList(SourceId, TransId, EntryNum, SeqNum, PickNum  
  , ItemId, LocId, LotNum, ExtLocA, ExtLocB, UOM, QtyReq, ReqDate  
  , GrpId, OriCompQty, Ref1, Ref2, Ref3)   
  Select 1, 'MFP', s.TransId, s.SeqNum, Null  
  , s.ComponentId, s.LocId, s.LotNum, s.ExtLocA, s.ExtLocB, s.UOM  
  , Case When s.ExtQtyReq is Null   
   Then Case When (s.EstQtyRequired - Round((isnull(d.Qty, 0) / u.ConvFactor), @PrecQty)) > 0   
    Then (s.EstQtyRequired - Round((isnull(d.Qty, 0) / u.ConvFactor), @PrecQty))   
    Else 0 End  
   Else Case When s.ExtQtyReq > 0 Then s.ExtQtyReq Else 0 End  
  End  
  , s.RequiredDate, Null, 0, s.OrderNo, s.ReleaseNo, s.ReqID  
  From
   (
   Select s1.TransId, isnull(e.SeqNum, 0) SeqNum, s1.ComponentType, s1.ComponentId, s1.LocId, s1.UOM  
   , req.EstStartDate AS RequiredDate, rel.OrderNo, rel.ReleaseNo, req.ReqId  
   , e.LotNum, e.ExtLocA, e.ExtLocB, (e.QtyRequired - e.QtyFilled) ExtQtyReq, s1.EstQtyRequired  
   From dbo.tblMpMatlSum s1    
   INNER JOIN  tblMpRequirements req ON req.TransId =s1.TransId 
   INNER JOIN  tblMpOrderReleases rel ON rel.Id=req.ReleaseId    
   LEFT JOIN  dbo.tblMpMatlSumExt e  ON s1.TransId = e.TransId
   LEFT JOIN dbo.tblSmTransLink l ON s1.[LinkSeqNum] = l.[SeqNum]
   WHERE s1.[Status] <> 6 ----Not Completed   
   AND (l.SeqNum IS NULL OR l.TransLinkType = 1 OR l.SourceStatus = 2 OR l.DestStatus = 2 OR (l.TransLinkType = 0 AND l.DropShipYn=0)) --((transaction linked and not DropShipped) or link is broken)
   )s  
   LEFT JOIN  
  (
  Select dtl.TransId, dtl.ComponentId, dtl.LocId, Sum(Round(dtl.Qty * dtlUom.ConvFactor, @PrecQty)) Qty   
  From dbo.tblMpMatlDtl dtl   
  INNER JOIN  dbo.tblInItemUom dtlUom ON dtl.ComponentId=dtlUom.ItemId  AND  dtlUom.Uom=dtl.UOM 
  Group By dtl.TransId, ComponentId, LocId
  )d ON s.TransId = d.TransId AND s.ComponentId = d.ComponentId AND s.LocId = d.LocId --can't include item/loc alternates  
  INNER JOIN  dbo.tblInItem i ON i.ItemId = s.ComponentId  
  INNER JOIN  dbo.tblInItemUom u ON u.ItemId =s.ComponentId AND u.Uom=s.UOM 
  Where (s.ComponentType = 3 Or s.ComponentType = 4) --material components  
  AND (s.EstQtyRequired - Round((isnull(d.Qty, 0) / u.ConvFactor), @PrecQty)) > 0  AND (i.ItemType <> 3)  
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_MP_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_MP_proc';

