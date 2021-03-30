  
CREATE PROCEDURE [dbo].[ALP_qryJm110b00ARItems_sp]          
/* modified 03/23/15 MAH - major changes changes to display reversl payments correctly   */    
/* modified 04/02/15 MAH ON ACCTto use latest TransDate rather than earliest  */      
(          
 @CustID pCustID = null          
)   
       
AS          
SET NOCOUNT ON          
 CREATE TABLE #OpenItems          
 (          
 InvcNum nvarchar(15) NOT NULL      
 )       
 INSERT INTO #OpenItems (InvcNum)          
 (SELECT distinct AROI.InvcNum FROM tblArOpenInvoice AROI            
  where CustID = @CustId         
   AND AROI.Status <>4           
 GROUP BY AROI.InvcNum      
 )           
 CREATE TABLE #OpenItems_I          
 (          
 InvcNum nvarchar(15) NOT NULL,          
 Ident integer          
 )          
INSERT INTO #OpenItems_I (InvcNum, Ident)          
 (SELECT AROI.InvcNum,MIN(CASE WHEN RecType > 0 THEN AROI.Counter ELSE 999999999 END ) as Ident            
 FROM tblArOpenInvoice AROI       
 INNER JOIN  #OpenItems  ON AROI.InvcNum =  #OpenItems.InvcNum      
 WHERE AROI.CustID = @CustId and AROI.InvcNum NOT LIKE 'ON%'        
  ----mah 02/11/15:          
  -- --AND AROI.Status <>4           
  -- --AND AROI.RecType > 0         
 GROUP BY AROI.InvcNum        
  HAVING max(RecType) > 0 
  --5/5/15: added max status changes, to avoid pulling remnants of previously purged old data
    AND MIN(Status) < 4
  AND SUM(CASE WHEN RecType > 0 THEN Amt ELSE Amt * -1 END )  <> 0        
 )          
          
CREATE TABLE #OpenItems_C          
 (          
 InvcNum nvarchar(15) NOT NULL,          
 Ident integer          
 )          
INSERT INTO #OpenItems_C (InvcNum, Ident)          
 (SELECT AROI.InvcNum,MIN(CASE WHEN AROI.RecType <= 0 THEN AROI.Counter ELSE 999999999 END ) as Ident             
  FROM tblArOpenInvoice AROI       
 INNER JOIN  #OpenItems  ON AROI.InvcNum =  #OpenItems.InvcNum          
  WHERE AROI.CustID = @CustId and AROI.InvcNum NOT LIKE 'ON%'         
  GROUP BY AROI.InvcNum          
  having max(AROI.RecType) < 0  and SUM(CASE WHEN AROI.RecType > 0 THEN AROI.Amt ELSE AROI.Amt * -1 END )  <> 0        
 )          
           
CREATE TABLE #OpenOnacctItems          
 (          
 InvcNum nvarchar(15) NOT NULL,          
 OnAcctIdent integer,          
 TransDate date          
 )          
INSERT INTO #OpenOnacctItems (InvcNum, OnAcctIdent, TransDate)          
 (SELECT AROI.InvcNum, MIN(AROI.Counter) as OnAcctIdent, AROI.TransDate          
 FROM tblArOpenInvoice AROI        
 INNER JOIN  #OpenItems  ON AROI.InvcNum =  #OpenItems.InvcNum             
 WHERE AROI.CustID = @CustId AND AROI.InvcNum LIKE 'ON%' --AND AROI.Status <>4          
 GROUP BY AROI.InvcNum, AROI.TransDate           
 --mah 01/26/15:          
 ,AROI.PmtMethodId, AROI.CheckNum       
 having --max(AROI.RecType) < 0  and       
 SUM(CASE WHEN AROI.RecType > 0 THEN AROI.Amt ELSE AROI.Amt * -1 END )  <> 0          
 )          
          
