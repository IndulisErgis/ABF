
CREATE PROCEDURE dbo.trav_CmOpportunityView_proc

--PET:http://webfront:801/view.php?id=238987

AS
BEGIN TRY
	SET NOCOUNT ON
	

--drop table #OpportunityList
--drop table #CrmAccessList
--CREATE TABLE #OpportunityList( OpportunityId bigint NOT NULL PRIMARY KEY  CLUSTERED ([OpportunityId]))
--CREATE TABLE #CrmAccessList( ContactId bigint NOT NULL PRIMARY KEY  CLUSTERED ([ContactId]))
--	INSERT INTO #CrmAccessList( ContactId )
--	SELECT DISTINCT Id 
--	FROM (
--	SELECT c.Id, c.ContactName, c.Title, c.FName, c.MName, c.LName, c.[Type], c.[Status], 
--	c.LinkID, r.ContactName AS ReportTo, a.Addr1, a.Addr2, a.City, a.Region, a.Country, a.PostalCode, m.Value,
--	m.TypeId, s.Descr FROM dbo.tblCmContact c 
--	 LEFT JOIN (SELECT ContactID, Addr1, Addr2, City, Region, Country, PostalCode 
--	FROM dbo.tblCmContactAddress WHERE Sequence = 0) a ON c.ID = a.ContactID 
--	 LEFT JOIN dbo.tblCmContactMethod m ON c.ID = m.ContactID 
--	 LEFT JOIN dbo.tblCmContactMethodType t ON m.TypeID = t.ID  
--	 LEFT JOIN dbo.tblCmContactStatus s ON c.StatusID = s.ID 
--	 LEFT JOIN dbo.tblCmContact r ON c.ReportToID = r.ID  WHERE c.[Status] <> 2
--	 ) c


--INSERT INTO #OpportunityList(OpportunityId)
--SELECT ID FROM (
--SELECT o.ID, o.ContactID, o.StatusID, o.Descr, o.OpenDate, o.CampaignID, o.ReferBy, o.ReferDate, 
--	a.ContactName AS ReferTo, o.Value, o.ProbCodeID, o.ResCodeID, o.TargetDate, o.CloseDate, o.UserID,  
--	o.[Status], c.ContactName, m.Descr AS Campaign
--FROM dbo.tblCmOpportunity o LEFT JOIN dbo.tblCmContact c ON o.ContactID = c.ID 
--	LEFT JOIN dbo.tblCmContact a ON o.ReferID = a.ID
--	LEFT JOIN dbo.tblCmCampaign m ON o.CampaignID = m.ID ) t
--WHERE (ContactID IS NULL OR ContactID IN (SELECT ContactId FROM #CrmAccessList)) AND 
--	[Status] <> 1 

	

	
SELECT  1 as  OpportCount, c.ContactName as Contact, o.UserID, datepart(yyyy,o.TargetDate) [YearExpected], datepart(mm,o.TargetDate) Period, o.Descr as Opportunity, s.Descr as Status, o.[Value], 
		b.Descr as Probability, b.ProbPct as Pct, 
		right('0'+cast(datepart(mm,o.TargetDate) as nvarchar(2)),2)+'/'+ right('0'+cast(datepart(dd,o.TargetDate) as nvarchar(2)),2) + '/'+ datename(yy,o.targetdate) as TargetDate,
		right('0'+cast(datepart(mm,o.OpenDate) as nvarchar(2)),2)+'/'+ right('0'+cast(datepart(dd,o.OpenDate) as nvarchar(2)),2) + '/'+ datename(yy,o.OpenDate) as OpenDate,
		right('0'+cast(datepart(mm,o.ReferDate) as nvarchar(2)),2)+'/'+ right('0'+cast(datepart(dd,o.ReferDate) as nvarchar(2)),2) + '/'+ datename(yy,o.ReferDate) as ReferDate,
		right('0'+cast(datepart(mm,o.TargetDate) as nvarchar(2)),2)+'/'+ datename(yy,o.targetdate) as Expected,
		right('0'+cast(datepart(mm,o.OpenDate) as nvarchar(2)),2)+'/'+ datename(yy,o.OpenDate) as [Open],datepart(yyyy,o.OpenDate) [YearOpen], 
		(o.[value]*b.ProbPct/100) as WeightedValue, o.CampaignID, o.ReferBy, a.ContactName AS ReferTo, m.Descr AS Campaign, r.Descr as Resolution
FROM        
	#OpportunityList t 
	INNER JOIN
	dbo.tblCMOpportunity o ON t.OpportunityID = o.ID 
	LEFT JOIN
    dbo.tblCMOppStatus s ON o.StatusID = s.ID  LEFT  JOIN
    dbo.tblCMContact c ON o.ContactID = c.ID LEFT  JOIN
    dbo.tblCmContact a ON o.ReferID = a.ID   LEFT JOIN 
    dbo.tblCMOppProbCode b ON o.ProbCodeID = b.ID LEFT JOIN
    dbo.tblCmOppResCode r on o.ResCodeID = r.ID LEFT JOIN
    dbo.tblCmCampaign m ON o.CampaignID = m.ID 
where o.closedate is null
order by o.targetdate



END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmOpportunityView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmOpportunityView_proc';

