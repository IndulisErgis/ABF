
CREATE PROCEDURE dbo.trav_PaCheckPost_UpdateEmployee_proc
AS
BEGIN TRY

--PET:http://webfront:801/view.php?id=226812
--PET:http://webfront:801/view.php?id=240903
--PET:http://webfront:801/view.php?id=255002

				Declare @DateOnCheck datetime, @PaYear smallint
				SELECT @DateOnCheck = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DateOnCheck'
				SELECT @PaYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'

	
   IF @DateOnCheck IS NULL 

	BEGIN
		RAISERROR(90025,16,1)
	END


	UPDATE dbo.tblPaEmployee SET dbo.tblPaEmployee.LastCheckDate = @DateOnCheck,Overridepay=0
	FROM dbo.tblPaCheck INNER JOIN dbo.tblPaEmployee
	ON dbo.tblPaCheck.EmployeeId =dbo.tblPaEmployee.EmployeeId 
	inner Join  dbo.tblSmEmployee
    on dbo.tblSmEmployee.EmployeeId = dbo.tblPaEmployee.EmployeeId

			

UPDATE dbo.tblPaEmpDeduct SET dbo.tblPaEmpDeduct.Balance =
V.SumB
--Select V.EmployeeID, V.DeductionCodeId, V.SumB
FROM 
(
select f.EmployeeID, f.DeductionCodeId, min(DiffBalance) as SumB
from
   (
   select c.EmployeeID, d.Id as DeductionCodeId, cd.CheckId, 
	cd.DeductionBalance DeductionBalance,  cd.DeductionAmount DeductionAmount, (cd.DeductionBalance - cd.DeductionAmount) DiffBalance
		FROM dbo.tblPaCheck c INNER JOIN dbo.tblPaCheckDeduct cd 
		ON c.Id = cd.CheckId 
        Inner Join dbo.tblPaDeductCode d
		on cd.DeductionCode = d.DeductionCode
		 WHERE  d.EmployerPaid = 0 and cd.DeductionBalance > 0 
	) f GROUP BY f.EmployeeID, f.DeductionCodeId
) V
Inner JOIN dbo.tblPaEmpDeduct ON V.DeductionCodeId = dbo.tblPaEmpDeduct.DeductionCodeId
			AND V.EmployeeId = dbo.tblPaEmpDeduct.EmployeeId 
			and dbo.tblPaEmpDeduct.PaYear =@PaYear


UPDATE dbo.tblPaEmpDeduct SET dbo.tblPaEmpDeduct.Balance = V.SumB
--Select V.EmployeeID, V.DeductionCodeId, V.SumB
FROM 
(
select f.EmployeeID, f.DeductionCodeId, min(DiffBalance) SumB
from
   (
   select c.EmployeeID, d.Id as DeductionCodeId, 
   cd.DeductionBalance DeductionBalance, cd.DeductionAmount DeductionAmount, (cd.DeductionBalance - cd.DeductionAmount)  DiffBalance 
		FROM dbo.tblPaCheck c INNER JOIN dbo.tblPaCheckEmplrCost cd 
		ON c.Id = cd.CheckId 
        Inner Join dbo.tblPaDeductCode d
		on cd.DeductionCode = d.DeductionCode
		 WHERE d.EmployerPaid = 1 and cd.DeductionBalance > 0
   ) f GROUP BY f.EmployeeID, f.DeductionCodeId
) V
INNER JOIN dbo.tblPaEmpDeduct ON V.DeductionCodeId = dbo.tblPaEmpDeduct.DeductionCodeId
			AND V.EmployeeId = dbo.tblPaEmpDeduct.EmployeeId 
				and dbo.tblPaEmpDeduct.PaYear = @PaYear
				
			
	


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_UpdateEmployee_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_UpdateEmployee_proc';

