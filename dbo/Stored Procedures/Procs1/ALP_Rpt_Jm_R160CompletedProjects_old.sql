



CREATE Procedure [dbo].[ALP_Rpt_Jm_R160CompletedProjects_old]-- '2013-11-01'
	(
	@Startdate Datetime ,
	@Enddate Datetime = null
	)

 AS  
 Begin

 select @Enddate= case when @Enddate is null then DATEADD(MM, DATEDIFF(MM, -1, @Startdate), 0) - 1 else  @Enddate End
	

SELECT 
@Enddate as Enddate,
QR160D.SalesRepId, 
QR160D.ProjectId,
--Fixed so Commercial accounts would correctly display name - 6/2/16 - ER
--[SiteName] + (case when [AlpFirstName] is null then '' else ', ' end) + [AlpFirstName] AS Site,
ALP_tblArAlpSite.[SiteName] + (case when ALP_tblArAlpSite.[AlpFirstName] is null then '' else ', '+ ALP_tblArAlpSite.[AlpFirstName] end) AS Site,
  ALP_tblArAlpSite.Addr1, 
  ALP_tblJmSvcTktProject.[Desc], 
  Sum(dbo.[ufxJmSvcTkt_Est_HrsByJob](QR160D.ProjectId,ALP_tblJmSvcTkt.[TicketId])) AS ProjectEstHrs,
  COALESCE((IsNull(Sum(dbo.ufxJmSvcTkt_ActualHrs(ALP_tblJmSvcTkt.[TicketId])),0)-Sum(dbo.[ufxJmSvcTkt_Est_HrsByJob](QR160D.ProjectId,ALP_tblJmSvcTkt.[TicketId]))) / NULLIF(Sum(dbo.[ufxJmSvcTkt_Est_HrsByJob](QR160D.ProjectId,ALP_tblJmSvcTkt.[TicketId])),0), 0)AS HrsDiffPrcnt,
   ALP_tblJmSvcTktProject.AdjHrs,
    round(Sum(IsNull(dbo.ufxJmSvcTkt_HrsByJob(ALP_tblJmSvcTkt.[TicketId]),0)*[FudgeFactorHrs]),2) AS ProjStandardHrs,
	 Sum(IsNull(dbo.ufxJmSvcTkt_ActualHrs(ALP_tblJmSvcTkt.[TicketId]),0)) AS ActualHours,
	  round(Q009.SumOfEstCostParts,0) as SumOfEstCostParts, 
	  round(Q009.ProjPartCost,0) as ProjPartCost,
	  COALESCE((IsNull(round(Q009.ProjPartCost,0),0)-round(Q009.SumOfEstCostParts,0)) / NULLIF(round(Q009.SumOfEstCostParts,0),0), 0)AS MatCostDiffPrcnt,
	   round(min(Q009.[ProjPrice]-Q009.[SumOfEstCostParts]-Q009.[SumOfEstCostLabor]-Q009.[SumOfEstCostMisc]-Q009.[ProjCommCost]),0) AS GPEst,
	    round(min((Q009.[ProjPrice]-Q009.[ProjPartCost]-Q009.[ProjLaborCost]-Q009.[ProjOtherCost]-Q009.[ProjCommCost])),0) AS GPAct,
		round( min((Q009.[ProjPv]+Q009.[ProjPartCost]+Q009.[ProjLaborCost]+Q009.[ProjOtherCost]-Q009.[SumOfEstCostParts]-Q009.[SumOfEstCostLabor]-Q009.[SumOfEstCostMisc])),0) AS GPPVEst, 
	   round(min(Q009.[ProjPv]),0) AS GPPVAct,
	    QR160D.ProjCompleteDate

FROM  ufxALP_R_AR_Jm_R160_D_CompletedProjs(@StartDate,@Enddate) as QR160D 
INNER JOIN (ALP_tblArAlpSite 
				INNER JOIN (ALP_tblJmSvcTkt
								 RIGHT JOIN ALP_tblJmSvcTktProject ON ALP_tblJmSvcTkt.[ProjectId] = ALP_tblJmSvcTktProject.[ProjectId]) 
								  ON ALP_tblArAlpSite.[SiteId] = ALP_tblJmSvcTktProject.[SiteId])
		 ON QR160D.[ProjectId] = ALP_tblJmSvcTktProject.[ProjectId]
		 INNER JOIN ufxALP_R_AR_Jm_Q011_ProjInfo_Q009() as Q009 ON QR160D.[ProjectId] = Q009.[ProjectId] 

GROUP BY QR160D.SalesRepId, 
QR160D.ProjectId, 
ALP_tblArAlpSite.[SiteName] + (case when ALP_tblArAlpSite.[AlpFirstName] is null then '' else ', '+ ALP_tblArAlpSite.[AlpFirstName] end),
ALP_tblArAlpSite.Addr1, ALP_tblJmSvcTktProject.[Desc], 
ALP_tblJmSvcTktProject.AdjHrs, 
Q009.SumOfEstCostParts, 
Q009.ProjPartCost,
 QR160D.ProjCompleteDate
--Removed to include all projects from time period selected which will match new R160T report - 6/7/16 - ER
--HAVING (Sum(dbo.[ufxJmSvcTkt_Est_HrsByJob](QR160D.ProjectId,ALP_tblJmSvcTkt.[TicketId]))<>0 AND Sum(IsNull(dbo.[ufxJmSvcTkt_ActualHrs](ALP_tblJmSvcTkt.[TicketId]),0))<>0)
ORDER BY  QR160D.ProjCompleteDate

End