
CREATE PROCEDURE dbo.trav_CmContactList_proc
@ViewAllAddresses bit = 1, 
@ViewContactRelations bit = 1, 
@ViewNotes bit = 1

AS
BEGIN TRY
	SET NOCOUNT ON

	-- Contact resultset
	SELECT c.ID AS ContactID, c.ContactName AS Contact, c.Title, c.FName AS FirstName, c.MName AS MiddleName
		, c.LName AS LastName, c.[Type], c.[Status]
		, s.Descr AS ContactStatus, c.LinkType, c.LinkID, r.ContactName AS ReportTo, [Image], ImageURL
		, CASE WHEN @ViewNotes <> 0 THEN c.Notes ELSE NULL END AS Notes
		, a.Descr AS DefaultDescription, a.Addr1 AS DefaultAddress1, a.Addr2 AS DefaultAddress2
		, a.City AS DefaultCity, a.Region AS DefaultRegion, a.Country AS DefaultCountry, a.PostalCode AS DefaultPostalCode
		, a.[Status] AS DefaultStatus 
	FROM #CrmAccessList t 
		INNER JOIN dbo.tblCmContact c ON t.ContactID = c.ID 
		LEFT JOIN dbo.tblCmContactAddress a ON a.ContactID = c.ID 
		LEFT JOIN dbo.tblCmContactStatus s ON s.ID = c.StatusID 
		LEFT JOIN dbo.tblCmContact r ON c.ReportToID = r.ID 
		LEFT JOIN dbo.tblCmImage i ON i.ContactID = c.ID 
	WHERE ISNULL(a.Sequence, 0) = 0
	
	-- Address resultset
	SELECT t.ContactID, Sequence, Descr AS Description
		, Addr1 AS Address1, Addr2 AS Address2, City, Region, Country, PostalCode, [Status] 
	FROM #CrmAccessList t 
		INNER JOIN dbo.tblCmContactAddress a ON t.ContactID = a.ContactID
	WHERE @ViewAllAddresses <> 0 AND a.Sequence <> 0

	-- Contact Method resultset
	SELECT m.ContactID, mt.[Type], mt.Descr AS ContactMethod, m.[Status], m.Value, a.Country 
	FROM #CrmAccessList t 
		LEFT JOIN dbo.tblCmContactAddress a ON a.ContactID = t.ContactID 
		INNER JOIN dbo.tblCmContactMethod m ON t.ContactID = m.ContactID 
		INNER JOIN dbo.tblCmContactMethodType mt ON mt.ID = m.TypeID 
	WHERE a.Sequence = 0

	-- Members Of resultset
	SELECT r.RelationID, c.ContactName AS MemberOfContact 
	FROM #CrmAccessList t 
		INNER JOIN dbo.tblCmContactRelation r ON t.ContactId = r.RelationID
		INNER JOIN dbo.tblCmContact c ON r.ContactID = c.ID
	WHERE @ViewContactRelations <> 0 AND c.Status <> 2

	-- Members resultset
	SELECT r.ContactID, c.ContactName AS MemberContact  
	FROM #CrmAccessList t 
		INNER JOIN dbo.tblCmContactRelation r ON t.ContactId = r.ContactID
		INNER JOIN dbo.tblCmContact c ON r.RelationID = c.ID
	WHERE @ViewContactRelations <> 0 AND c.Status <> 2

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmContactList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmContactList_proc';

