CREATE VIEW [dbo].[trav_tblSmEmployee_view]
AS
SELECT t.[AddressLine1]
, t.[AddressLine2]
, t.[BirthDate]
, t.[ContactHomePhone]
, t.[ContactRelation]
, t.[ContactWorkPhone]
, t.[CountryCode]
, t.[EmergrncyContact]
, t.[EmployeeId]
, t.[FirstName]
, t.[HomeEmail]
, t.[Internet]
, t.[LastName]
, t.[MiddleInit]
, t.[PhoneNumber]
, t.[ResidentCity]
, t.[ResidentState]
, t.[SocialSecurityNo]
, t.[Status]
, t.[UID]
, t.[WorkEmail]
, t.[WorkExtension]
, t.[WorkPhoneNo]
, t.[ZipCode]
, e.[cf_User Defined Date 1]
, e.[cf_User Defined Date 10]
, e.[cf_User Defined Date 2]
, e.[cf_User Defined Date 3]
, e.[cf_User Defined Date 4]
, e.[cf_User Defined Date 5]
, e.[cf_User Defined Date 6]
, e.[cf_User Defined Date 7]
, e.[cf_User Defined Date 8]
, e.[cf_User Defined Date 9]
, e.[cf_User Label 1]
, e.[cf_User Label 2]
, e.[cf_User Label 3]
 FROM dbo.[tblSmEmployee] t
 LEFT JOIN
 ( SELECT pvt.[EmployeeId]
	, Cast(pvt.[User Defined Date 1] As datetime) AS [cf_User Defined Date 1]
	, Cast(pvt.[User Defined Date 10] As datetime) AS [cf_User Defined Date 10]
	, Cast(pvt.[User Defined Date 2] As datetime) AS [cf_User Defined Date 2]
	, Cast(pvt.[User Defined Date 3] As datetime) AS [cf_User Defined Date 3]
	, Cast(pvt.[User Defined Date 4] As datetime) AS [cf_User Defined Date 4]
	, Cast(pvt.[User Defined Date 5] As datetime) AS [cf_User Defined Date 5]
	, Cast(pvt.[User Defined Date 6] As datetime) AS [cf_User Defined Date 6]
	, Cast(pvt.[User Defined Date 7] As datetime) AS [cf_User Defined Date 7]
	, Cast(pvt.[User Defined Date 8] As datetime) AS [cf_User Defined Date 8]
	, Cast(pvt.[User Defined Date 9] As datetime) AS [cf_User Defined Date 9]
	, Cast(pvt.[User Label 1] As nvarchar(20)) AS [cf_User Label 1]
	, Cast(pvt.[User Label 2] As nvarchar(20)) AS [cf_User Label 2]
	, Cast(pvt.[User Label 3] As nvarchar(20)) AS [cf_User Label 3]
	 FROM
		 ( SELECT t.[EmployeeId], [Name], [Value]
		 FROM
			 ( SELECT t.[EmployeeId]
			 , e.props.value('./Name[1]', 'NVARCHAR(max)') as [Name]
			 , e.props.value('./Value[1]', 'NVARCHAR(max)') as [Value]
			 FROM dbo.[tblSmEmployee] t
			 CROSS APPLY t.CF.nodes('/ArrayOfEntityPropertyOfString/EntityPropertyOfString') as e(props)
			 WHERE (e.props.exist('Name') = 1) AND (e.props.exist('Value') = 1)
		 ) t
	 ) tmp
	 PIVOT (Max([Value]) FOR [Name] IN ([User Defined Date 1], [User Defined Date 10], [User Defined Date 2], [User Defined Date 3], [User Defined Date 4], [User Defined Date 5], [User Defined Date 6], [User Defined Date 7], [User Defined Date 8], [User Defined Date 9], [User Label 1], [User Label 2], [User Label 3])) AS pvt
) e on  t.[EmployeeId] = e.[EmployeeId]
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_tblSmEmployee_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_tblSmEmployee_view';

