
CREATE PROCEDURE [dbo].[trav_PaCheckPost_UpdateDept_proc]
AS
BEGIN TRY

	----PET:http://webfront:801/view.php?id=227109    
	----PET:http://webfront:801/view.php?id=227374     
	--PET:http://webfront:801/view.php?id=229971   
	--MOD:  

	DECLARE	@Hours smallint, @Earnings smallint, @Pieces smallint, @Deductions  smallint, @CurrBase pCurrency,
	@DateOnCheck Datetime, @iMonth smallint, @PaYear smallint,@Accrual smallint,@AccruedWages smallint

	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @Hours = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Hours'
    SELECT @Earnings = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Earnings'
    SELECT @Pieces = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Pieces'
    SELECT @Deductions = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Deductions'
    SELECT @PaYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'
    SELECT @DateOnCheck = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DateOnCheck'
    SELECT @iMonth = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'iMonth'
	SELECT @Accrual = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Accrual'
	SELECT @AccruedWages = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'AccruedWages'

	IF @Hours IS NULL OR @Earnings IS NULL OR @Pieces IS NULL Or 
	@Deductions IS NULL Or @CurrBase IS NULL OR @Accrual IS NULL OR @AccruedWages IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	CREATE TABLE [dbo].[#tmpTrans](
		[DepartmentID] [dbo].[pDeptID] NOT NULL,
		[SH] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[SP] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
	)

	CREATE TABLE [dbo].[#tmpTransE](
		[DepartmentID] [pDeptID] NOT NULL,
		[EarningCode] [dbo].[pDeptID] NOT NULL,
		[SE] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
	)

	CREATE TABLE [dbo].[#tmpEarn](
		[DepartmentID] [dbo].[pDeptID] NOT NULL,
		[SH] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[SP] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
	)

	CREATE TABLE [dbo].[#tmpEarnCode](
		[DepartmentID] [dbo].[pDeptID] NOT NULL,
		[EarningCode] [dbo].[pDeptID] NOT NULL,
		[SE] [dbo].[pDecimal] NOT NULL DEFAULT ((0))
	)

	CREATE TABLE [dbo].[#tmpAT](

		[DepartmentID] [dbo].[pDeptID] NOT NULL,
		[WithholdingCode] [dbo].[pCode] NOT NULL,
		[TaxAuthorityId] int NOT NULL,
		[SAT] [dbo].[pDecimal] NOT NULL DEFAULT ((0))
	)

	CREATE TABLE [dbo].[#tmpAC](


		[DepartmentID] [dbo].[pDeptID] NOT NULL,
		[DeductionCode]  [dbo].[pCode] NOT NULL,
		[SAC] [dbo].[pDecimal] NOT NULL DEFAULT ((0))
	)



	INSERT INTO #tmpTrans(DepartmentID, SH, SP)
	SELECT t.DepartmentID, SUM(t.[Hours]) AS SH, SUM(t.[Pieces]) AS SP
	FROM dbo.tblPaTransEarn t
	INNER JOIN  dbo.tblPaCheckTrans ct on t.Id = ct.TransId  
	INNER JOIN #PostTransList b ON ct.CheckId = b.TransId
	WHERE t.PostedYn = 1 and ct.TransType = 0
	GROUP BY t.DepartmentID

	INSERT INTO #tmpTransE(DepartmentID, EarningCode,SE)
	SELECT t.DepartmentID, t.EarningCode, SUM(t.Amount) AS SE
	FROM dbo.tblPaTransEarn t
	INNER JOIN  dbo.tblPaCheckTrans ct on t.Id = ct.TransId
	INNER JOIN #PostTransList b ON ct.CheckId = b.TransId
	WHERE t.PostedYn = 1 and ct.TransType = 0
	GROUP BY t.DepartmentID, t.EarningCode

	INSERT INTO #tmpEarn(DepartmentID, SH, SP )
	SELECT t.DepartmentID, SUM(t.HoursWorked) SH, SUM(t.Pieces) SP 
	FROM dbo.tblPaCheckEarn t
	INNER JOIN #PostTransList b ON t.CheckId = b.TransId
	GROUP BY t.DepartmentID

	
	INSERT INTO #tmpEarnCode(DepartmentID,EarningCode, SE)
	SELECT t.DepartmentID, t.EarningCode, SUM(t.EarningAmount) SE
	FROM dbo.tblPaCheckEarn t
	INNER JOIN #PostTransList b ON t.CheckId = b.TransId	
	GROUP BY t.DepartmentID, t.EarningCode

	--Post Employer Taxes/Costs update dept amounts
	INSERT INTO #tmpAT(DepartmentID, WithholdingCode,  TaxAuthorityId,SAT)
	SELECT DepartmentID, WithholdingCode,  TaxAuthorityId, SUM(AllocTax) SAT
	FROM #tmpPaAllocTax 
	GROUP BY DepartmentID, WithholdingCode,  TaxAuthorityId

	INSERT INTO #tmpAC(DepartmentID,DeductionCode,SAC)
	SELECT DepartmentID,DeductionCode, SUM(AllocCost) SAC
	FROM #tmpPaAllocCost
	GROUP BY DepartmentID,DeductionCode



	INSERT INTO dbo.tblPaDeptDtlAmount(DeptDtlId, PaYear, PaMonth, Amount, EntryDate)
	SELECT d.Id, @PaYear, @iMonth, - t.SH, @DateOnCheck 
	FROM (dbo.tblPaDeptDtl d INNER JOIN #tmpTrans t ON d.DepartmentId = t.DepartmentId) 
	WHERE d.Type =  @Hours 
	UNION ALL 
	SELECT d.Id, @PaYear, @iMonth, - t.SP, @DateOnCheck 
	FROM (dbo.tblPaDeptDtl d INNER JOIN #tmpTrans t ON d.DepartmentId = t.DepartmentId) 
	WHERE d.Type = @Pieces 
	UNION ALL 
	SELECT d.Id, @PaYear, @iMonth, -t.SE, @DateOnCheck 
	FROM (dbo.tblPaDeptDtl d INNER JOIN #tmpTransE t ON d.Code = t.EarningCode and d.DepartmentId = t.DepartmentId) 
	WHERE d.Type = @Earnings 

	IF(@Accrual = 1) -- via transaction
	BEGIN
		INSERT INTO dbo.tblPaDeptDtlAmount(DeptDtlId, PaYear, PaMonth, Amount, EntryDate)
		SELECT d.Id,@PaYear, @iMonth, -t.Amount, @DateOnCheck 
		FROM dbo.tblPaTransEarn t 
		INNER JOIN  dbo.tblPaCheckTrans ct on t.Id = ct.TransId  AND ct.TransType = 0
		INNER JOIN  dbo.tblPaDeptDtl d on t.DepartmentId = d.DepartmentId
		INNER JOIN #PostTransList b ON  ct.CheckId = b.TransId 
		INNER JOIN dbo.tblPaEarnCode e ON t.EarningCode= e.Id 
		WHERE d.Type = @AccruedWages AND d.Code = 'ACW'	AND e.IncludeInNet =1	
	END

	INSERT INTO dbo.tblPaDeptDtlAmount(DeptDtlId, PaYear, PaMonth, Amount, EntryDate)
	SELECT d.Id, @PaYear, @iMonth, t.SP , @DateOnCheck 
	FROM (dbo.tblPaDeptDtl d INNER JOIN #tmpEarn t ON d.DepartmentId = t.DepartmentId) 
	WHERE d.Type =  @Pieces 
	UNION ALL
	SELECT  d.Id, @PaYear, @iMonth, t.SH, @DateOnCheck 
	FROM (dbo.tblPaDeptDtl d INNER JOIN #tmpEarn t ON d.DepartmentId = t.DepartmentId) 
	WHERE d.Type =  @Hours
	UNION ALL
	SELECT d.Id, @PaYear, @iMonth, t.SE, @DateOnCheck 
	FROM (dbo.tblPaDeptDtl d INNER JOIN #tmpEarnCode t ON d.Code = t.EarningCode AND d.DepartmentId = t.DepartmentId) 
	WHERE d.Type = @Earnings 	


	INSERT INTO dbo.tblPaDeptDtlAmount(DeptDtlId, PaYear, PaMonth, Amount, EntryDate)
	SELECT  d.Id, @PaYear, @iMonth, Alloc.SAT, @DateOnCheck
	FROM tblPaDeptDtl d 
	INNER JOIN #tmpAT AS Alloc ON d.DepartmentId = Alloc.DepartmentId AND d.Code = Alloc.WithholdingCode AND d.TaxAuthorityId = Alloc.TaxAuthorityId

	INSERT INTO dbo.tblPaDeptDtlAmount(DeptDtlId, PaYear, PaMonth, Amount, EntryDate)
	SELECT  d.Id, @PaYear, @iMonth, Cost.SAC, @DateOnCheck
	FROM dbo.tblPaDeptDtl d 
	INNER JOIN #tmpAC AS Cost ON d.DepartmentId = Cost.DepartmentId and d.Code = Cost.DeductionCode 
	WHERE d.Type = @Deductions 
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_UpdateDept_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_UpdateDept_proc';

