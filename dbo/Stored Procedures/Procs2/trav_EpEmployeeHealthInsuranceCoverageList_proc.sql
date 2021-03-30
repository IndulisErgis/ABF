
CREATE PROCEDURE dbo.trav_EpEmployeeHealthInsuranceCoverageList_proc
@SortBy int, -- 0 = Employee ID, 1 = Last Name, 2 = Social Security Number, 3 = Department ID
@PaYear smallint

AS
BEGIN TRY
	SET NOCOUNT ON

	-- Header resultset
	SELECT CASE @SortBy 
			WHEN 0 THEN e.EmployeeId 
			WHEN 1 THEN s.LastName 
			WHEN 2 THEN s.SocialSecurityNo 
			WHEN 3 THEN p.DepartmentId 
			END AS GrpId1
		, CASE @SortBy 
			WHEN 3 THEN e.EmployeeId 
			ELSE p.DepartmentId 
			END AS GrpId2
		, e.Id, e.EmployeeId, s.LastName
		, COALESCE (s.LastName, '') + ', ' + COALESCE (s.FirstName, '')  + ' ' + COALESCE (s.MiddleInit, '') AS Name
		, s.SocialSecurityNo, p.DepartmentId, s.PhoneNumber, s.CountryCode AS Country, e.ElectronicOnly, e.PolicyOrigin, e.SelfInsured 
	FROM #EmployeeList tmp 
		INNER JOIN dbo.tblEpHCEmployee e ON e.Id = tmp.Id 
		INNER JOIN dbo.tblPaEmployee p ON p.EmployeeId = e.EmployeeId 
		INNER JOIN dbo.tblSmEmployee s ON s.EmployeeId = e.EmployeeId

	-- Coverage Codes / Amounts resultset
	SELECT HeaderId
		, MAX(CASE WHEN PaMonth = 1 THEN Code ELSE NULL END) AS Code1
		, MAX(CASE WHEN PaMonth = 1 THEN Premium ELSE NULL END) AS Premium1
		, MAX(CASE WHEN PaMonth = 2 THEN Code ELSE NULL END) AS Code2
		, MAX(CASE WHEN PaMonth = 2 THEN Premium ELSE NULL END) AS Premium2
		, MAX(CASE WHEN PaMonth = 3 THEN Code ELSE NULL END) AS Code3
		, MAX(CASE WHEN PaMonth = 3 THEN Premium ELSE NULL END) AS Premium3
		, MAX(CASE WHEN PaMonth = 4 THEN Code ELSE NULL END) AS Code4
		, MAX(CASE WHEN PaMonth = 4 THEN Premium ELSE NULL END) AS Premium4
		, MAX(CASE WHEN PaMonth = 5 THEN Code ELSE NULL END) AS Code5
		, MAX(CASE WHEN PaMonth = 5 THEN Premium ELSE NULL END) AS Premium5
		, MAX(CASE WHEN PaMonth = 6 THEN Code ELSE NULL END) AS Code6
		, MAX(CASE WHEN PaMonth = 6 THEN Premium ELSE NULL END) AS Premium6
		, MAX(CASE WHEN PaMonth = 7 THEN Code ELSE NULL END) AS Code7
		, MAX(CASE WHEN PaMonth = 7 THEN Premium ELSE NULL END) AS Premium7
		, MAX(CASE WHEN PaMonth = 8 THEN Code ELSE NULL END) AS Code8
		, MAX(CASE WHEN PaMonth = 8 THEN Premium ELSE NULL END) AS Premium8
		, MAX(CASE WHEN PaMonth = 9 THEN Code ELSE NULL END) AS Code9
		, MAX(CASE WHEN PaMonth = 9 THEN Premium ELSE NULL END) AS Premium9
		, MAX(CASE WHEN PaMonth = 10 THEN Code ELSE NULL END) AS Code10
		, MAX(CASE WHEN PaMonth = 10 THEN Premium ELSE NULL END) AS Premium10
		, MAX(CASE WHEN PaMonth = 11 THEN Code ELSE NULL END) AS Code11
		, MAX(CASE WHEN PaMonth = 11 THEN Premium ELSE NULL END) AS Premium11
		, MAX(CASE WHEN PaMonth = 12 THEN Code ELSE NULL END) AS Code12 
		, MAX(CASE WHEN PaMonth = 12 THEN Premium ELSE NULL END) AS Premium12 
	FROM #EmployeeList tmp 
		INNER JOIN dbo.tblEpHCEmployeeMonth m ON m.HeaderId = tmp.id
	WHERE m.CodeType = 0 
	GROUP BY HeaderId

	-- Safe Harbor Codes resultset
	SELECT HeaderId
		, MAX(CASE WHEN PaMonth = 1 THEN Code ELSE NULL END) AS Code1
		, MAX(CASE WHEN PaMonth = 2 THEN Code ELSE NULL END) AS Code2
		, MAX(CASE WHEN PaMonth = 3 THEN Code ELSE NULL END) AS Code3
		, MAX(CASE WHEN PaMonth = 4 THEN Code ELSE NULL END) AS Code4
		, MAX(CASE WHEN PaMonth = 5 THEN Code ELSE NULL END) AS Code5
		, MAX(CASE WHEN PaMonth = 6 THEN Code ELSE NULL END) AS Code6
		, MAX(CASE WHEN PaMonth = 7 THEN Code ELSE NULL END) AS Code7
		, MAX(CASE WHEN PaMonth = 8 THEN Code ELSE NULL END) AS Code8
		, MAX(CASE WHEN PaMonth = 9 THEN Code ELSE NULL END) AS Code9
		, MAX(CASE WHEN PaMonth = 10 THEN Code ELSE NULL END) AS Code10
		, MAX(CASE WHEN PaMonth = 11 THEN Code ELSE NULL END) AS Code11
		, MAX(CASE WHEN PaMonth = 12 THEN Code ELSE NULL END) AS Code12 
	FROM #EmployeeList tmp 
		INNER JOIN dbo.tblEpHCEmployeeMonth m ON m.HeaderId = tmp.id
	WHERE m.CodeType = 1 
	GROUP BY HeaderId

	-- Provider resultset
	SELECT i.HeaderId, i.Name1, i.Name2, i.EIN, i.Address1, i.Address2
		, i.City, i.Region, i.PostalCode, i.Country, i.Phone, i.PhoneExt 
	FROM #EmployeeList tmp 
		INNER JOIN dbo.tblEpHCEmployeeProviderInfo i ON i.HeaderId = tmp.id

	-- Covered Individuals resultset
	SELECT HeaderId, LastName, FirstName, MiddleInit, SSN, Birthdate
		, SUBSTRING(MonthFlag, 1, 1) AS Month1
		, SUBSTRING(MonthFlag, 2, 1) AS Month2
		, SUBSTRING(MonthFlag, 3, 1) AS Month3
		, SUBSTRING(MonthFlag, 4, 1) AS Month4
		, SUBSTRING(MonthFlag, 5, 1) AS Month5
		, SUBSTRING(MonthFlag, 6, 1) AS Month6
		, SUBSTRING(MonthFlag, 7, 1) AS Month7
		, SUBSTRING(MonthFlag, 8, 1) AS Month8
		, SUBSTRING(MonthFlag, 9, 1) AS Month9
		, SUBSTRING(MonthFlag, 10, 1) AS Month10
		, SUBSTRING(MonthFlag, 11, 1) AS Month11
		, SUBSTRING(MonthFlag, 12, 1) AS Month12 
	FROM #EmployeeList tmp 
		INNER JOIN dbo.tblEpHCEmployeeCoverage c ON c.HeaderId = tmp.id

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_EpEmployeeHealthInsuranceCoverageList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_EpEmployeeHealthInsuranceCoverageList_proc';

