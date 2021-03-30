
CREATE PROCEDURE [dbo].[trav_PaEmpHistoryInquiry_proc]
@EmpHistoryCtlType tinyint = 0

AS
BEGIN TRY
	SET NOCOUNT ON

	--DROP TABLE #tmpEmpHistoryGrossNetList
	--CREATE TABLE #tmpEmpHistoryGrossNetList(Id int NOT NULL, Code nvarchar(6))
	--INSERT INTO #tmpEmpHistoryGrossNetList ([Id], Code) SELECT Id, Code FROM dbo.trav_PaEmpHistGrossNet_view WHERE Code = 'Net'

	IF @EmpHistoryCtlType = 0
	BEGIN
		--CREATE TABLE #tmpEmpHistoryList(Id int NOT NULL PRIMARY KEY CLUSTERED ([Id]))
		--INSERT INTO #tmpEmpHistoryList ( [Id]) SELECT Id FROM dbo.trav_PaEmpHistMisc_view 

		SELECT * FROM
		(
			SELECT h.Id, 1 AS [Type], c.Descr AS [Description], h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.MiscCodeId AS Code, h.Amount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryList l 
				INNER JOIN dbo.tblPaEmpHistMisc h ON l.Id = h.Id 
				INNER JOIN tblPaMiscCode c ON h.MiscCodeId = c.Id AND c.Descr <> 'Paid/Month' 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			UNION ALL
			SELECT h.Id, 3 AS [Type], c.Descr AS [Description], h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.MiscCodeId AS Code, h.Amount AS Amount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryList l 
				INNER JOIN dbo.tblPaEmpHistMisc h ON l.Id = h.Id 
				INNER JOIN dbo.tblPaMiscCode c ON h.MiscCodeId = c.Id AND c.Descr = 'Paid/Month' 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
		) EmpHistQry ORDER BY EmployeeId, [Type], [Description]
	END

	IF @EmpHistoryCtlType = 1
	BEGIN
		SELECT * FROM
		(
			SELECT h.Id, 1 AS [Type], c.[Description], h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.DeductionCode AS Code, h.EmployerPaid, h.Amount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryList l 
				INNER JOIN dbo.tblPaEmpHistDeduct h ON l.Id = h.Id 
				INNER JOIN tblPaDeductCode c ON h.DeductionCode = c.DeductionCode 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId 
			WHERE h.EmployerPaid = 0 AND c.EmployerPaid = 0
		) EmpHistQry ORDER BY EmployeeId, [Type], [Description]
	END

	IF @EmpHistoryCtlType = 2
	BEGIN
		SELECT * FROM
		(
			SELECT h.Id, 1 AS [Type], c.[Description], h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.EarningCode AS Code, h.Amount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpEarnHistoryList l 
				INNER JOIN dbo.tblPaEmpHistEarn h ON l.Id = h.Id 
				INNER JOIN dbo.tblPaEarnCode c ON h.EarningCode = c.Id AND l.[Type] = 1 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			UNION ALL
			SELECT h.Id, 2 AS [Type], c.[Description], h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.EarningCode AS Code, h.Hours, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpEarnHistoryList l 
				INNER JOIN dbo.tblPaEmpHistEarn h ON l.Id = h.Id 
				INNER JOIN dbo.tblPaEarnCode c ON h.EarningCode = c.Id AND l.[Type] = 2 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			UNION ALL
			SELECT h.Id, 1 AS [Type], 'Gross Pay' AS [Description], EntryDate, PaYear, PaMonth, h.EmployeeId
				, 'Gross' AS Code, GrossPayAmount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryGrossNetList l 
				INNER JOIN dbo.tblPaEmpHistGrossNet h ON l.Id = h.Id AND l.Code = 'Gross' 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			UNION ALL
			SELECT h.Id, 1 AS [Type], 'Net Pay' AS [Description], EntryDate, PaYear, PaMonth, h.EmployeeId
				, 'Net' AS Code, NetPayAmount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryGrossNetList l 
				INNER JOIN dbo.tblPaEmpHistGrossNet h ON l.Id = h.Id AND l.Code = 'Net' 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
		) EmpHistQry ORDER BY EmployeeId, [Type], [Description]
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmpHistoryInquiry_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmpHistoryInquiry_proc';

