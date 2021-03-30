
CREATE PROCEDURE dbo.trav_CmSynchronizeContact_Write_proc 
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ServerTime datetime, @CurrentUser nvarchar(25), @Id bigint

	--Retrieve global values
	SELECT @ServerTime = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'ServerTime'
	SELECT @CurrentUser = Cast([Value] AS nvarchar(25)) FROM #GlobalValues WHERE [Key] = 'CurrentUser'
	SELECT @Id = Cast([Value] AS bigint) FROM #GlobalValues WHERE [Key] = 'Id'
	
	--LinkType: 0;None;1;Customer;2;Vendor;3;Employee;4;SalesRep
	--UpdateDir: 0;Contact;1;Link;2;Skip
	IF @ServerTime IS NULL OR @CurrentUser IS NULL OR @Id IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	UPDATE dbo.tblCmContact SET ContactName = CASE WHEN t.LinkType = 3 THEN dbo.tblCmContact.ContactName ELSE t.LinkName END,
		FName = CASE WHEN t.LinkType = 3 THEN t.LinkFirstName ELSE FName END,
		LName = CASE WHEN t.LinkType = 3 THEN t.LinkLastName ELSE LName END,
		LastUpdated = @ServerTime, LastUpdatedBy = @CurrentUser
	FROM dbo.tblCmContact INNER JOIN #Synchronize t ON dbo.tblCmContact.ID = t.ContactId
	WHERE dbo.tblCmContact.[Status] <> 2 AND t.UpdateDir = 0
	
	UPDATE dbo.tblCmContactAddress 
		SET Addr1 = t.LinkAddr1, Addr2 = t.LinkAddr2, City = t.LinkCity, Region = t.LinkRegion, Country = t.LinkCountry, PostalCode = t.LinkPostalCode
	FROM dbo.tblCmContactAddress INNER JOIN dbo.tblCmContact c ON dbo.tblCmContactAddress.ContactID = c.ID 
		INNER JOIN #Synchronize t ON c.ID = t.ContactId
	WHERE c.[Status] <> 2 AND t.UpdateDir = 0 AND dbo.tblCmContactAddress.Sequence = 0
	
	INSERT INTO dbo.tblCmContactAddress (ID, ContactID, Sequence, Addr1, Addr2, City, Region, Country, PostalCode, [Status], LastUpdated, LastUpdatedBy)
	SELECT  @Id + t.ContactId, t.ContactId, 0, t.LinkAddr1, t.LinkAddr2, t.LinkCity, t.LinkRegion, t.LinkCountry, t.LinkPostalCode, 0, @ServerTime, @CurrentUser
	FROM dbo.tblCmContact INNER JOIN #Synchronize t ON dbo.tblCmContact.ID = t.ContactId 
		LEFT JOIN dbo.tblCmContactAddress a ON dbo.tblCmContact.ID = a.ContactID
	WHERE dbo.tblCmContact.[Status] <> 2 AND t.UpdateDir = 0 AND (a.ID IS NULL OR a.Sequence <> 0)
	
	INSERT INTO dbo.tblCmActivity(ID, Descr, EntryDate, ContactID, UserID, Source, [Status])
	SELECT @Id + t.ContactId, c.ContactName, @ServerTime, c.ID, @CurrentUser, 2, 0
	FROM dbo.tblCmContact c INNER JOIN #Synchronize t ON c.ID = t.ContactId
	WHERE c.[Status] <> 2 AND t.UpdateDir = 0
	
	UPDATE dbo.tblArCust 
		SET CustName = t.ContactName, Addr1 = t.Addr1, Addr2 = t.Addr2, City = t.City, Region = t.Region, Country = t.Country, PostalCode = t.PostalCode
	FROM dbo.tblArCust INNER JOIN #Synchronize t ON dbo.tblArCust.CustId = t.LinkId
	WHERE t.UpdateDir = 1 AND t.LinkType = 1
	
	UPDATE dbo.tblApVendor
		SET [Name] = t.ContactName, Addr1 = t.Addr1, Addr2 = t.Addr2, City = t.City, Region = t.Region, Country = t.Country, PostalCode = t.PostalCode
	FROM dbo.tblApVendor INNER JOIN #Synchronize t ON dbo.tblApVendor.VendorID = t.LinkId
	WHERE t.UpdateDir = 1 AND t.LinkType = 2
			
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmSynchronizeContact_Write_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmSynchronizeContact_Write_proc';

