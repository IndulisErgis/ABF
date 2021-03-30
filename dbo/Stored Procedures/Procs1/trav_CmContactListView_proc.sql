
CREATE PROCEDURE dbo.trav_CmContactListView_proc
AS
BEGIN TRY
SET NOCOUNT ON

--CREATE TABLE #CrmAccessList( ContactId bigint NOT NULL PRIMARY KEY  CLUSTERED ([ContactId]))
----InsertContactAll
--INSERT INTO #CrmAccessList( ContactId ) SELECT DISTINCT Id FROM {0} {1}
----InsertContactAccessSetup
--INSERT INTO #CrmAccessList( ContactId ) SELECT DISTINCT Id FROM {0} WHERE Id IN (SELECT ContactId FROM dbo.tblCmContactAccess WHERE LinkType = 4 AND LinkId = '{1}') {2}
----InsertContactNoAccessSetup
--INSERT INTO #CrmAccessList( ContactId ) SELECT DISTINCT Id FROM {0} WHERE Id NOT IN (SELECT ContactId FROM dbo.tblCmContactAccess WHERE LinkType = 4) {1}

	SELECT c.ID AS ContactID, c.ContactName AS Contact, c.Title, c.FName, c.MName, c.LName, c.[Type], c.[Status]
		, s.Descr AS ContactStatus, c.LinkType, c.LinkID, r.ContactName AS ReportTo,  c.Notes
		, a.Descr AS DefaultDescription, a.Addr1 AS DefaultAddress1, a.Addr2 AS DefaultAddress2
		, a.City AS DefaultCity, a.Region AS DefaultRegion, a.Country AS DefaultCountry, a.PostalCode AS DefaultPostalCode
		, a.[Status] AS DefaultStatus 
	FROM #CrmAccessList t 
		INNER JOIN dbo.tblCmContact c ON t.ContactID = c.ID 
		LEFT JOIN dbo.tblCmContactAddress a ON a.ContactID = c.ID 
		LEFT JOIN dbo.tblCmContactStatus s ON s.ID = c.StatusID 
		LEFT JOIN dbo.tblCmContact r ON c.ReportToID = r.ID 
	
	WHERE ISNULL(a.Sequence, 0) = 0


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmContactListView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmContactListView_proc';

