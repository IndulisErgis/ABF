
CREATE PROCEDURE dbo.trav_PaDepartmentExpense_proc 
@PayrollYear smallint,
@UseHomeDepartment bit, 
@PrecCurr tinyint
AS
BEGIN TRY
	SET NOCOUNT ON
	--build a list of checks to process
	CREATE TABLE #CheckList([CheckId] [int] NOT NULL PRIMARY KEY ([CheckId]))

	INSERT INTO #CheckList([CheckId])
	SELECT [Id] FROM [dbo].[tblPaCheck]
	WHERE [PaYear] = @PayrollYear

	--create the tables used by the calculate department allocations process
	CREATE TABLE #tmpPaAllocPct
	(
		[Id] int IDENTITY(1,1),
		[CheckId] [int] NOT NULL,
		[DepartmentId] [pDeptID] NOT NULL,
		[EarnPerc] [pDecimal] NULL,
		[HomeYn] [bit] NOT NULL
	)
	
	CREATE TABLE #tmpPaAllocExclPct
	(
		[Id] int IDENTITY(1,1),
		[CheckId] [int] NOT NULL,
		[DepartmentId] [pDeptID] NOT NULL,
		[EarnPerc] [pDecimal] NULL,
		[HomeYn] [bit] NOT NULL,
		[Code] [pCode] NOT NULL
	)


	CREATE TABLE #tmpPaAllocTax
	(
		[CheckId] [int] NOT NULL,
		[Id] [int] NOT NULL, 
		[DepartmentId] [pDeptID] NOT NULL,
		[TaxAuthorityId] [int] NOT NULL,
		[WithholdingCode] [pCode] NOT NULL,
		[AllocTax] [pDecimal] NOT NULL,
		[AllocEarn] [pDecimal] NOT NULL,
		[AllocGross] [pDecimal] NOT NULL
	)

	CREATE TABLE #tmpPaAllocCost
	(
		[CheckId] [int] NOT NULL,
		[Id] [int] NOT NULL,
		[DepartmentId] [pDeptID] NOT NULL,
		[DeductionCode] [pCode] NOT NULL,
		[AllocCost] [pDecimal] NOT NULL
	)

	CREATE TABLE #EarningDepartmentDetail
	(
		[DepartmentId] [pDeptID] NOT NULL,
		[CheckId] [int] NOT NULL,
		[HoursWorked] [pDecimal] NOT NULL,
		[EarningAmount] [pDecimal] NOT NULL,
		[EarningCode] [pCode] NULL
	)
   
	  
	--Execute the SP to generate the department allocations
	EXEC [dbo].[trav_PaCalculateDepartmentAllocations_proc] @UseHomeDepartment, @PrecCurr, @PayrollYear 


	--build the list of earning detail for each department in the prepared checks
	INSERT INTO #EarningDepartmentDetail ([DepartmentId], [CheckId]
		, [HoursWorked], [EarningAmount], [EarningCode])
	SELECT ce.[DepartmentId], c.[Id]
		, ce.[HoursWorked], ce.[EarningAmount], ce.[EarningCode]
	FROM [dbo].[tblPaCheck] c 
	INNER JOIN #CheckList l ON c.[Id] = l.[CheckId]
	INNER JOIN [dbo].[tblPaCheckEarn] ce ON c.[Id] = ce.[CheckId]
	INNER JOIN [dbo].[tblPaEarnCode] ec ON ce.[EarningCode] = ec.[Id]
	WHERE ec.[IncludeInNet] <> 0
	
	--ensure that the all allocated department have an associated earning entry
	--	Note:Home department may not be listed in the earnings but may be needed due to allocations of Taxes/Costs
	INSERT INTO #EarningDepartmentDetail ([DepartmentId], [CheckId]
		, [HoursWorked], [EarningAmount], [EarningCode])
	SELECT t.[DepartmentId], t.[CheckId], 0, 0, NULL
	FROM 
	(
		SELECT [CheckId], [DepartmentId] 
			FROM #tmpPaAllocTax 
			WHERE [AllocTax] <> 0 
			GROUP BY [CheckId], [DepartmentId] 
		UNION 
		SELECT [CheckId], [DepartmentId] 
			FROM #tmpPaAllocCost 
			WHERE [AllocCost] <> 0
			GROUP BY [CheckId], [DepartmentId] 
	) t		
	LEFT JOIN #EarningDepartmentDetail d ON t.[CheckId] = d.[CheckId] AND t.[DepartmentId] = d.[DepartmentId]
	WHERE d.[DepartmentId] IS NULL
	

	--retrieve the earning detail
	SELECT ce.[DepartmentId], c.[Id] AS [CheckId], c.[CheckNumber], c.[EmployeeId] 
		, SUM(ce.[HoursWorked]) AS [HoursWorked]
		, SUM(ce.[EarningAmount]) AS [EarningAmount]
		, ce.[EarningCode], ec.[Description]
	FROM [dbo].[tblPaCheck] c 
	INNER JOIN #CheckList l ON c.[Id] = l.[CheckId]
	INNER JOIN #EarningDepartmentDetail ce ON c.[Id] = ce.[CheckId]
	LEFT JOIN [dbo].[tblPaEarnCode] ec ON ce.[EarningCode] = ec.[Id]
	--WHERE  ce.[EarningCode] not in 
	--(Select EarningCode from #tmpPaCheckEarnExclusion)
	GROUP BY ce.[DepartmentId], c.[Id], c.[CheckNumber], c.[EmployeeId]
		, ce.[EarningCode], ec.[Description]

	--retrieve the tax detail
	SELECT a.[CheckId], a.DepartmentId, t.[TaxAuthority], a.[WithholdingCode]
		, t.[TaxAuthority] + ' / ' + a.[WithholdingCode] AS [TaxAuthWithholdingCode]
		, d.[Description], a.[AllocTax]
	FROM [dbo].[tblPaDeptDtl] d 
	INNER JOIN #tmpPaAllocTax a ON d.[DepartmentId] = a.[DepartmentId] AND d.[TaxAuthorityId] = a.[TaxAuthorityId] AND d.[Code] = a.[WithholdingCode]
	INNER JOIN [dbo].[tblPaTaxAuthorityHeader] t ON a.[TaxAuthorityId] = t.[Id]

	--retrieve the cost detail
	SELECT a.[CheckId], a.[DepartmentId], a.[DeductionCode], d.[Description], a.[AllocCost]
	FROM [dbo].[tblPaDeptDtl] d 
	INNER JOIN #tmpPaAllocCost a ON d.[DepartmentId] = a.[DepartmentId] AND d.[Code] = a.[DeductionCode]
	WHERE d.[Type] = 4 --Deductions


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaDepartmentExpense_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaDepartmentExpense_proc';

