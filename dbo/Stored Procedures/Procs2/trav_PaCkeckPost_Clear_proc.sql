
CREATE PROCEDURE dbo.trav_PaCkeckPost_Clear_proc
AS
BEGIN TRY

--	/* clear Chk tables */

--PET:http://webfront:801/view.php?id=227413
--PET:http://webfront:801/view.php?id=229971

		DECLARE @PaYear smallint, @PdEnd datetime


		SELECT @PaYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'
        SELECT @PdEnd = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'PdEnd'



	IF @PaYear IS NULL OR @PdEnd IS NULL

	BEGIN
		RAISERROR(90025,16,1)
	END


	DELETE dbo.tblPaTransEarn 
		FROM dbo.tblPaTransEarn 
		INNER JOIN  dbo.tblPaCheckTrans ct on dbo.tblPaTransEarn.Id = ct.TransId
		INNER JOIN #PostTransList b ON b.TransId = ct.CheckId

	DELETE dbo.tblPaTransDeduct 
		FROM dbo.tblPaTransDeduct
		INNER JOIN  dbo.tblPaCheckTrans ct on dbo.tblPaTransDeduct.Id = ct.TransId
		INNER JOIN #PostTransList b ON b.TransId = ct.CheckId

	DELETE dbo.tblPaTransEmplrCost 
		FROM dbo.tblPaTransEmplrCost
		INNER JOIN  dbo.tblPaCheckTrans ct on dbo.tblPaTransEmplrCost.Id = ct.TransId
		INNER JOIN #PostTransList b ON b.TransId = ct.CheckId

   
	DELETE  dbo.tblPaCheck from dbo.tblPaCheck 
    inner Join #PostTransList i on i.TransId = dbo.tblPaCheck.Id


    DELETE  dbo.tblPaCheckDeduct from dbo.tblPaCheckDeduct  
    inner Join #PostTransList i on i.TransId = dbo.tblPaCheckDeduct.CheckId  
	
     
    DELETE dbo.tblPaCheckDistribution from dbo.tblPaCheckDistribution  
    inner Join #PostTransList i on i.TransId = dbo.tblPaCheckDistribution.CheckId  

	
    DELETE dbo.tblPaCheckEarn from dbo.tblPaCheckEarn 
    inner Join #PostTransList i on i.TransId = dbo.tblPaCheckEarn.CheckId

	DELETE dbo.tblPaCheckEmplrCost from dbo.tblPaCheckEmplrCost
    inner Join #PostTransList i on i.TransId = dbo.tblPaCheckEmplrCost.CheckId

	DELETE dbo.tblPaCheckEmplrTax from dbo.tblPaCheckEmplrTax
    inner Join #PostTransList i on i.TransId = dbo.tblPaCheckEmplrTax.CheckId

    DELETE dbo.tblPaCheckLeave from dbo.tblPaCheckLeave
    inner Join #PostTransList i on i.TransId = dbo.tblPaCheckLeave.CheckId

	
    DELETE dbo.tblPaCheckPosPay from dbo.tblPaCheckPosPay
    inner Join #PostTransList i on i.TransId = dbo.tblPaCheckPosPay.CheckNumber 
    


    DELETE dbo.tblPaCheckWithhold from dbo.tblPaCheckWithhold
    inner Join #PostTransList i on i.TransId = dbo.tblPaCheckWithhold.CheckId 

	
--increment payroll number
	UPDATE dbo.tblPaYear_Common SET PayrollNum = PayrollNum + 1
    WHERE PaYear = @PaYear

	 
--declare @PaYear smallint
--set @PaYear = 2010
--   

    DELETE dbo.tblPaCheckInfoGroup  from dbo.tblPaCheckInfoGroup g 
    Inner Join dbo.tblPaCheckInfo i on g.InfoId = i.Id WHERE i.PaYear = @PaYear


    DELETE FROM dbo.tblPaCheckInfo WHERE dbo.tblPaCheckInfo.PaYear = @PaYear
	
	DELETE dbo.tblPaCheckTrans FROM dbo.tblPaCheckTrans inner Join #PostTransList i on i.TransId = dbo.tblPaCheckTrans.CheckId 



END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCkeckPost_Clear_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCkeckPost_Clear_proc';

