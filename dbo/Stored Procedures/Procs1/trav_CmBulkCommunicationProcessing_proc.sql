
CREATE PROCEDURE dbo.trav_CmBulkCommunicationProcessing_proc
@BulkCommType smallint, --1 Email,2 Fax,4 Print
@ContactGroupId BigInt
AS
BEGIN TRY
	SET NOCOUNT ON
	
    IF(@ContactGroupId IS NOT NULL) -- When Contact Group is provided
    BEGIN
       	IF(@BulkCommType in (1,2)) -- Email or Fax
		BEGIN              
			SELECT  Distinct c.ID,c.ContactName,m.Value,c.Title,c.FName,c.LName,c.MName,
					   a.Addr1,a.Addr2,a.City,a.Region,a.Country,a.PostalCode
			FROM dbo.tblCmContactGroup g 
				INNER JOIN dbo.tblCmContactGroupDtl gd ON g.ID = @ContactGroupId AND g.ID = gd.ContactGroupID AND gd.SelectYn = 1 
																	AND gd.[Type] = CASE WHEN @BulkCommType = 1 THEN 2 ELSE 1 END -- Email or Fax
				INNER JOIN dbo.tblCmContact c ON gd.ContactID = c.ID AND C.Status <> 2 
				INNER JOIN dbo.tblCmContactMethod m  ON gd.ContactMethodID = m.ID AND  c.ID = m.ContactID AND m.Status = 0 
				INNER JOIN dbo.tblCmContactMethodType mt ON m.TypeID = mt.ID AND mt.Type = CASE WHEN @BulkCommType = 1 THEN 2 ELSE 1 END
				LEFT OUTER JOIN dbo.tblCmContactAddress a ON c.ID = a.ContactID AND a.Sequence = 0 -- Default Address
			ORDER BY c.ContactName,m.Value
        END
       	ELSE IF (@BulkCommType = 4) -- Print
		BEGIN                          
			SELECT c.ID,c.ContactName,c.Title,c.FName,c.LName,c.MName,
					   a.Addr1,a.Addr2,a.City,a.Region,a.Country,a.PostalCode
			FROM dbo.tblCmContactGroup g 
				INNER JOIN dbo.tblCmContactGroupDtl gd ON g.ID = @ContactGroupId AND g.ID = gd.ContactGroupID AND gd.SelectYn = 1 AND gd.[Type] = 3 -- Print
				INNER JOIN dbo.tblCmContact c ON gd.ContactID = c.ID AND c.Status <> 2 
				INNER JOIN dbo.tblCmContactAddress a ON gd.ContactMethodID = a.ID AND c.ID = a.ContactID AND a.Status = 0 AND a.Sequence = 0 -- Default Addresss
			ORDER BY  c.ContactName
		END 
	END
	ELSE-- When Contact Group is not provided
	BEGIN
		IF(@BulkCommType in (1,2)) -- Email or Fax
		BEGIN                     
			--Select Distinct record - Email or Fax can have duplicates  
			SELECT Distinct c.ID,c.ContactName,m.Value,c.Title,c.FName,c.LName,c.MName,
					   a.Addr1,a.Addr2,a.City,a.Region,a.Country,a.PostalCode
			FROM #CrmAccessList t 
				INNER JOIN dbo.tblCmContact c ON t.ContactID = c.ID AND C.Status <> 2 
				INNER JOIN dbo.tblCmContactMethod m  ON c.ID = m.ContactID AND m.Status = 0 
				INNER JOIN dbo.tblCmContactMethodType mt ON m.TypeID = mt.ID AND mt.Type = CASE WHEN @BulkCommType = 1 THEN 2 ELSE 1 END
				LEFT OUTER JOIN dbo.tblCmContactAddress a ON c.ID = a.ContactID AND a.Sequence = 0 -- Default Address
			ORDER BY c.ContactName,m.Value
		END
		ELSE IF (@BulkCommType = 4) -- Print
		BEGIN
			SELECT c.ID,c.ContactName,c.Title,c.FName,c.LName,c.MName,
					   a.Addr1,a.Addr2,a.City,a.Region,a.Country,a.PostalCode	 	 
			FROM #CrmAccessList t 
				INNER JOIN dbo.tblCmContact c ON t.ContactID = c.ID AND c.Status <> 2 
				INNER JOIN dbo.tblCmContactAddress a ON c.ID = a.ContactID AND a.Status = 0 AND a.Sequence = 0 -- Default Addresss
			ORDER BY  c.ContactName
		END
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmBulkCommunicationProcessing_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmBulkCommunicationProcessing_proc';

