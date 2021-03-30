
CREATE PROCEDURE [dbo].[trav_PaW2_Others_sp]
@PaYear smallint
AS
BEGIN TRY



DECLARE @Count int, @13Count int, @14Count int
DECLARE @NewCreated bit
---PET:http://webfront:801/view.php?id=229661
 --declare @PaYear int

 --SELECT @PaYear= Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'
  
   
   if @PaYear = 0

	BEGIN
		RAISERROR(90025,16,1)
	END


declare @StartDate datetime
declare @EndDate datetime

select @StartDate =  Cast(Cast(@PaYear as varchar(4)) + '0319' as datetime) 
select @EndDate =  Cast(Cast(@PaYear as varchar(4)) + '1231' as datetime) 

Create table #EmpRef

( EmpNum [int] IDENTITY (1, 1) NOT NULL ,
  EmployeeId varchar(11),
  HireAct bit
)
--update #EmpRef set HireAct = 1 where EmployeeId = '1000'

--Capture the employee HireAct settings 
--	(use dynamic SQL for referencing the custom field value)

EXEC('SET QUOTED_IDENTIFIER ON ;
Insert Into #EmpRef (EmployeeId, HireAct )
Select e.EmployeeId, case when v.[cf_Hire Act] IS NULL then 0 else  v.[cf_Hire Act] end from dbo.tblPaEmployee e
INNER Join dbo.trav_tblSmEmployee_view v on e.EmployeeId = v.EmployeeId')



--'Uncollected OASDI' 13

SELECT EmployeeID, sum(Amount) AS Amount, Convert(varchar(2),'A') AS Description 
INTO #tmpBox13
FROM dbo.tblPaEmpHistMisc
WHERE MiscCodeId = 13 and PaYear = @PaYear
group by EmployeeID, MiscCodeId, PaYear


--'Uncollected MEDICARE' 14

INSERT INTO #tmpBox13
SELECT EmployeeID, sum(Amount) AS Amount, 'B' AS Description
FROM dbo.tblPaEmpHistMisc
WHERE MiscCodeId = 14 and PaYear = @PaYear
group by EmployeeID, MiscCodeId, PaYear


--INSERT INTO #tmpBox13
--SELECT EmployeeID, YTD, 'C'
--FROM tblPaEmpHistMisc
--WHERE CodeDesc='Cost of GTLI'

INSERT INTO #tmpBox13
SELECT e.EmployeeID, Sum(e.Amount) Amount, LEFT(c.W2Code,1)  Description
FROM dbo.tblPaEarnCode c INNER JOIN dbo.tblPaEmpHistEarn e ON
	c.Id = e.EarningCode
WHERE c.W2Box='12' and e.PaYear = @PaYear
GROUP BY e.EmployeeId, c.W2Code


INSERT INTO #tmpBox13
SELECT  EmployeeID, Sum(d.Amount) Amount, LEFT(c.W2Code,2)  Description
FROM dbo.tblPaEmpHistDeduct d INNER JOIN dbo.tblPaDeductCode c ON
	d.DeductionCode = c.DeductionCode
WHERE d.PaYear = @PaYear and (c.W2Box='12' AND d.EmployerPaid =0 AND c.EmployerPaid =0) or 
(c.W2Box='12' AND d.EmployerPaid = 1 AND c.EmployerPaid =1)
GROUP BY d.EmployeeId, c.W2Code


INSERT INTO #tmpBox13

Select v.EmployeeId, sum(v.WithholdingEarnings) Amount, LEFT(v.W2Code,2)  Description
from 
(
SElect t.PostRun, t.CheckId, 'CC' W2Code, h.EmployeeId, t.WithholdingEarnings 
from dbo.tblPaCheckHistEmplrTax t INNEr Join dbo.tblPaCheckHist h  on 
h.PostRun = t.PostRun AND h.Id = t.CheckId 
INNER JOIn #EmpRef tmp on  h.EmployeeId = tmp.EmployeeId
WHERE  t.WithholdingCode = 'EOA'and h.Voided <> 1 and tmp.HireAct = 1
and t.WithholdingEarnings  <> 0  
and h.CheckDate BETWEEN @StartDate AND @EndDate) v
group by  v.EmployeeId, v.W2Code


--Select * from #tmpBox13
DELETE FROM #tmpBox13 WHERE Amount=0


--setup box14
SELECT e.EmployeeID, Sum(e.Amount) Amount, 
Case When IsNULL(convert(varchar(10), c.W2Code), '') <> '' 
then convert(varchar(10), c.W2Code) else convert(varchar(10), e.EarningCode) end as Description,
	'E' + Case When IsNULL(convert(varchar(10), c.W2Code), '') <> '' 
then convert(varchar(10), c.W2Code) else convert(varchar(10), e.EarningCode) end as LineCode
INTO #tmpBox14
FROM dbo.tblPaEarnCode c INNER JOIN dbo.tblPaEmpHistEarn e ON
	c.Id = e.EarningCode
WHERE c.W2Box='14' and e.PaYear = @PaYear
GROUP BY e.EmployeeId, c.W2Code, e.EarningCode



INSERT INTO #tmpBox14
SELECT  d.EmployeeID, Sum(d.Amount) Amount,  LEFT(c.W2Code,10)  Description,
	'D' + Cast(c.W2Code AS varchar(4)) LineCode
FROM dbo.tblPaEmpHistDeduct d INNER JOIN dbo.tblPaDeductCode c ON
	d.DeductionCode = c.DeductionCode
WHERE c.W2Box='14' and d.PaYear = @PaYear
--AND EmployerPaidFlag=0 AND ERFlag='E'
GROUP BY d.EmployeeId, c.W2Code


--exclude NJ; unique method required
INSERT INTO #tmpBox14

SELECT w.EmployeeID, sum(w.WithholdAmount) Amount, LEFT(td.Description,10)  Description, 
	'O' + Cast(w.WithholdingCode AS varchar(4)) LineCode
FROM dbo.tblPaEmpHistWithhold w 
Left Join  dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYear
	on 	w.State = th.State  and w.WithholdingCode = td.Code and w.EmployerPaid = td.EmployerPaid 
WHERE w.EmployerPaid = 0  and  w.PaYear = @PaYear and w.TaxAuthorityType  = 1 and td.CodeType =0 AND w.State <> 'NJ'
GROUP BY w.EmployeeID, w.State, w.WithholdingCode, td.Description

--INNER JOIN dbo.tblPaStateTaxCodeDtl b ON
--a.WithholdingCode = b.Code AND a.TaxAuthority = b.State
--WHERE b.Type = 'other' AND b.State <> 'NJ' AND b.ERFlag='E' AND a.EmployerPaidFlag=0


----handle NJ 12/14/2000 -- JRS
----so2 and so3
--INSERT INTO #tmpBox14
--SELECT a.EmployeeID, Sum(a.WithholdYtd), 'UI/WF/SWF', 
--	'NJ141' LineCode
--FROM dbo.tblPaEmpHistoryWithhold a INNER JOIN dbo.tblPaStateTaxCodeDtl b ON
--a.WithholdingCode = b.Code AND a.TaxAuthority = b.State
--WHERE b.Type = 'other' AND b.State = 'NJ' AND (b.Code = 'SO2' OR b.Code = 'SO3')
--	AND b.ERFlag='E' AND a.EmployerPaidFlag=0
--GROUP BY a.employeeid


--handle NJ 12/14/2000 -- JRS
--so2 and so3
INSERT INTO #tmpBox14

SELECT w.EmployeeID, Sum(w.WithholdAmount) Amount, 'UI/WF/SWF' Description, 
	'NJ141' LineCode
FROM dbo.tblPaEmpHistWithhold w 
Left Join  dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYear
	on 	w.State = th.State  and w.WithholdingCode = td.Code and w.EmployerPaid = td.EmployerPaid 
WHERE w.EmployerPaid = 0  and  w.PaYear = @PaYear and w.TaxAuthorityType  = 1 and td.CodeType =0 
AND w.State = 'NJ'  AND (w.WithholdingCode = 'SO2' OR w.WithholdingCode = 'SO3')
GROUP BY w.EmployeeID


--so1
INSERT INTO #tmpBox14

SELECT w.EmployeeID, Sum(w.WithholdAmount) Amount, 'DI', 
	'NJ142' LineCode
FROM dbo.tblPaEmpHistWithhold w 
Left Join  dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYear
	on 	w.State = th.State  and w.WithholdingCode = td.Code and w.EmployerPaid = td.EmployerPaid 
WHERE w.EmployerPaid = 0  and  w.PaYear = @PaYear and w.TaxAuthorityType  = 1 and td.CodeType =0 
AND w.State = 'NJ'  AND w.WithholdingCode = 'SO1'
GROUP BY w.EmployeeID
 


--so4
UPDATE dbo.tblPaW2 SET NJFLIAmt = t.Total
FROM (SELECT w.EmployeeId, Sum(w.WithholdAmount) AS Total 
FROM dbo.tblPaEmpHistWithhold w 
Left Join  dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYear
	on 	w.State = th.State  and w.WithholdingCode = td.Code and w.EmployerPaid = td.EmployerPaid 
WHERE w.EmployerPaid = 0  and  w.PaYear = @PaYear and w.TaxAuthorityType  = 1 and td.CodeType =0 
AND w.State = 'NJ'  AND w.WithholdingCode = 'SO4'
GROUP BY w.EmployeeID

) t 
WHERE dbo.tblPaW2.EmployeeId = t.EmployeeId


--local others

INSERT INTO #tmpBox14
SELECT w.EmployeeID, sum(w.WithholdAmount), LEFT(td.Description,10), 
	'Z' + Cast(w.WithholdingCode AS varchar(4)) LineCode
FROM dbo.tblPaEmpHistWithhold w 
Left Join  dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYear
	on 	w.State = th.State and  w.Local = th.Local and w.WithholdingCode = td.Code and w.EmployerPaid = td.EmployerPaid 

WHERE w.EmployerPaid = 0 and  w.PaYear = @PaYear and w.TaxAuthorityType  = 2 and td.CodeType =0
GROUP BY w.EmployeeID, w.State, w.Local, w.WithholdingCode, td.Description




DELETE FROM #tmpBox14 WHERE Amount=0

SELECT @13Count=Count(*) FROM #tmpBox13
SELECT @14Count=Count(*) FROM #tmpBox14
SET @Count = @13Count+@14Count
SET @NewCreated=0

WHILE Coalesce(@count,0) > 0
BEGIN
IF @13Count > 0
BEGIN
	--Line 1
	SELECT EmployeeID, MIN(Description) AS FirstDescr
	INTO #tmpBox13First
	FROM #tmpBox13
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box13Line1= Amount, Box13LineDesc1=Description
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.Description=F.FirstDescr)
		ON B.EmployeeID= dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox13=0

	DELETE #tmpBox13 FROM #tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.Description=F.FirstDescr

	--Line 2
	DELETE FROM #tmpBox13First

	INSERT INTO #tmpBox13First
	SELECT EmployeeID, MIN(Description) AS FirstDescr
	FROM #tmpBox13
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box13Line2= Amount, Box13LineDesc2=Description
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.Description=F.FirstDescr)
		ON B.EmployeeID= dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox13=0

	DELETE #tmpBox13 FROM #tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.Description=F.FirstDescr

	--Line 3
	DELETE FROM #tmpBox13First

	INSERT INTO #tmpBox13First
	SELECT EmployeeID, MIN(Description) AS FirstDescr
	FROM #tmpBox13
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box13Line3= Amount, Box13LineDesc3=Description
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.Description=F.FirstDescr)
		ON B.EmployeeID=dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox13=0

	DELETE #tmpBox13 FROM #tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.Description=F.FirstDescr

	--Line 4
	DELETE FROM #tmpBox13First

	INSERT INTO #tmpBox13First
	SELECT EmployeeID, MIN(Description) AS FirstDescr
	FROM #tmpBox13
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box13Line4= Amount, Box13LineDesc4=Description
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.Description=F.FirstDescr)
		ON B.EmployeeID=dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox13=0

	DELETE #tmpBox13 FROM #tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.Description=F.FirstDescr



	SELECT @13Count=Count(*) FROM #tmpBox13
	SET @13Count=Coalesce(@13Count,0)
	DROP TABLE #tmpBox13First
