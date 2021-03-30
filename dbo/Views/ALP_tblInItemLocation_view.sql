CREATE VIEW   [dbo].[ALP_tblInItemLocation_view]  
AS    
SELECT    ItemId, LocId,GLAcctCode,ItemLocStatus,CostStd,CostAvg,CostBase,CostLast,CarrCostPct,OrderCostAmt,QtySafetyStock,QtyOrderPoint,QtyOnHandMax,
QtyOrderMin,Eoq,EoqType,ForecastId,SafetyStockType,OrderPointType,DateLastSale,DateLastPurch,DateLastSaleRet,DateLastPurchRet,DateLastXfer,DateLastAdj,
DateLastBuild,DateLastMatReq,DfltLeadTime,DfltBinNum,DfltVendId,DfltPriceId,PriceAdjType,PriceAdjBase,PriceAdjAmt,ts,ABCClass,CostLandedLast,
OrderQtyUom, Cast( dbo.tblInItemLoc.CF as nvarchar(max) )as cf, dbo.ALP_tblInItemLoc.*    
FROM         dbo.tblInItemLoc LEFT OUTER JOIN    
             dbo.ALP_tblInItemLoc  ON dbo.tblInItemLoc.ItemId = dbo.ALP_tblInItemLoc.AlpItemId AND     
                     dbo.tblInItemLoc.LocId  = dbo.ALP_tblInItemLoc.AlpLocId