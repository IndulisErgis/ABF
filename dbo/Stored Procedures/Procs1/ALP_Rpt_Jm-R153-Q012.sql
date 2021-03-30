





CREATE PROCEDURE [dbo].[ALP_Rpt_Jm-R153-Q012] --'2013-11-01',null,1
	(
	@Startdate DATETIME ,
	@Enddate DATETIME = NULL,
	@Branch VARCHAR(255)='<ALL>',
		@ActiveSubdivision BIT=NULL
	)

 AS  
 BEGIN
 SELECT @Enddate= CASE WHEN @Enddate IS NULL THEN DATEADD(MM, DATEDIFF(MM, -1, @Startdate), 0) - 1 ELSE  @Enddate END
	
SELECT @Enddate AS Enddate,
		Q1209.[Desc],
		Q1209.Lead, 
		Q1209.SiteId, 
		Q1209.Site, 
		Q1209.Address, 
		SUM(Q1209.ProjRmr) AS SumOfProjRmr, 
		SUM(Q1209.ProjPrice) AS SumOfProjPrice, 
		SUM(ISNULL(Q1209.ProjPv,0)) AS SumOfProjPv, 
		SUM(Q1209.Connects ) AS SumOfConnects,
		MIN(Q1209.InactiveYN) AS InactiveYN

FROM [dbo].[ufxALP_R_AR_Jm-Q012-ProjInfoByDateRange-Q009](@Startdate,@Enddate,@Branch,@ActiveSubdivision)AS Q1209
GROUP BY Q1209.Lead, Q1209.[Desc], 
Q1209.SiteId, Q1209.Site, 
Q1209.Address
HAVING Q1209.[Desc] IS NOT NULL

END