END --13Count>0

IF @14Count>0
BEGIN
	--Line 1
	SELECT EmployeeID, Min(LineCode) LineCode
	INTO #tmpBox14First
	FROM #tmpBox14
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box14Line1= Amount, Box14LineDesc1=Description
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox14 B INNER JOIN #tmpBox14First F 
		ON B.EmployeeID=F.EmployeeID AND B.LineCode=F.Linecode)
		ON B.EmployeeID=dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox14=0

	DELETE #tmpBox14 FROM #tmpBox14 B INNER JOIN #tmpBox14First F 
		ON B.EmployeeID=F.EmployeeID AND B.LineCode=F.Linecode

	--Line 2
	DELETE FROM #tmpBox14First

	INSERT INTO #tmpBox14First
	SELECT EmployeeID, Min(LineCode) LineCode
	FROM #tmpBox14
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box14Line2= Amount, Box14LineDesc2=Description
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox14 B INNER JOIN #tmpBox14First F 
		ON B.EmployeeID=F.EmployeeID AND B.LineCode=F.Linecode)
		ON B.EmployeeID=dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox14=0

	DELETE #tmpBox14 FROM #tmpBox14 B INNER JOIN #tmpBox14First F 
		ON B.EmployeeID=F.EmployeeID AND B.LineCode=F.Linecode

	--Line 3
	DELETE FROM #tmpBox14First

	INSERT INTO #tmpBox14First
	SELECT EmployeeID, Min(LineCode) LineCode
	FROM #tmpBox14
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box14Line3= Amount, Box14LineDesc3=Description
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox14 B INNER JOIN #tmpBox14First F 
		ON B.EmployeeID=F.EmployeeID AND B.LineCode=F.Linecode)
		ON B.EmployeeID=dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox14=0

	DELETE #tmpBox14 FROM #tmpBox14 B INNER JOIN #tmpBox14First F 
		ON B.EmployeeID=F.EmployeeID AND B.LineCode=F.Linecode

	SELECT @14Count=Count(*) FROM #tmpBox14
	SET @14Count=Coalesce(@14Count,0)
	DROP TABLE #tmpBox14First
