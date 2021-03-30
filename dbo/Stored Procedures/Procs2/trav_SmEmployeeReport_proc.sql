
CREATE PROCEDURE [dbo].[trav_SmEmployeeReport_proc]

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT e.EmployeeId, LastName, AddressLine1, AddressLine2, ResidentCity, ResidentState, ZipCode, CountryCode
		, SocialSecurityNo, PhoneNumber, WorkPhoneNo, WorkExtension, BirthDate, EmergrncyContact AS EmergencyContact
		, ContactWorkPhone, ContactHomePhone, ContactRelation, WorkEmail, HomeEmail, Internet
		, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
	FROM dbo.tblSmEmployee e INNER JOIN #tmpEmployeeList t ON e.EmployeeId = t.EmployeeId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmEmployeeReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmEmployeeReport_proc';

