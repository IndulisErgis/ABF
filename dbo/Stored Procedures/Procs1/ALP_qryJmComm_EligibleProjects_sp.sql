
CREATE Procedure [dbo].[ALP_qryJmComm_EligibleProjects_sp]   
--Determines projects eligible for commission payment  
--mah 3/6/10: modified qualification logic.  
--mah 4/4/10: added more qualifications criteria, looking at entire project status ( per JCP ).  
--     No commissions on a project are eligible until the entire project   
--     has been billed and entirely paid.  CO Connects still have TO and RecSvcpaid criteria  
--MAH 05/03/11: added CustID criteria in checking for paid invoices to the site for recurring services    
--MAH 05/25/11: removed criteria for Projects appearing on the 'All Projects' reports.   
--MAH 01/17/12: added rounding to eliminate precision differences in Project totals 
--mah 03/04/13 - changed to allow 'negative' commissions to go though ( per Accounting dept, 3/2013 ) 
--MAH 04/04/13 - if InvcBalance is < 0 (a credit), then consider it same as 'PAID' status for considering commission payment eligibility  
As    
SET NOCOUNT ON    
--find all projects with unpaid commission amounts     
 /*Populates a temporary table of all jobs eligible for commission payment.*/    
 DELETE FROM ALP_tmpJmComm_EligibleJobs    
 INSERT INTO ALP_tmpJmComm_EligibleJobs     
  (    
  TicketId,ProjectID,SalesRep,CustID,    
  SiteId,InvcNum,CommAmt,    
  CommPaidDate,Status,    
  CommPayNowYn,    
  WorkCodeID,CsConnectYn,TODate,JobCompltDate,    
  JobPrice,InvcStatus, JobCreateDate, RMRAdded    
  )    
  --function returns all projects that have unpaid commissions    
  select ST.TicketId,ST.ProjectID,ST.SalesRepID,ST.CustID,    
  ST.SiteId,ST.InvcNum,ST.CommAmt,    
  ST.CommPaidDate,ST.Status,    
  ST.CommPayNowYn,    
  ST.WorkCodeId,ST.CsConnectYn,ST.TurnOverDate,ST.CompleteDate,    
  dbo.ALP_ufxJmComm_GetSvcJobPrice(ST.TicketID),    
  ' ',ST.CreateDate, ST.RMRAdded    
  from  dbo.ALP_tblJmSvcTkt ST    
  inner join dbo.ALP_ufxJmComm_UnpaidCommProjects() P    
  on ST.ProjectID = P.ProjectID   
  where ST.Status <> 'canceled' and ST.Status <> 'cancelled'   
  order by ST.ProjectID,TicketID    
  
--Get Invoice Amounts and Balance from AR Hist files    
 UPDATE ALP_tmpJmComm_EligibleJobs    
 SET InvcBilledAmt = I.AmtBilled,   
	 InvcDate = I.InvoiceDate,   
     InvcPaidDate = I.InvoiceDate,    
     InvcStatus = I.PaidStatus,
     --InvcStatus = CASE
     --   WHEN I.PaidStatus = 'OPEN' and EJ.InvcBalance <= 0 THEN 'CRED' 
     --   ELSE I.PaidStatus
     --   END,     
     InvcBalance = dbo.ALP_ufxJmComm_CheckInvcBalance(EJ.InvcNum),    
     RecurSvcPaidYn = CASE WHEN (I.RecurAmt > 0 and I.PaidStatus = 'PAID') THEN 1    
     ELSE 0    
     END    
 FROM ALP_tmpJmComm_EligibleJobs EJ    
 INNER JOIN dbo.ALP_ufxJmComm_GetInvoiceDataForEligibleJobs() I    
  ON EJ.InvcNum = I.InvcNum    
 WHERE EJ.InvcNum <> ''    
  
--Check overall Project status.  Determine if project has not been totally billed, totally paid,  
-- and if any jobs have 'Pay Now' forced pay turned on. 
-- MAH 01/17/12 - added rounding to eliminate precision differences  
-- MAH 04/04/13 - if InvcBalance is < 0 (a credit), then consider it same as 'PAID' status, 
--                and assign '0' to ProjectTotPaidYn field 
 CREATE TABLE #ProjectSummary  
  (ProjectID varchar(10),ProjectTotPrice pDec,   
  ProjectTotBilled pDec,ProjectTotPaidYn integer, ProjectCommPayNowYn integer)    
 INSERT INTO #ProjectSummary  
  (ProjectID,ProjectTotPrice,  
  ProjectTotBilled,ProjectTotPaidYn, ProjectCommPayNowYn)    
 SELECT  EJ.ProjectID ,ROUND(SUM(EJ.JobPrice),2),  
  ROUND(SUM(EJ.InvcBilledAmt),2),  
  SUM(CASE WHEN EJ.InvcStatus = 'PAID' THEN 0   
        WHEN EJ.InvcStatus = ' ' THEN 0  
     --WHEN EJ.InvcStatus = 'OPEN' THEN 1 
        WHEN EJ.InvcStatus = 'OPEN' and EJ.InvcBalance > 0 THEN 1
        WHEN EJ.InvcStatus = 'OPEN' and EJ.InvcBalance <= 0 THEN 0     
        ELSE 1 END),    
  SUM(CASE WHEN EJ.CommPayNowYn = 0 THEN 0 ELSE 1 END)   
 FROM ALP_tmpJmComm_EligibleJobs EJ    
 GROUP BY EJ.ProjectID    
  