END --14Count>0
	
	--check if additional records need to be created
	IF @13Count>0
	BEGIN
		UPDATE dbo.tblPaW2 SET AddnlBox13=1 
		WHERE AddnlBox13 = 0
		--create new record
		INSERT INTO dbo.tblPaW2 (EmployeeID)
		SELECT dbo.tblPaW2.EmployeeID
		FROM dbo.tblPaW2 INNER JOIN #tmpBox13 ON dbo.tblPaW2.EmployeeID=#tmpBox13.EmployeeID
		GROUP BY dbo.tblPaW2.EmployeeID
		
		SET @NewCreated=1 --set so box14 routine doesn't create new record
	END
	IF @14Count>0
	BEGIN
		UPDATE dbo.tblPaW2 SET AddnlBox14=1 WHERE AddnlBox14=0
		--create new record
		IF @NewCreated = 0
			INSERT INTO dbo.tblPaW2 (EmployeeID)
			SELECT dbo.tblPaW2.EmployeeID
			FROM dbo.tblPaW2 INNER JOIN #tmpBox14 ON dbo.tblPaW2.EmployeeID=#tmpBox14.EmployeeID
			GROUP BY dbo.tblPaW2.EmployeeID
		SET @NewCreated=0
	END
	
SET @Count=@13Count + @14Count

END --Count>0



     
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.10203.1229', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaW2_Others_sp';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 13344', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaW2_Others_sp';

