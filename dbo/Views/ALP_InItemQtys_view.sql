CREATE VIEW dbo.ALP_InItemQtys_view  
AS  
SELECT ItemId,LocId,Sum(CASE WHEN TransType=0 THEN Qty ELSE 0 END ) AS QtyCmtd,  
 Sum(CASE WHEN TransType=2 THEN Qty ELSE 0 END ) AS QtyOnOrder,  
 Sum(CASE WHEN TransType=1 THEN Qty ELSE 0 END ) AS QtyInUse ,
 SUM(CASE WHEN TransType=0 AND LinkIdSubline=1 AND LinkId='JM' THEN Qty ELSE 0 END)ALP_QtyInUse
FROM dbo.tblInQty  
GROUP BY ItemId,LocId