--MAH 05/25/11: removed criteria for Projects appearing on the 'All Projects' reports.  Commented out the section below.  
----Check Project status.    
---- If project has not been totally billed, or not totally paid, eliminate it from table.    
---- Do NOT eliminate the project if any of the Jobs have "CommPayNowYn" = 1 ( forced pay )     
-- DELETE ALP_tmpJmComm_EligibleJobs FROM ALP_tmpJmComm_EligibleJobs   
-- INNER JOIN #ProjectSummary   
-- ON  ALP_tmpJmComm_EligibleJobs.ProjectID = #ProjectSummary.ProjectID  
-- WHERE (#ProjectSummary.ProjectTotPrice > #ProjectSummary.ProjectTotBilled)   
--  AND #ProjectSummary.ProjectTotPaidYn > 0   
--  AND #ProjectSummary.ProjectCommPayNowYn = 0   
    
    
--Flag invoices that have been paid using Writeoffs or Gifts.   Invoice status of these will be changed from 'PAID' to 'XXXX'    
 UPDATE ALP_tmpJmComm_EligibleJobs    
 SET InvcStatus = CASE WHEN dbo.ALP_ufxJmComm_CheckInvcStatus_FlagWriteOffs (InvcNum) = 1 THEN '****'  ELSE InvcStatus  END   
 FROM ALP_tmpJmComm_EligibleJobs EJ    
 WHERE EJ.InvcStatus = 'PAID'   
   
  
  
--Check the status of any CsConnect jobs. Mark the job as "eligible for commission payment", if the cust/site has been     
--invoiced for any recurring services ( since the date of CsConnect job), and that invoice has been paid.    
CREATE TABLE #SiteInvoices    
 (  SiteID integer,    
  InvcNum varchar(15),       
  InvoiceDate datetime,    
  AmtBilled decimal(12,2),    
  RecurAmt decimal(12,2),    
          PartsLaborAmt decimal(12,2),    
  PaidStatus varchar(4),    
  Balance decimal(12,2))    
 INSERT INTO #SiteInvoices ( SiteID,InvcNum,InvoiceDate,AmtBilled,RecurAmt,    
    PartsLaborAmt,PaidStatus,Balance)    
  SELECT  ALP_tmpJmComm_EligibleJobs.SiteID,    
   tblArHistHeader.InvcNum,       
   InvoiceDate = MIN(tblArHistHeader.InvcDate),    
   AmtBilled = SUM(tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell),    
   RecurAmt = SUM(CASE WHEN AlpServiceType = 0 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell     
    WHEN AlpServiceType >= 4 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell    
    ELSE 0 END),    
           PartsLaborAmt = SUM(CASE WHEN AlpServiceType = 1 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell    
    WHEN AlpServiceType = 2 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell    
    ELSE 0 END),    
   PaidStatus = dbo.ALP_ufxJmComm_CheckInvcStatus(tblArHistHeader.InvcNum),    
   Balance = dbo.ALP_ufxJmComm_CheckInvcBalance(tblArHistHeader.InvcNum)    
  FROM     ALP_tmpJmComm_EligibleJobs  
     INNER JOIN  ALP_tblArHistHeader     
		ON  ALP_tmpJmComm_EligibleJobs.SiteID = ALP_tblArHistHeader.AlpSiteID
		    
     INNER JOIN  tblArHistHeader  
		    ON tblArHistHeader.PostRun = ALP_tblArHistHeader.AlpPostRun     
			AND tblArHistHeader.TransID = ALP_tblArHistHeader.AlpTransID
			AND ALP_tmpJmComm_EligibleJobs.CustID = tblArHistHeader.CustId 
		--ON  ALP_tmpJmComm_EligibleJobs.SiteID = tblArHistHeader.AlpSiteID   
 -- MAH 05/03/11 - added CustiD qualification :  
     
 -- MAH 02/01/10:  
    --AND ALP_tmpJmComm_EligibleJobs.InvcNum = tblArHistHeader.InvcNum    
   INNER JOIN tblArHistDetail     
    ON tblArHistDetail.PostRun = ALP_tblArHistHeader.AlpPostRun     
    AND tblArHistDetail.TransID = ALP_tblArHistHeader.AlpTransID    
   INNER JOIN ALP_tblInItem     
    ON tblArHistDetail.PartId = ALP_tblInItem.AlpItemId    
  WHERE   tblArHistHeader.InvcDate >=  ALP_tmpJmComm_EligibleJobs.JobCreateDate 
		AND tblArHistHeader.CustId =  ALP_tmpJmComm_EligibleJobs.CustID   
		AND (tblArHistDetail.UnitPriceSell <> 0)    
  GROUP BY ALP_tmpJmComm_EligibleJobs.SiteID,tblArHistHeader.InvcNum     
  ORDER BY ALP_tmpJmComm_EligibleJobs.SiteID,tblArHistHeader.InvcNum     
     
