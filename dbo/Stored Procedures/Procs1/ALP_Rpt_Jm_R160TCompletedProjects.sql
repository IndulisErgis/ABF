
CREATE Procedure [dbo].[ALP_Rpt_Jm_R160TCompletedProjects]
	(
	@Startdate Datetime ,
	@Enddate Datetime = null
	)

 AS  
 Begin

 select @Enddate= case when @Enddate is null then DATEADD(MM, DATEDIFF(MM, -1, @Startdate), 0) - 1 else  @Enddate End
	

SELECT
@Enddate as Enddate,
IsNull(ALP_tblJmTech.Tech,'n/a') AS Tech,  
CP.ProjectId,
 ALP_tblArAlpSite.[SiteName] + (case when ALP_tblArAlpSite.[AlpFirstName] is null then '' else ', '+ ALP_tblArAlpSite.[AlpFirstName] end) AS Site,
  --3/14/2018 - ER - added Summing functions to group by Tech
  Sum(ALP_tblJmSvcTkt.EstHrs_FromQM) AS EstHrs,
  Sum(ALP_tblJmSvcTktProject.AdjHrs) AS AdjHrs,
  Sum(COALESCE((IsNull(dbo.ufxJmSvcTkt_ActualHrs(ALP_tblJmSvcTkt.[TicketId]),0)-ALP_tblJmSvcTkt.EstHrs_FromQM) / NULLIF(ALP_tblJmSvcTkt.EstHrs_FromQM,0), 0))AS HrsDiffPrcnt,
    Sum(IsNull(dbo.ufxJmSvcTkt_HrsByJob(ALP_tblJmSvcTkt.[TicketId])*[FudgeFactorHrs],0)) AS StandardHrs,
	Sum(IsNull(dbo.ufxJmSvcTkt_ActualHrs(ALP_tblJmSvcTkt.[TicketId]),0)) AS ActualHours,
	  Sum(round(Q009.EstCostParts,0)) as EstCostParts,
	  --added to report - 06/30/16 - ER 
	  Sum(ROUND(Q009.OtherCost,0)) as OtherCost,
	  Sum(round(IsNull(Q009.PartCost,0),0)) as PartCost,
	  Sum(COALESCE((IsNull(round(Q009.PartCost,0),0)-round(Q009.EstCostParts,0)) / NULLIF(round(Q009.EstCostParts,0),0), 0))AS MatCostDiffPrcnt,
	   Sum(round(Q009.[JobPrice]-Q009.[EstCostParts]-Q009.[EstCostLabor]-Q009.[EstCostMisc]-Q009.[CommCost],0)) AS GPEst,
	    Sum(round((Q009.[JobPrice]-IsNull(Q009.[PartCost],0)-Q009.[LaborCost]-Q009.[OtherCost]-Q009.[CommCost]),0)) AS GPAct,
		Sum(round((Q009.[JobPv]+IsNull(Q009.[PartCost],0)+Q009.[LaborCost]+Q009.[OtherCost]-Q009.[EstCostParts]-Q009.[EstCostLabor]-Q009.[EstCostMisc]),0)) AS GPPVEst, 
	   Sum(round(Q009.[JobPv],0)) AS GPPVAct,
	    CP.ProjCompleteDate

--Replaced function that determined completed projects - 06/30/2016 - ER
--FROM  ufxALP_R_AR_Jm_R160_D_CompletedProjs(@StartDate,@Enddate) as QR160D 
FROM [dbo].[ufxALP_R_AR_Jm_Q010b_CompletedProjIds_Q004c](@EndDate) CP 
		INNER JOIN (ALP_tblArAlpSite 
			INNER JOIN (ALP_tblJmSvcTkt
				RIGHT JOIN ALP_tblJmSvcTktProject 
			ON ALP_tblJmSvcTkt.[ProjectId] = ALP_tblJmSvcTktProject.[ProjectId]) 
		ON ALP_tblArAlpSite.[SiteId] = ALP_tblJmSvcTktProject.[SiteId])
				ON CP.[ProjectId] = ALP_tblJmSvcTktProject.[ProjectId]
					INNER JOIN ufxALP_R_AR_Jm_Q009_JobInfo_Q005_Q008('<ALL>','<ALL>') as Q009 
					ON ALP_tblJmSvcTkt.TicketId = Q009.TicketId
						LEFT JOIN ALP_tblJmTech
						ON ALP_tblJmSvcTkt.LeadTechId = ALP_tblJmTech.TechId 

--3/14/2018 - ER - Added Group by section to roll up by tech/project						
GROUP BY IsNull(ALP_tblJmTech.Tech,'n/a'), 
CP.ProjectId, 
ALP_tblArAlpSite.[SiteName] + (case when ALP_tblArAlpSite.[AlpFirstName] is null then '' else ', '+ ALP_tblArAlpSite.[AlpFirstName] end),
ALP_tblArAlpSite.Addr1, ALP_tblJmSvcTktProject.[Desc], 
ALP_tblJmSvcTktProject.AdjHrs, 
 CP.ProjCompleteDate
						
HAVING ((CP.ProjCompleteDate >= @StartDate)  And (CP.ProjCompleteDate <= @EndDate))					
ORDER BY  CP.ProjCompleteDate


End