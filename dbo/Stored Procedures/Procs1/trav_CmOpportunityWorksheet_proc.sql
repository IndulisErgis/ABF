
CREATE PROCEDURE dbo.trav_CmOpportunityWorksheet_proc
@ViewContactMethods tinyint = 1, 
@ViewNotes bit = 1

AS
BEGIN TRY
	SET NOCOUNT ON

	-- Opportunity Report/Worksheet resultset
	SELECT o.ID AS OpportunityID, c.ID AS ContactID, CONVERT(nvarchar(8), o.OpenDate,112) AS OpenDateSort
		, c.ContactName AS Contact, a.Addr1 AS Address1, a.Addr2 AS Address2, a.City, a.Region
		, a.Country, a.PostalCode, o.OpenDate, o.Descr AS [Description], s.Descr AS [Status]
		, p.Descr AS Campaign, o.ReferBy AS ReferredBy, o.ReferDate, c2.ContactName AS ReferredTo
		, o.CloseDate, b.Descr AS Probability, r.Descr AS Resolution, o.Value, o.TargetDate
		, CASE WHEN @ViewNotes <> 0 THEN o.Notes ELSE NULL END AS Notes 
	FROM #OpportunityList t 
		INNER JOIN dbo.tblCmOpportunity o ON t.OpportunityID = o.ID 
		LEFT JOIN dbo.tblCmOppStatus s ON o.StatusID = s.ID 
		LEFT JOIN dbo.tblCmContact c ON o.ContactID = c.ID 
		LEFT JOIN dbo.tblCmContactAddress a ON c.ID = a.ContactID 
		LEFT JOIN dbo.tblCmContact c2 ON o.ReferID = c2.ID 
		LEFT JOIN dbo.tblCmCampaign p ON o.CampaignID = p.ID 
		LEFT JOIN dbo.tblCmOppProbCode b ON o.ProbCodeID = b.ID 
		LEFT JOIN dbo.tblCmOppResCode r ON o.ResCodeID = r.ID 
	WHERE ISNULL(a.Sequence, 0) = 0

	-- Contact Methods resultset
	SELECT o.ContactID, mt.[Type], mt.Descr AS [Description], m.Value, h.Country 
	FROM #OpportunityList t 
		INNER JOIN dbo.tblCmOpportunity o ON t.OpportunityID = o.ID 
		LEFT JOIN dbo.tblCmContact c ON o.ContactID = c.ID 
		LEFT JOIN dbo.tblCmContactAddress h ON h.ContactID = c.ID 
		INNER JOIN dbo.tblCmContactMethod m ON c.ID = m.ContactID 
		INNER JOIN dbo.tblCmContactMethodType mt ON mt.ID = m.TypeID 
	WHERE @ViewContactMethods <> 0 AND mt.[Type] IN (0, 2) AND ISNULL(h.Sequence, 0) = 0 
	GROUP BY o.ContactID, mt.[Type], mt.Descr, m.Value, h.Country

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmOpportunityWorksheet_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmOpportunityWorksheet_proc';

