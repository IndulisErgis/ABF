








CREATE FUNCTION  [dbo].[ufxALP_R_AR_Jm-Q012-ProjInfoByDateRange-Q009]
(
	@Startdate DATETIME ,
	@Enddate DATETIME,
		@Branch VARCHAR(255)='<ALL>',
		@ActiveSubdivision BIT=NULL)

 
RETURNS TABLE 
AS
RETURN 
(

SELECT  SVT.ProjectId, SVT.[Desc] AS ProjDesc, AP.Promo, 
LS.LeadSource, MC.MarketCode,
 --max(SVT.EstMatCost), max(SVT.EstLabCost), max(SVT.EstLabHrs), 
SVT.SiteId, Q958.Site,MIN(Q958.OrderDate)  AS OrderDate, Q958.Lead,
 Q958.Address, Q958.[Desc],MIN((Q958.InactiveYN*1)) AS InactiveYN, MIN(Q958.OrderDate) AS ProjOrderDate, 
 MAX(Q958.CompleteDate) AS ProjCmpltdDate, MAX(Q958.CloseDate) AS ProjCloseDate,
  MIN(Q958.SysType) AS FirstOfSysType, MIN(Q958.SalesRepID) AS FirstOfSalesRepID, 
  MIN(Q958.Branch) AS FirstOfBranch, MIN(Q958.Division) AS FirstOfDivision,
   MIN(Q958.Dept) AS FirstOfDept, 
   SUM(([CsConnectYn]*-1)) AS Connects, 
   SUM(ISNULL(Q958.JobPrice,0)) AS ProjPrice, 
   SUM(ISNULL(Q958.PartCost,0)) AS ProjPartCost, 
   SUM(ISNULL(Q958.OtherCost,0)) AS ProjOtherCost,
    SUM(ISNULL(Q958.LaborCost,0)) AS ProjLaborCost,
    SUM(ISNULL(Q958.CommCost,0)) AS ProjCommCost, 
    SUM(ISNULL(Q958.JobCost,0)) AS ProjCost, 
    SUM(ISNULL(Q958.JobPV,0)) AS ProjPv, 
    SUM(ISNULL(Q958.CommAmt,0)) AS ProjComm,
    SUM(ISNULL(Q958.RMRAdded,0)) AS ProjRmr, 
    SUM(ISNULL(Q958.RmrExpense,0)) AS ProjRmrExp
FROM dbo.ufxALP_R_AR_Jm_Q009_JobInfo_Q005_Q008 (@Branch,'<ALL>')AS Q958 
INNER JOIN   ALP_tblJmSvcTktProject AS SVT  
LEFT JOIN ALP_tblArAlpPromotion AP ON SVT.[PromoId] = AP.[PromoId]
 LEFT JOIN ALP_tblArAlpLeadSource LS ON SVT.[LeadSourceId] = LS.[LeadSourceId]
  ON Q958.[ProjectId] = SVT.[ProjectId] 
 LEFT JOIN ALP_tblJmMarketCode MC ON SVT.[MarketCodeId] = MC.[MarketCodeId]
WHERE Q958.OrderDate BETWEEN @Startdate AND @EndDate  AND  CASE WHEN @ActiveSubdivision IS NULL THEN 1 ELSE Q958.InactiveYN END!=CASE WHEN @ActiveSubdivision IS NULL THEN 0 ELSE @ActiveSubdivision END
GROUP BY SVT.ProjectId, SVT.[Desc],
 AP.Promo, LS.LeadSource, MC.MarketCode, 
 SVT.SiteId, Q958.Site, Q958.Address, Q958.Lead, Q958.[Desc]
 --,SVT.EstMatCost, SVT.EstLabCost, SVT.EstLabHrs 
 
)