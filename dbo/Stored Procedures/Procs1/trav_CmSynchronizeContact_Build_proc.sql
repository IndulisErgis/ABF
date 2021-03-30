
CREATE PROCEDURE dbo.trav_CmSynchronizeContact_Build_proc 
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @LinkType int, @UpdateDir int

	--Retrieve global values
	SELECT @LinkType = Cast([Value] AS int) FROM #GlobalValues WHERE [Key] = 'LinkType'
	SELECT @UpdateDir = Cast([Value] AS int) FROM #GlobalValues WHERE [Key] = 'UpdateDir'
	
	--LinkType: 0;None;1;Customer;2;Vendor;3;Employee;4;SalesRep
	--UpdateDir: 0;Contact;1;Link;2;Skip
	IF @LinkType IS NULL OR @UpdateDir IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	IF @LinkType = 1 --Customer
	BEGIN
		INSERT INTO #Synchronize(ContactId, LinkId, UpdateDir, LinkType, ContactName, FirstName, LastName, Addr1,
			Addr2, City, Region, Country, PostalCode, LinkName, LinkAddr1, LinkAddr2,
			LinkCity, LinkRegion, LinkCountry, LinkPostalCode)
		SELECT c.ID, c.LinkId, @UpdateDir, 1, c.ContactName, c.FName, c.LName, a.Addr1,
			a.Addr2, a.City, a.Region, a.Country, a.PostalCode, m.CustName, m.Addr1, m.Addr2,
			m.City, m.Region, m.Country, m.PostalCode
		FROM #CrmAccessList t INNER JOIN dbo.tblCMContact c ON t.ContactId = c.Id 
			INNER JOIN dbo.tblArCust m ON c.LinkId = m.CustId 
			LEFT JOIN dbo.tblCmContactAddress a ON c.ID = a.ContactID --Assume only one address with Sequence = 0 per contact
		WHERE c.LinkType = 1 AND (a.ID IS NULL OR a.Sequence = 0) AND (ISNULL(c.ContactName,'') != ISNULL(m.CustName,'') OR 
			ISNULL(a.Addr1,'') != ISNULL(m.Addr1,'') OR ISNULL(a.Addr2,'') != ISNULL(m.Addr2,'')
			OR ISNULL(a.City,'') != ISNULL(m.City,'') OR ISNULL(a.Region,'') != ISNULL(m.Region,'') 
			OR ISNULL(a.Country,'') != ISNULL(m.Country,'') OR ISNULL(a.PostalCode,'') != ISNULL(m.PostalCode,''))
	END
	ELSE IF @LinkType = 2 --Vendor
	BEGIN
		INSERT INTO #Synchronize(ContactId, LinkId, UpdateDir, LinkType, ContactName, FirstName, LastName, Addr1,
			Addr2, City, Region, Country, PostalCode, LinkName, LinkAddr1, LinkAddr2,
			LinkCity, LinkRegion, LinkCountry, LinkPostalCode)
		SELECT c.ID, c.LinkId, @UpdateDir, 2, c.ContactName, c.FName, c.LName, a.Addr1,
			a.Addr2, a.City, a.Region, a.Country, a.PostalCode, m.[Name], m.Addr1, m.Addr2,
			m.City, m.Region, m.Country, m.PostalCode
		FROM #CrmAccessList t INNER JOIN dbo.tblCMContact c ON t.ContactId = c.Id 
			INNER JOIN dbo.tblApVendor m ON c.LinkId = m.VendorID 
			LEFT JOIN dbo.tblCmContactAddress a ON c.ID = a.ContactID --Assume only one address with Sequence = 0 per contact
		WHERE c.LinkType = 2 AND (a.ID IS NULL OR a.Sequence = 0) AND (ISNULL(c.ContactName,'') != ISNULL(m.[Name],'') OR 
			ISNULL(a.Addr1,'') != ISNULL(m.Addr1,'') OR ISNULL(a.Addr2,'') != ISNULL(m.Addr2,'')
			OR ISNULL(a.City,'') != ISNULL(m.City,'') OR ISNULL(a.Region,'') != ISNULL(m.Region,'') 
			OR ISNULL(a.Country,'') != ISNULL(m.Country,'') OR ISNULL(a.PostalCode,'') != ISNULL(m.PostalCode,''))
	END
	ELSE IF @LinkType = 3 --Employee
	BEGIN
		INSERT INTO #Synchronize(ContactId, LinkId, UpdateDir, LinkType, ContactName, FirstName, LastName, Addr1,
			Addr2, City, Region, Country, PostalCode, LinkName, LinkFirstName, LinkLastName, LinkAddr1, LinkAddr2,
			LinkCity, LinkRegion, LinkCountry, LinkPostalCode)
		SELECT c.ID, c.LinkId, @UpdateDir, 3, ISNULL(c.FName,'') + ' ' + ISNULL(c.LName,''), c.FName, c.LName, a.Addr1,
			a.Addr2, a.City, a.Region, a.Country, a.PostalCode, ISNULL(m.FirstName,'') + ' ' + ISNULL(m.LastName,''), 
			m.FirstName, m.LastName, m.AddressLine1, m.AddressLine2,	m.ResidentCity, m.ResidentState, m.CountryCode, m.ZipCode
		FROM #CrmAccessList t INNER JOIN dbo.tblCMContact c ON t.ContactId = c.Id 
			INNER JOIN dbo.tblSmEmployee m ON c.LinkId = m.EmployeeId 
			LEFT JOIN dbo.tblCmContactAddress a ON c.ID = a.ContactID --Assume only one address with Sequence = 0 per contact
		WHERE c.LinkType = 3 AND (a.ID IS NULL OR a.Sequence = 0) AND (ISNULL(c.FName,'') != ISNULL(m.FirstName,'') OR ISNULL(c.LName,'') != ISNULL(m.LastName,'') OR ISNULL(a.Addr1,'') != ISNULL(m.AddressLine1,'') OR ISNULL(a.Addr2,'') != ISNULL(m.AddressLine2,'')
			OR ISNULL(a.City,'') != ISNULL(m.ResidentCity,'') OR ISNULL(a.Region,'') != ISNULL(m.ResidentState,'') OR ISNULL(a.Country,'') != ISNULL(m.CountryCode,'') OR ISNULL(a.PostalCode,'') != ISNULL(m.ZipCode,''))
	END	
			
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmSynchronizeContact_Build_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmSynchronizeContact_Build_proc';

