
CREATE PROCEDURE dbo.trav_CmContactGroup_ValidateDetails_proc
@ContactGroupId BigInt
AS
BEGIN TRY

	SET NOCOUNT ON
	
	UPDATE dbo.tblCmContactGroupDtl 
		SET SelectYn = 0
	FROM dbo.tblCmContactGroupDtl INNER JOIN dbo.tblCmContactGroup g ON dbo.tblCmContactGroupDtl.ContactGroupID = g.ID 
		LEFT JOIN dbo.tblCMContact c ON dbo.tblCmContactGroupDtl.ContactID = c.ID 
		LEFT JOIN dbo.tblCmContactAddress a ON dbo.tblCmContactGroupDtl.ContactMethodID = a.ID
	WHERE g.ID = @ContactGroupId AND dbo.tblCmContactGroupDtl.[Type] = 3 AND SelectYn = 1 AND ((c.ID IS NULL OR c.[Status] = 2) OR --invalid contact
		(a.ID IS NULL OR a.Sequence != 0 OR a.[Status] = 1)) --invalid address or not allowed

	UPDATE dbo.tblCmContactGroupDtl 
		SET SelectYn = 0
	FROM dbo.tblCmContactGroupDtl INNER JOIN dbo.tblCmContactGroup g ON dbo.tblCmContactGroupDtl.ContactGroupID = g.ID 
		LEFT JOIN dbo.tblCMContact c ON dbo.tblCmContactGroupDtl.ContactID = c.ID 
		LEFT JOIN dbo.tblCmContactMethod m ON dbo.tblCmContactGroupDtl.ContactMethodID = m.ID
	WHERE g.ID = @ContactGroupId AND dbo.tblCmContactGroupDtl.[Type] < 3 AND SelectYn = 1 AND ((c.ID IS NULL OR c.[Status] = 2) OR --invalid contact
		(m.ID IS NULL OR m.[Status] = 1)) --invalid contact method or not allowed
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmContactGroup_ValidateDetails_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmContactGroup_ValidateDetails_proc';

