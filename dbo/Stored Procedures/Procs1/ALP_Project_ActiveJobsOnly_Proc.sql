CREATE  Procedure ALP_Project_ActiveJobsOnly_Proc(
@Enddate Datetime = null
	)

 AS  
 Begin
 SELECT ProjectId,[Desc],SiteId,SiteName,SvcTktProjectId FROM [ALP_lkpJmSvcTktProject] where ProjectId in(  
select * from [ufxALP_R_AR_Jm_Q004_OpenProjJobsWIP]( @Enddate))
group by ProjectId,[Desc],SiteId,SiteName,SvcTktProjectId
order by ProjectId 
  END