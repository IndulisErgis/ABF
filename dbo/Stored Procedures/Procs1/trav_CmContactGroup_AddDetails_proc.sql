
CREATE PROCEDURE dbo.trav_CmContactGroup_AddDetails_proc
@ContactGroupId BigInt,
@ContactGroupDtlId Bigint
AS
BEGIN TRY
	DECLARE @GroupType tinyint
	SET NOCOUNT ON
	
	SELECT @GroupType = [Type] FROM dbo.tblCmContactGroup WHERE ID = @ContactGroupId
	
	CREATE TABLE #tmpCmContactGroupDtl(ID bigint NOT NULL IDENTITY(1,1), ContactID bigint NOT NULL, 
		ContactMethodID bigint NOT NULL, [Type] tinyint NOT NULL)
	
	--Address when Group Type is Address or All
	INSERT INTO #tmpCmContactGroupDtl(ContactID, ContactMethodID, [Type])
	SELECT c.ID, a.ID, 3
	FROM dbo.tblCmContact c INNER JOIN #CrmAccessList t ON c.ID = t.ContactId
		INNER JOIN dbo.tblCmContactAddress a ON c.ID = a.ContactID 
		LEFT JOIN (SELECT ContactMethodID FROM dbo.tblCmContactGroupDtl WHERE ContactGroupID = @ContactGroupId AND [Type] = 3) d ON a.ID = d.ContactMethodID
	WHERE @GroupType IN (3, 4) AND d.ContactMethodID IS NULL AND a.Sequence = 0 AND a.[Status] = 0 --Not exist and Default address with Allowed status
	
	--Contact Methods when Group Type is Phone/Fax/Email or All
	INSERT INTO #tmpCmContactGroupDtl(ContactID, ContactMethodID, [Type])
	SELECT c.ID, m.ID, p.[Type]
	FROM dbo.tblCmContact c INNER JOIN #CrmAccessList t ON c.ID = t.ContactId 
		INNER JOIN dbo.tblCmContactMethod m ON c.ID = m.ContactID 
		INNER JOIN dbo.tblCmContactMethodType p ON m.TypeID = p.ID 
		LEFT JOIN (SELECT ContactMethodID FROM dbo.tblCmContactGroupDtl WHERE ContactGroupID = @ContactGroupId AND [Type] < 3) d ON m.ID = d.ContactMethodID
	WHERE (@GroupType = 4 OR p.[Type] = @GroupType) AND p.[Type] < 3 AND d.ContactMethodID IS NULL AND m.[Status] = 0 --Not exist and contact methods with Allowed status
	
	INSERT INTO dbo.tblCmContactGroupDtl (ID, ContactGroupID, [Type], ContactID, ContactMethodID, SelectYn)
	SELECT @ContactGroupDtlId + ID, @ContactGroupId, [Type], ContactID, ContactMethodID, 1
	FROM #tmpCmContactGroupDtl

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmContactGroup_AddDetails_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmContactGroup_AddDetails_proc';