--Update CSConnect jobs that have had Recurring billed and paid.     
 UPDATE ALP_tmpJmComm_EligibleJobs    
 SET RecurSvcPaidYn = CASE WHEN (EXISTS (Select SI.InvcNum FROM  #SiteInvoices SI    
      WHERE ALP_tmpJmComm_EligibleJobs.SiteID = SI.SiteID    
      AND SI.RecurAmt > 0    
      AND SI.PaidStatus = 'PAID')    
     ) THEN 1    
    ELSE 0    
    END    
 WHERE CsConnectYn = 1 AND TODate is not null    
 OR CsConnectYn <> 1 AND RMRAdded > 0  
    
    
----Add invoice records for Cust/Site invoices not already included in the project. ( i.e. Invoices    
----generated through AR rather than through the Job Form    
-- CREATE TABLE #ProjectsCustSite(ProjectID varchar(10),CustID varchar(10), SiteID int,StartDate datetime)    
-- INSERT INTO #ProjectsCustSite(ProjectID,CustID,SiteID,StartDate)    
-- SELECT  EJ.ProjectID,EJ.CustID,EJ.SiteID,EJ.StartDate     
-- FROM ALP_tmpJmComm_EligibleJobs EJ    
-- GROUP BY EJ.ProjectID,EJ.CustID,EJ.SiteID,EJ.StartDate    
--select * from  #ProjectsCustSite    
-- INSERT INTO ALP_tmpJmComm_EligibleJobs     
--  (    
--  TicketId,ProjectID,SalesRep,CustID,    
--  SiteId,InvcNum,    
--  InvcBilledAmt,    
--      InvcPaidDate,    
--      InvcStatus,    
--      InvcIncludeRecurAmtYn    
--  )    
--      
--  select 0,P.ProjectID,'',P.CustID,    
--  P.SiteId,    
--  AR.InvcNum,    
--      
--  AR.AmtBilled,    
--      AR.InvoiceDate,    
--      AR.PaidStatus,    
--      InvcIncludeRecurAmtYn = CASE WHEN AR.RecurAmt > 0 Then 1    
--     ELSE 0    
--     END,    
--  from  #ProjectsCustSite P    
--  inner join dbo.ufxJmComm_GetSiteInvoices AR    
--  on   
    
--Flag all records still eligible for commission payment:  
-- Those that have unpaid Commission amount (blank Commission Paid date)  
--  Those with 'PayNow' forced  
-- CO Connect jobs that have been turned over, and also have recurring service paid  
-- Jobs are in Projects that are fully billed and fully paid   
 UPDATE ALP_tmpJmComm_EligibleJobs    
 SET CommToBePaidFlag = 1    
 FROM ALP_tmpJmComm_EligibleJobs EJ    
 INNER JOIN #ProjectSummary   
 ON  EJ.ProjectID = #ProjectSummary.ProjectID 
 --mah 03/04/13 - changed to allow 'negative' commissions to go though ( per Accounting dept, 3/2013 ) 
 --WHERE (CommAmt > 0 AND CommPaidDate is null )  AND
  WHERE (CommAmt <> 0 AND CommPaidDate is null )  AND      
  (    
 (CommPayNowYn = 1)    
  OR   
 ((CommPayNowYn <> 1)  
  AND (#ProjectSummary.ProjectTotPrice <= #ProjectSummary.ProjectTotBilled)   
  AND (#ProjectSummary.ProjectTotPaidYn = 0 )  
  AND ( (CsConnectYn <> 1)   
    OR   
     (CsConnectYn = 1 AND TODate is not null AND RecurSvcPaidYn = 1)   
   )  
 )   
  )   
  
--Cleanup  
DELETE #ProjectSummary
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_qryJmComm_EligibleProjects_sp] TO [JMCommissions]
    AS [dbo];

