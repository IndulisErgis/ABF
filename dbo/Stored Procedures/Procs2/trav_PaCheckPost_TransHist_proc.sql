
CREATE PROCEDURE dbo.trav_PaCheckPost_TransHist_proc 
AS
BEGIN TRY

     --PET:http://webfront:801/view.php?id=227220
     --PET:http://webfront:801/view.php?id=227943
     --PET:http://webfront:801/view.php?id=241925
	 --PET:http://webfront:801/view.php?id=251453
	 --PET:http://webfront:801/view.php?id=245493
	 --PET:http://problemtrackingsystem.osas.com/view.php?id=272854

        DECLARE @PostRun pPostRun, @PaYear smallint, @PdEnd datetime, @iMonth tinyint, @DateOnCheck datetime, @GlPeriod smallint 
     
       
        SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	    SELECT @iMonth = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'iMonth'
        SELECT @PdEnd = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'PdEnd'
        SELECT @DateOnCheck = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DateOnCheck'
	    SELECT @GlPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'GlPeriod'
		
	
   IF @PostRun IS NULL

	BEGIN
		RAISERROR(90025,16,1)
	END


   INSERT INTO dbo.tblPaTransEarnHist 
   (PostRun, Id, EmployeeId, EarningCode, DepartmentId, 
	TaxGroup,StateCode, LocalCode, LaborClass, Rate, Pieces, Hours, Amount, TransDate, SUIState,
	SeqNo, CustId, ProjId, PhaseId, TaskId, PaMonth, DeptAllocId, PaYear, LeaveCodeId,
    CheckNumber, CheckId, Voided, CF)

	SELECT @PostRun, c.Id, c.EmployeeId, c.EarningCode, c.DepartmentId, 
	g.TaxGroup,St.[State],  Lt.[local],  c.LaborClass, c.Rate, c.Pieces, c.Hours, 
	c.Amount, c.TransDate, c.SUIState,
	c.SeqNo, c.CustId, c.ProjId, c.PhaseId, c.TaskId, @iMonth, c.DeptAllocId,
	ch.PaYear,  c.LeaveCodeId,  ch.CheckNumber, ct.CheckId,0 as Voided, c.CF
	FROM dbo.tblPaTransEarn c INNER JOIN  dbo.tblPaCheckTrans ct
    on c.Id = ct.TransId
    INNER JOIN dbo.tblPaCheck ch on ch.Id = ct.CheckId 
    INNER JOIN #PostTransList b ON ch.Id = b.TransId
	LEFT JOIN dbo.tblPaTaxGroupHeader g ON c.TaxGroupId = g.ID
	LEFT JOIN 
	(Select e.Id, t.[State] From dbo.tblPaTaxAuthorityHeader t INNER JOIN dbo.tblPaTransEarn e  
	on e.StateTaxAuthorityId = t.Id WHERE [State] IS NOT NULL group by  e.Id, t.[State]) St
	on St.Id = c.Id and c.Id =  ct.TransId
	LEFT JOIN 
	(Select e.Id, t.[TaxAuthority] as [Local]  From dbo.tblPaTaxAuthorityHeader t INNER JOIN dbo.tblPaTransEarn e  
	on e.LocalTaxAuthorityId = t.Id WHERE [Local] IS NOT NULL) Lt
	on Lt.Id = c.Id AND c.Id =  ct.TransId
	WHERE ct.TransType = 0
	


	Insert Into dbo.tblPaTransDeductHist(
	PostRun, Id, PaYear, PaMonth, EmployeeId, DeductCode, LaborClass, Hours,
	Amount, TransDate, SeqNo, Note, CheckNumber, CheckId, Voided, CF)
	Select @PostRun, c.Id, ch.PaYear, @iMonth, c.EmployeeId,  c.DeductCode, c.LaborClass, c.Hours, 
	c.Amount, c.TransDate, c.SeqNo, c.Note, ch.CheckNumber, v.CheckId, 0 as Voided, c.CF 
	FROM dbo.tblPaTransDeduct c Inner Join 
	dbo.tblPaCheckTrans ct  on c.Id = ct.TransId
	Inner Join dbo.tblPaCheck ch on ch.Id = ct.CheckId 
	INNER JOIN #PostTransList b ON ch.Id = b.TransId
	Inner Join 
	(
	Select c.CheckId, c.DeductionCode from
	dbo.tblPaCheckDeduct c 
	 group by   c.CheckId, c.DeductionCode) v
	on v.DeductionCode = c.DeductCode and v.CheckId = ch.Id
	WHERE ct.TransType = 1




	INSERT INTO dbo.tblPaTransEmplrCostHist(
	PostRun, Id,  PaYear, PaMonth, EmployeeId,  DeductCode, DepartmentId, LaborClass, Hours, 
	Amount,TransDate,SeqNo, Note, CheckNumber, CheckId , Voided, CF) 
	Select @PostRun, c.Id, ch.PaYear, @iMonth, c.EmployeeId,  c.DeductCode, v.DepartmentId, c.LaborClass, c.Hours, 
	 c.Amount, c.TransDate, c.SeqNo, c.Note, ch.CheckNumber, v.CheckId, 0 as Voided, c.CF
	FROM dbo.tblPaTransEmplrCost c Inner Join 
	dbo.tblPaCheckTrans ct  on c.Id = ct.TransId
	Inner Join dbo.tblPaCheck ch on ch.Id = ct.CheckId 
		INNER JOIN #PostTransList b ON ch.Id = b.TransId 
	Inner Join 
	(
	Select c.CheckId, c.DeductionCode, c.DepartmentId from
	dbo.tblPaCheckEmplrCost c 
	 group by   c.CheckId, c.DeductionCode, c.DepartmentId) v
	on v.DeductionCode = c.DeductCode and v.CheckId = ch.Id
	WHERE ct.TransType = 2



 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_TransHist_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_TransHist_proc';