SELECT 'A-NotOA',  AlpSiteID = MAX( CASE WHEN OIU.Ident is not null THEN AROI.AlpSiteID          
       ELSE 0 END),           
  Min(AROI.TransDate) AS FirstOfTransDate,          
  InvoiceDate = Min(AROI.TransDate),          
  AROI.InvcNum,          
   Amount = SUM( CASE WHEN OIU.Ident is not null THEN          
        CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       ELSE 0 END),           
  Applied = SUM( CASE WHEN OIU.Ident is not null THEN 0          
       ELSE CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       END),            
   Balance =          
    (SUM( CASE WHEN OIU.Ident is not null THEN          
        CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       ELSE 0 END)) +           
    (SUM( CASE WHEN OIU.Ident is not null THEN 0          
       ELSE CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       END) ) ,           
  AROI.CustId           
  --mah 01/26/15: add TransID to help identify original transaction for reprint later via Control Center          
  ,AlpTransID = MAX( CASE WHEN OIU.Ident is not null THEN AROI.AlpTransID          
       ELSE '' END)          
  ,PmtMethodId = MAX( CASE WHEN OIU.Ident is not null THEN AROI.PmtMethodId          
       ELSE '' END)          
  ,CheckNum = MAX( CASE WHEN OIU.Ident is not null THEN AROI.CheckNum          
       ELSE '' END)          
      
 FROM ALP_tblArOpenInvoice_view AROI            
 LEFT OUTER JOIN   #OpenItems_I OIU   
 ON AROI.InvcNum = OIU.InvcNum AND AROI.Counter = OIU.Ident           
 WHERE AROI.CustId=@CustID            
 AND AROI.InvcNum Not Like 'on acc%'           
 --AND AROI.Status<>4          
 GROUP BY   
  AROI.custID,           
  AROI.InvcNum  
  --,             
  --AROI.Status,              
  --AROI.custID            
 HAVING           
 (          
  (SUM( CASE WHEN OIU.Ident is not null THEN          
    CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
    ELSE 0 END)) +           
  (SUM( CASE WHEN OIU.Ident is not null THEN 0          
    ELSE CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
  END) ) <> 0          
  AND MAX(RecType) > 0 
    --5/5/15: added max status changes, to avoid pulling remnants of previously purged old data
    AND MIN(Status) < 4         
 )          
UNION ALL          
          
SELECT 'B-NotOA',  AlpSiteID = MAX( CASE WHEN OIU.Ident is not null THEN AROI.AlpSiteID          
       ELSE 0 END),   
  Min(AROI.TransDate) AS FirstOfTransDate,          
  InvoiceDate = Min(AROI.TransDate),          
  AROI.InvcNum,          
   Amount = SUM( CASE WHEN OIU.Ident is not null THEN          
        CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       ELSE 0 END),           
  Applied = SUM( CASE WHEN OIU.Ident is not null THEN 0          
       ELSE CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       END),            
   Balance =          
    (SUM( CASE WHEN OIU.Ident is not null THEN          
        CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       ELSE 0 END)) +           
    (SUM( CASE WHEN OIU.Ident is not null THEN 0          
       ELSE CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       END) ) ,           
  AROI.CustId          
  --mah 01/26/15: add TransID to help identify original transaction for reprint later via Control Center          
  ,AlpTransID = MIN( CASE WHEN OIU.Ident is not null THEN AROI.AlpTransID          
       ELSE '' END)          
  ,PmtMethodId = MAX( CASE WHEN OIU.Ident is not null THEN AROI.PmtMethodId          
       ELSE '' END)          
  ,CheckNum = MAX( CASE WHEN OIU.Ident is not null THEN AROI.CheckNum          
       ELSE '' END)          
            
 FROM ALP_tblArOpenInvoice_view AROI          
  left outer JOIN  #OpenItems_C OIU      
 --INNER JOIN          
 ON AROI.InvcNum = OIU.InvcNum AND AROI.Counter = OIU.Ident           
 WHERE AROI.CustId=@CustId   
       AND AROI.InvcNum Not Like 'on acc%'         
 GROUP BY   
  AROI.custID,           
  AROI.InvcNum  
  --,           
  --AROI.Status,           
  --AROI.CustId          
 HAVING           
  (AROI.InvcNum Not Like 'on acc%'           
  AND           
  (SUM( CASE WHEN OIU.Ident is not null THEN          
        CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       ELSE 0 END)) +           
    (SUM( CASE WHEN OIU.Ident is not null THEN 0          
       ELSE CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       END))  <> 0           
  --AND AROI.Status<>4 
  AND MAX(RecType) < 0)
    --5/5/15: added max status changes, to avoid pulling remnants of previously purged old data
    AND MIN(Status) < 4          
