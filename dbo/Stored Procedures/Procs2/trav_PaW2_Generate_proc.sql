
CREATE PROCEDURE [dbo].[trav_PaW2_Generate_proc]
@PaYear smallint
AS

--PET:[235931]
--PET:http://webfront:801/view.php?id=249407
--declare @CompName nvarchar(30)

BEGIN TRY

--set nocount on

--@FicaLimit changed to 106,800 to 110,100

declare @FicaLimit decimal(28,10)
DECLARE
@BoxC   nvarchar(50),
@BoxB      nvarchar(17),
@BoxC1   nvarchar(70),
@BoxC2 nvarchar(50)


 --declare @PaYear int

 --SELECT @PaYear= Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'
  
   
   if @PaYear = 0

	BEGIN
		RAISERROR(90025,16,1)
	END


DELETE FROM dbo.tblPaW2


Insert INTO dbo.tblPaW2(EmployeeID, BOX1, Box2, Box3, Box4, Box5, Box6, Box9,FirstLine)
select EmployeeId,
	SUM(case WHEN withholdingcode='FWH' then TaxableAmount else 0 end) AS BOX1,
	SUM(case WHEN withholdingcode='FWH' then WithholdAmount else 0 end) AS BOX2,
	SUM(case WHEN withholdingcode='OAS' then TaxableAmount else 0 end) AS BOX3,
	SUM(case WHEN withholdingcode='OAS' then WithholdAmount  else 0 end) AS BOX4,
	SUM(case WHEN withholdingcode='MED' then TaxableAmount else 0 end) AS BOX5,
	SUM(case WHEN withholdingcode='MED' then WithholdAmount else 0 end) AS BOX6,
	--SUM(case WHEN withholdingcode='EIC' then ABS(WithholdAmount) else 0 end) AS BOX9,
	0 AS BOX9,
	1
from dbo.tblPaEmpHistWithhold where TaxAuthorityType=0 and EmployerPaid=0 and  PaYear = @PaYear and (WithholdAmount <> 0 or TaxableAmount <> 0) 
group by EmployeeId


--Select * From dbo.tblPaEmpHistWithhold

--IF @@ROWCOUNT=0 return 9  --nothing to prepare


Select @FicaLimit = Column2 FROM ST..tblPASTTaxTablesDtl WHERE TableId='FED__FIC' AND Status='NA'
AND SequenceNumber = 1 AND PaYear = @PaYear
SET @FicaLimit=Coalesce(@FicaLimit,0)


--MISC FOR BOX1,BOX3,BOX5,BOX8,BOX10,BOX11

-- Box7

Update dbo.tblPaW2 SET BOX7 = T.Box7, 
Box3 = CASE WHEN (Box3 - T.Box7) > @FicaLimit 
THEN @FicaLimit ELSE (Box3 - T.Box7) END
from dbo.tblPaW2 
INNER JOIN 
(Select H.EmployeeID, PaYear, case when sum(H.Amount) < @FicaLimit Then sum(H.Amount) ELSE @FicaLimit END AS BOX7
FROM dbo.tblPaEmpHistMisc H INNER JOIN dbo.tblPaW2 T
ON H.EmployeeID = T.EmployeeID
WHERE MiscCodeId = 11 AND PaYear = @PaYear group by
H.EmployeeID, H.PaYear) T 
ON dbo.tblPaW2.EmployeeID=T.EmployeeID




UPDATE dbo.tblPaW2 SET BOX8 = a.ALLOCATEDTIPS                        
FROM 
(SELECT EmployeeID,  SUM(Amount) AS ALLOCATEDTIPS
FROM dbo.tblPaEmpHistMisc WHERE MiscCodeId = 5 AND PaYear = @PaYear
GROUP BY EmployeeID) a
INNER JOIN tblPaW2 b
ON a.EmployeeID = b.EmployeeID





update dbo.tblPaW2 SET Box8 = W.Box8 + T.Box8
from dbo.tblPaW2 W 
INNER JOIN 
(Select employeeid, sum(Amount) BOX8 
FROM tblPaEmpHistEarn H INNER JOIN dbo.tblPaEarnCode EC
	ON H.EarningCode = EC.Id
WHERE EC.W2Box='8' AND  H.PaYear = @PaYear
GROUP BY EmployeeID) T 
ON W.EmployeeID=T.EmployeeID


--INTO #tmpBox10  ---Box10

UPDATE dbo.tblPaW2 set BOX10 = a.DCB
FROM 
(
Select DCB.employeeid, sum(DCB.BOX10) DCB
	from
	(
	select H.employeeid,  sum(H.Amount) BOX10
	FROM tblPaEmpHistEarn H INNER JOIN dbo.tblPaEarnCode EC
		ON H.EarningCode = EC.Id
	WHERE EC.W2Box='10'  AND H.PaYear = @PaYear
	GROUP BY  H.EmployeeID
	union All
	select H.employeeid,  case when sum(H.Amount) > 0 then sum(H.Amount) else 0 end BOX10
	FROM tblPaEmpHistDeduct H INNER JOIN tblPaDeductCode EC 
		ON H.DeductionCode = EC.DeductionCode and H.EmployerPaid =  EC.EmployerPaid
	WHERE EC.W2Box='10' AND H.PaYear = @PaYear
	GROUP BY  H.EmployeeID, H.EmployerPaid
	) DCB
GROUP BY  DCB.EmployeeID) a
 INNER JOIN dbo.tblPaW2 b
ON a.EmployeeID = b.EmployeeID





Update dbo.tblPaW2 SET Box11 = W.Box11 + T.Box11
from dbo.tblPaW2 W
INNER JOIN 
(Select employeeid, sum(Amount) BOX11
FROM dbo.tblPaEmpHistEarn H INNER JOIN dbo.tblPaEarnCode EC
	ON H.EarningCode = EC.Id
WHERE EC.W2Box='11' AND H.PaYear = @PaYear
GROUP BY EmployeeID)
T ON W.EmployeeID=T.EmployeeID

--#tmpBox12 --Box12

Update dbo.tblPaW2 SET Box12 = T.Box12
from dbo.tblPaW2 INNER JOIN 
(Select Employeeid, sum(Amount) BOX12
FROM tblPaEmpHistEarn H INNER JOIN tblPaEarnCode EC
	ON H.EarningCode = EC.Id
WHERE EC.W2Box='12' AND H.PaYear = @PaYear
GROUP BY H.EmployeeID) T
ON dbo.tblPaW2.EmployeeID=T.EmployeeID


--call box13 routine here
--exec @ret = qryPaW2_Others



     
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaW2_Generate_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaW2_Generate_proc';

