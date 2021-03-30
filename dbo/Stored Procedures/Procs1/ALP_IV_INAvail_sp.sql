   
        
CREATE PROCEDURE [dbo].[ALP_IV_INAvail_sp]        
(            
  @Where nvarchar(1000)= NULL              
)           
AS          
  --mah 03/24/16: added fields related to order points, safety stock, eoq, etc   
  --mah 06/09/16 - added QtyInWhse , QtyInUse      
SET NOCOUNT ON          
DECLARE @str nvarchar(2000) = NULL                
BEGIN TRY          
        
SELECT l.ItemId, i.Descr, l.LocId, CAST((ISNULL(v.QtyCmtd,0)/ISNULL(u.ConvFactor,1)) AS DECIMAL(12,2)) AS QtyCmtd,         
  CAST(ISNULL(v.QtyOnOrder,0)/ISNULL(u.ConvFactor,1) AS DECIMAL(12,2)) AS QtyOnOrder,        
  CAST(ISNULL(o.QtyOnHand,0)/ISNULL(u.ConvFactor,1)  AS DECIMAL(12,2)) AS QtyOnHand,         
  CAST((ISNULL(o.QtyOnHand,0) - ISNULL(v.QtyCmtd,0))/ISNULL(u.ConvFactor,1)  AS DECIMAL(12,2))  AS QtyAvail        
  ,CAST((ISNULL(o.QtyOnHand,0) - ISNULL(v.Alp_QtyInUse,0)) AS DECIMAL(12,2)) AS QtyInWhse  
  ,CAST(ISNULL(v.Alp_QtyInUse,0) AS DECIMAL(12,2)) AS QtyInUse  
  ,ItemLocStatus = CASE WHEN l.ItemLocStatus = 1 THEN 'Active'      
 WHEN l.ItemLocStatus = 2 THEN 'Discontinued'      
 WHEN l.ItemLocStatus = 3 THEN 'Superseded'      
 WHEN l.ItemLocStatus = 4 THEN 'Obsolete'      
 ELSE 'unknown' END       
  ,a.AlpMFG AS MFG, a.AlpCATG AS CATG, a.AlpQMDescription AS QMDescr,         
  CAST(al.AlpInstalledPrice  AS DECIMAL(12,2))  AS InstPrice,         
  al.AlpDfltHours AS HrsR, al.AlpDfltPts AS PtsR, al.AlpDfltCommercialHours AS HrsC, al.AlpDfltCommercialPts AS PtsC       
  ,ItemStatus = CASE WHEN i.ItemStatus = 1 THEN 'Active'      
 WHEN i.ItemStatus = 2 THEN 'Discontinued'      
 WHEN i.ItemStatus = 3 THEN 'Superseded'      
 WHEN i.ItemStatus = 4 THEN 'Obsolete'      
 ELSE 'unknown' END       
 , l.DfltBinNum as DfltBin    
 , CAST(l.Eoq as Decimal(12,2)) as EOQ    
 , CAST(l.QtySafetyStock as Decimal(12,2))  as SafetyStock    
 , CAST(l.QtyOrderPoint as Decimal(12,2))  as OrderPoint    
 , CAST(l.QtyOnHandMax as Decimal(12,2))  as OnHandMax    
 , CAST(l.QtyOrderMin as Decimal(12,2))  as MinOrder  
 , CAST(l.CostStd as Decimal(12,2))  as StdCost    
 , CAST(l.CostAvg as Decimal(12,2))  as AvgCost    
 , CAST(l.CostBase as Decimal(12,2))  as BaseCost    
 , CAST(l.CostLast as Decimal(12,2))  as LastCost 
 ,l.OrderQtyUom
 ,i.UomBase   
 INTO #temp          
 FROM dbo.tblInItem i (NOLOCK) INNER JOIN dbo.tblInItemLoc l (NOLOCK) ON i.ItemId = l.ItemId        
  INNER JOIN dbo.tblInItemUom u (NOLOCK) ON l.ItemId = u.ItemId        
  LEFT JOIN dbo.ALP_tblInItem a (NOLOCK) ON i.ItemId = a.AlpItemId        
  LEFT JOIN dbo.ALP_tblInItemLoc al (NOLOCK) ON l.ItemId = al.AlpItemId AND l.LocId = al.AlpLocId        
  LEFT JOIN dbo.trav_InItemOnHand_view o (NOLOCK) ON l.ItemId = o.ItemId AND l.LocId = o.LocId        
  --LEFT JOIN dbo.trav_InItemQtys_view v (NOLOCK) ON l.ItemId = v.ItemId AND l.LocId = v.LocId   
  LEFT JOIN dbo.ALP_InItemQtys_view v (NOLOCK) ON l.ItemId = v.ItemId AND l.LocId = v.LocId        
 WHERE  u.Uom = i.UomBase AND i.ItemType = 1  --i.ItemId = @ItemId        
 --UNION ALL        
         
 --SELECT l.ItemId, l.LocId, ISNULL(v.QtyCmtd,0) AS QtyCmtd, ISNULL(v.QtyOnOrder,0) AS QtyOnOrder,        
 -- ISNULL(o.QtyOnHand,0) AS QtyOnHand, (ISNULL(o.QtyOnHand,0) - ISNULL(v.QtyCmtd,0)) AS QtyAvail        
 -- , l.ItemLocStatus, a.AlpMFG, a.AlpCATG, a.AlpQMDescription, al.AlpInstalledPrice,         
 -- al.AlpDfltHours, al.AlpDfltPts, al.AlpDfltCommercialHours, al.AlpDfltCommercialPts         
 --INTO #temp         
 --FROM dbo.tblInItem i (NOLOCK) INNER JOIN dbo.tblInItemLoc l (NOLOCK) ON i.ItemId = l.ItemId        
 --  LEFT JOIN dbo.ALP_tblInItem a (NOLOCK) ON i.ItemId = a.AlpItemId        
 -- LEFT JOIN dbo.ALP_tblInItemLoc al (NOLOCK) ON l.ItemId = al.AlpItemId AND l.LocId = al.AlpLocId        
 -- LEFT JOIN dbo.trav_InItemOnHandSer_view o (NOLOCK) ON l.ItemId = o.ItemId AND l.LocId = o.LocId        
 -- LEFT JOIN dbo.trav_InItemQtys_view v (NOLOCK) ON l.ItemId = v.ItemId AND l.LocId = v.LocId        
 --WHERE i.ItemType = 2 --i.ItemId = @ItemId AND         
        
 SET @str =              
'SELECT * FROM #temp '               
  + CASE WHEN @Where IS NULL THEN ' '              
 WHEN @Where = '' THEN ' '              
 WHEN @Where = ' ' THEN ' '              
 ELSE ' WHERE ' + @Where              
 END  + ' '          
            
 execute (@str)             
 DROP TABLE #temp            
 END TRY                
BEGIN CATCH              
 DROP TABLE #temp              
 EXEC dbo.trav_RaiseError_proc                
END CATCH