UNION ALL          
SELECT 'C-OA', 
  --mah 05/01/15: fix ON ACCT displays by not grouping by SiteId 
  MIN(AROI.AlpSiteID) AS AlpSiteId, 
  --AROI.AlpSiteID,           
  --MIN(AROI.TransDate) AS TransDate,          
  --min(AROI.TRansDate) AS InvoiceDate,   
  MAX(AROI.TransDate) AS TransDate,          
  MAX(AROI.TRansDate) AS InvoiceDate,          
  AROI.InvcNum,           
  Amount = SUM( CASE WHEN OA.OnacctIdent is not null THEN          
        CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       ELSE 0 END),           
  Applied = SUM( CASE WHEN OA.OnacctIdent is not null THEN 0          
       ELSE CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       END),           
  Balance =          
    (SUM( CASE WHEN OA.OnacctIdent is not null THEN          
        CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       ELSE 0 END)) +           
    (SUM( CASE WHEN OA.OnacctIdent is not null THEN 0          
       ELSE CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
       END) ) ,            
   AROI.custID          
  --mah 01/26/15: add TransID to help identify original transaction for reprint later via Control Center          
  ,AlpTransID = MAX( CASE WHEN OA.OnAcctIdent is not null THEN AROI.AlpTransID          
       ELSE '' END)          
  ,PmtMethodId = MAX( CASE WHEN OA.OnAcctIdent is not null THEN AROI.PmtMethodId          
       ELSE '' END)   
 --,CheckNum = MAX( CASE WHEN OA.OnAcctIdent is not null THEN AROI.CheckNum          
 --  ELSE '' END)      
 ,CheckNum = MAX( CASE WHEN OA.OnAcctIdent is null THEN ''  
      ELSE CASE WHEN AROI.CheckNum IS NULL THEN ''  
       WHEN AROI.CheckNum = '' THEN ''  
       WHEN AROI.CheckNum = ' ' THEN ''  
       ELSE AROI.CheckNum  
      END         
     END)     
            
 FROM ALP_tblArOpenInvoice_view AROI           
  LEFT OUTER JOIN #OpenOnacctItems OA ON AROI.[Counter] = OA.OnAcctIdent          
 WHERE AROI.CustId=@custId          
 GROUP BY   
  AROI.custID, 
  --mah 05/01/15: fix ON ACCT displays by not grouping by SiteId          
  --AROI.AlpSiteID,          
  --mah 01/26/15:          
  AROI.InvcNum  
  --AROI.CheckNum           
  --AROI.TransDate,           
    
  --,           
  --AROI.Status,            
  --AROI.custID          
 HAVING           
  (          
  AROI.InvcNum Like 'on acc%'           
  AND           
  (          
   (SUM( CASE WHEN OA.OnacctIdent is not null THEN          
    CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
    ELSE 0 END)) +           
   (SUM( CASE WHEN OA.OnacctIdent is not null THEN 0          
    ELSE CASE WHEN (Rectype < 0 ) THEN [amt]*-1 ELSE [amt] END          
    END) ) <> 0            
  )           
  --AND AROI.Status<>4  
    --5/5/15: added max status changes, to avoid pulling remnants of previously purged old data
    AND MIN(Status) < 4        
  )
  --5/5/15: type 'D' union removed - redundant with B           
--UNION           
--SELECT 'D', AROI.AlpSiteID,           
--  AROI.TransDate,           
--  InvoiceDate = Min(AROI.TransDate),          
--  AROI.InvcNum,           
--  Amount =          
--  Sum(CASE WHEN (RecType=-2) THEN [Amt]*-1 ELSE 0 END),           
--  Applied = 0,           
--  Balance =           
--  Sum(CASE WHEN (RecType=-2) THEN [Amt]*-1 ELSE 0 END),            
--  AROI.custID          
--  --mah 01/26/15: add TransID to help identify original transaction for reprint later via Control Center          
--  ,AlpTransID = MAX( CASE WHEN #OpenItems_C.Ident is not null THEN AROI.AlpTransID          
--       ELSE '' END)          
--  ,PmtMethodId = MAX( CASE WHEN #OpenItems_C.Ident is not null THEN AROI.PmtMethodId          
--       ELSE '' END)          
--  ,CheckNum = MAX( CASE WHEN #OpenItems_C.Ident is not null THEN AROI.CheckNum          
--       ELSE '' END)          
            
-- FROM ALP_tblArOpenInvoice_view AROI          
-- INNER JOIN #OpenItems_C  
-- --LEFT OUTER JOIN            
--  ON AROI.InvcNum = #OpenItems_C.InvcNum          
-- WHERE AROI.CustId=@custId          
-- GROUP BY   
-- AROI.custID,          
--    AROI.AlpSiteID,           
--    AROI.TransDate,           
--    AROI.InvcNum  
--  --,           
--  --AROI.Status,            
--  --          
-- HAVING           
--  (          
--  AROI.InvcNum Not Like 'on acc%'           
--  AND          
--  Sum(CASE WHEN RecType=-2 THEN [Amt]*-1 ELSE 0 END)<>0           
--  --AND AROI.Status<>4 
--    --5/5/15: added max status changes, to avoid pulling remnants of previously purged old data
--    AND MIN(Status) < 4         
--  )          
 ORDER BY           
  Min(AROI.TransDate) DESC,           
  AROI.InvcNum   
--select * from #OpenItems           
--select * from #OpenItems_I          
--select * from #OpenItems_C          
--select * from #OpenOnacctItems   
DROP TABLE #OpenItems           
DROP TABLE #OpenItems_I          
DROP TABLE #OpenItems_C          
DROP TABLE #OpenOnacctItems