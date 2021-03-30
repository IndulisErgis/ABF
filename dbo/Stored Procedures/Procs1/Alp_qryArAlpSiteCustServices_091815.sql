CREATE PROCEDURE dbo.Alp_qryArAlpSiteCustServices_091815 @Cust varchar(10), @Site varchar(10)          
As          
SET NOCOUNT ON         
  
SELECT  
   MAX([p].[RecBillServPriceId]) AS [RecBillServPriceId], [p].[RecBillServId] into #tempLastPriceRecord  
  FROM [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [p] Inner Join [dbo]. ALP_tblArAlpSiteRecBillServ  as serv On p.RecBillServId =serv.RecBillServId  
  inner join ALP_tblArAlpSiteRecBill as recBill on serv.RecBillId =recBill.RecBillId   
  WHERE (((serv .Status)='Active'OR (serv .Status='New')) AND       
((recBill.SiteId )=@Site) AND ((recBill.CustId)=@Cust))    
  GROUP BY [p].[RecBillServId]  
    
  ALTER TABLE #tempLastPriceRecord add   ServiceEndDate date null;  
    
  UPDATE #tempLastPriceRecord   
 set ServiceEndDate = CASE    
       WHEN  b.EndBillDate   IS NULL THEN NULL   
       ELSE   b.EndBillDate    
       END  
  From   #tempLastPriceRecord a Inner Join  ALP_tblArAlpSiteRecBillServPrice b on a.RecBillServPriceId =b.RecBillServPriceId   
     
     
SELECT ALP_tblArAlpSiteRecBill_view.ItemId, Alp_tblArAlpCycle.Cycle,       
 -- DateAdd(day,-1,[NextBillDate]) AS Bill,      
 --The above Bill column commented and below BilledThruDate value taken from service table       
 -- this is done by ravi and Mah on 07.17.2014      
Bill=  Case When ALP_tblArAlpSiteRecBillServ_view.BilledThruDate IS NULL Then ALP_tblArAlpSiteRecBillServ_view .ServiceStartDate      
else  ALP_tblArAlpSiteRecBillServ_view.BilledThruDate END ,      
 ALP_tblArAlpSiteRecBillServ_view.ServiceStartDate,           
 ALP_tblArAlpSiteRecBillServ_view.InitialTerm, ALP_tblArAlpSiteRecBillServ_view.RenTerm, ALP_tblArAlpSiteRecBillServ_view.ServiceID,           
 [ALP_tblArAlpSiteRecBillServ_view].[ActivePrice] AS Price, [ALP_tblArAlpSiteRecBillServ_view].[ActivePrice]*[Units] AS Ext, ALP_tblArAlpSiteRecBillServ_view.[Desc],           
 ALP_tblArAlpSiteRecBill_view.LocID, ALP_tblArAlpSiteRecBill_view.TaxClass, ALP_tblArAlpSiteRecBill_view.AcctCode, ALP_tblArAlpSiteRecBill_view.GLAcctSales,           
 ALP_tblArAlpSiteRecBill_view.GLAcctCOGS, ALP_tblArAlpSiteRecBill_view.GLAcctInv, ALP_tblArAlpSiteRecBill_view.CatId, ALP_tblArAlpSiteRecBillServ_view.ActiveCost,           
 ALP_tblArAlpSiteRecBillServ_view.RecBillServId, ALP_tblArAlpSiteRecBill_view.MailSiteYN, ALP_tblArAlpSiteRecBill_view.CustPONum, ALP_tblArAlpSiteRecBill_view.CustPODate,           
 Alp_tblArAlpCycle.Units, ALP_tblArAlpSiteRecBill_view.RecBillId, ALP_tblArAlpSiteRecBill_view.[Desc] AS EntryDesc,ALP_tblArAlpSiteSys .SysId,ALP_tblArAlpSiteSys.SysDesc           
 , #tempLastPriceRecord. ServiceEndDate   
FROM (ALP_tblArAlpSiteRecBill_view  INNER JOIN Alp_tblArAlpCycle ON ALP_tblArAlpSiteRecBill_view.BillCycleId = Alp_tblArAlpCycle.CycleId)       
INNER JOIN ALP_tblArAlpSiteRecBillServ_view ON ALP_tblArAlpSiteRecBill_view.RecBillId = ALP_tblArAlpSiteRecBillServ_view.RecBillId   
INNER JOIN #tempLastPriceRecord  ON       #tempLastPriceRecord .RecBillServId =ALP_tblArAlpSiteRecBillServ_view.RecBillServId   
LEFT OUTER JOIN ALP_tblArAlpSiteSys  on ALP_tblArAlpSiteRecBillServ_view.SysId =ALP_tblArAlpSiteSys .SysId     
WHERE (((ALP_tblArAlpSiteRecBillServ_view .Status)='Active'OR (ALP_tblArAlpSiteRecBillServ_view .Status='New')) AND       
((ALP_tblArAlpSiteRecBill_view.SiteId)=@Site) AND ((ALP_tblArAlpSiteRecBill_view.CustId)=@Cust))          
ORDER BY DateAdd(day,-1,[NextBillDate]), ALP_tblArAlpSiteRecBill_view.ItemId, ALP_tblArAlpSiteRecBillServ_view.ServiceID;    
  
  
drop table #tempLastPriceRecord