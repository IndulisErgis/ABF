
CREATE PROCEDURE [dbo].[trav_PaEmplrHistoryWithholdInquiry_proc]
@EmpHistoryCtlType tinyint = 0

AS
BEGIN TRY
	SET NOCOUNT ON

	--DROP TABLE #tmpEmpHistoryList
	--CREATE TABLE #tmpEmpHistoryList(Id int NOT NULL PRIMARY KEY CLUSTERED ([Id]))
	--INSERT INTO #tmpEmpHistoryList ([Id]) SELECT Id FROM dbo.tblPaEmpHistWithhold
	--INSERT INTO #tmpEmpHistoryList ([Id]) SELECT Id FROM dbo.tblPaEmpHistDeduct WHERE MiscCodeID = 1

	IF @EmpHistoryCtlType = 0
	BEGIN
		SELECT * FROM
		(
			SELECT h.Id, 1 AS [Type], h.TaxAuthorityType, h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.WithholdingCode AS Code, h.[State], h.[Local], h.EarningAmount AS Amount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryList l 
				INNER JOIN dbo.tblPaEmpHistWithhold h ON l.Id = h.Id 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			WHERE h.TaxAuthorityType = 0 AND h.EmployerPaid = 1
			UNION ALL
			SELECT h.Id, 2 AS [Type], h.TaxAuthorityType, h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.WithholdingCode AS Code, h.[State], h.[Local], h.TaxableAmount AS Amount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryList l 
				INNER JOIN dbo.tblPaEmpHistWithhold h ON l.Id = h.Id 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			WHERE h.TaxAuthorityType = 0 AND h.EmployerPaid = 1
			UNION ALL
			SELECT h.Id, 3 AS [Type], h.TaxAuthorityType, h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.WithholdingCode AS Code, h.[State], h.[Local], h.WithholdAmount AS Amount, e.DepartmentId, e.GroupCode
				,	CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2	
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryList l 
				INNER JOIN dbo.tblPaEmpHistWithhold h ON l.Id = h.Id 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			WHERE h.TaxAuthorityType = 0 AND h.EmployerPaid = 1
			UNION ALL
			SELECT h.Id, 1 AS [Type], h.TaxAuthorityType, h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.WithholdingCode AS Code, h.[State], h.[Local], h.EarningAmount AS Amount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryList l 
				INNER JOIN dbo.tblPaEmpHistWithhold h ON l.Id = h.Id 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			WHERE h.TaxAuthorityType = 1 AND h.EmployerPaid = 1
			UNION ALL
			SELECT h.Id, 2 AS [Type], h.TaxAuthorityType, h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.WithholdingCode AS Code, h.[State], h.[Local], h.TaxableAmount AS Amount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryList l 
				INNER JOIN dbo.tblPaEmpHistWithhold h ON l.Id = h.Id 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			WHERE h.TaxAuthorityType = 1 AND h.EmployerPaid = 1
			UNION ALL
			SELECT h.Id, 3 AS [Type], h.TaxAuthorityType, h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.WithholdingCode AS Code, h.[State], h.[Local], h.WithholdAmount AS Amount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryList l 
				INNER JOIN dbo.tblPaEmpHistWithhold h ON l.Id = h.Id 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			WHERE h.TaxAuthorityType = 1 AND h.EmployerPaid = 1
			UNION ALL
			SELECT h.Id, 1 AS [Type], h.TaxAuthorityType, h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.WithholdingCode AS Code, h.[State], h.[Local], h.EarningAmount AS Amount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryList l 
				INNER JOIN dbo.tblPaEmpHistWithhold h ON l.Id = h.Id 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			WHERE h.TaxAuthorityType = 2 AND h.EmployerPaid = 1
			UNION ALL
			SELECT h.Id, 2 AS [Type], h.TaxAuthorityType, h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.WithholdingCode AS Code, h.[State], h.[Local], h.TaxableAmount AS Amount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryList l	
				INNER JOIN dbo.tblPaEmpHistWithhold h ON l.Id = h.Id 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			WHERE h.TaxAuthorityType = 2 AND h.EmployerPaid = 1
			UNION ALL
			SELECT h.Id, 2 AS [Type], h.TaxAuthorityType, h.EntryDate, h.PaYear, h.PaMonth, h.EmployeeId
				, h.WithholdingCode AS Code, h.[State], h.[Local], h.WithholdAmount AS Amount, e.DepartmentId, e.GroupCode
				, CASE h.PaMonth WHEN 1 THEN 1 WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 4 THEN 2 WHEN 5 THEN 2 WHEN 6 THEN 2 
					WHEN 7 THEN 3 WHEN 8 THEN 3 WHEN 9 THEN 3 WHEN 10 THEN 4 WHEN 11 THEN 4 WHEN 12 THEN 4 END AS [Quarter]
				, COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '') + ' ' + COALESCE (MiddleInit, '') AS EmployeeName 
			FROM #tmpEmpHistoryList l 
				INNER JOIN dbo.tblPaEmpHistWithhold h ON l.Id = h.Id 
				LEFT JOIN dbo.tblPaEmployee e ON h.EmployeeId = e.EmployeeId 
				LEFT JOIN dbo.tblSmEmployee s ON e.EmployeeId = s.EmployeeId
			WHERE h.TaxAuthorityType = 2 AND h.EmployerPaid = 1
		) EmpHistQry ORDER BY EmpHistQry.EmployeeId, EmpHistQry.TaxAuthorityType, EmpHistQry.[Type], EmpHistQry.Code
	END
	ELSE
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
			WHERE h.EmployerPaid = 1 AND c.EmployerPaid = 1
		) EmpHistQry ORDER BY EmployeeId, [Type], [Description]
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmplrHistoryWithholdInquiry_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmplrHistoryWithholdInquiry_proc';

