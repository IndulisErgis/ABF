
CREATE PROCEDURE [dbo].[trav_PaCreateTblMagMed_sp]


@PaYear smallint,
@CompName varchar(30)

AS

SET NOCOUNT ON
BEGIN TRY

--PET:http://webfront:801/view.php?id=229833
--PET:http://webfront:801/view.php?id=229852
--PET:http://webfront:801/view.php?id=229922
--PET:http://webfront:801/view.php?id=229968
--PET:http://webfront:801/view.php?id=230000

 --SELECT @PaYear= Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'
 --SELECT @CompName= Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'CompName' 
 --drop table #tmpEmployeeList
--CREATE TABLE #tmpEmployeeList(EmployeeId pEmpID NULL, StartDate datetime NULL,  TerminationDate datetime PRIMARY KEY CLUSTERED ([EmployeeId] ))
--INSERT INTO #tmpEmployeeList (EmployeeId, StartDate, TerminationDate) SELECT EmployeeId, StartDate, TerminationDate FROM dbo.tblPaEmployee
 
 
-- #tmpVendorList
   
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




--declare  @PaYear  smallint
--declare @CompName varchar(40)
--set  @CompName  = 'CPU'
--set  @PaYear  = 2010

--drop table #tmpEmployeeList
--create table #tmpEmployeeList (EmployeeId  pEmpID)

--INSERT INTO #tmpEmployeeList (EmployeeId)
--Select EmployeeId from  dbo.tblPaEmployee


delete from dbo.tblPaPrepMagMed
 
INSERT INTO dbo.tblPaPrepMagMed (EmployeeId, LastName, FirstName, MiddleInit
	, BoxB, BoxC, BoxC1, BoxA, AddressLine1, AddressLine2, BoxE, BoxF1, BoxF2, BoxF3, BoxF4
	, Box15a, Box15b, Box15c, Box15f, Box16a, Box16b, SumOfBox17, SumOfBox18, SumOfBox20
	, SumOfBox21, SumOfBox1, SumOfBox2, SumOfBox3, SumOfBox4, SumOfBox5, SumOfBox6
	, SumOfBox7, SumOfBox8, SumOfBox9, SumOfBox10, SumOfBox11, SumOfBox12, SumOfBox13Line1
	, SumOfBox13Line2, SumOfBox13Line3, SumOfBox14Line1, Box13LineDesc1, Box13LineDesc2
	, SumOfBox14Line2, SumOfBox14Line3, Box13LineDesc3, StartDate, TerminDate) 
	
SELECT w.EmployeeId, e.LastName, e.FirstName, e.MiddleInit
	, w.BoxB, w.BoxC, w.BoxC1, w.BoxA, LEFT(e.AddressLine1, 35), LEFT(e.AddressLine2, 35)
	, w.BoxE, w.BoxF1, w.BoxF2, w.BoxF3, w.BoxF4
	, (CASE WHEN w.Box15a = 1 THEN - 1 ELSE 0 END) AS Box15a
	, (CASE WHEN w.Box15b = 1 THEN - 1 ELSE 0 END) AS Box15b
	, (CASE WHEN w.Box15c = 1 THEN - 1 ELSE 0 END) AS Box15c
	, (CASE WHEN w.Box15G = 1 THEN - 1 ELSE 0 END) AS Box15G
	, w.Box16A, w.Box16b, SUM([Box17]) AS SumOfBox17, SUM([Box18]) AS SumOfBox18, 0, 0
	, SUM([Box1]) AS SumOfBox1, SUM([Box2]) AS SumOfBox2, SUM([Box3]) AS SumOfBox3
	, SUM([Box4]) AS SumOfBox4, SUM([Box5]) AS SumOfBox5, SUM([Box6]) AS SumOfBox6
	, SUM([Box7]) AS SumOfBox7, SUM([Box8]) AS SumOfBox8, SUM([Box9]) AS SumOfBox9
	, SUM([Box10]) AS SumOfBox10, SUM([Box11]) AS SumOfBox11, SUM([Box12]) AS SumOfBox12
	, SUM([Box13Line1]) AS SumOfBox13Line1, SUM([Box13Line2]) AS SumOfBox13Line2
	, SUM([Box13Line3]) AS SumOfBox13Line3, SUM([Box14Line1]) AS SumOfBox14Line1
	, w.Box13LineDesc1, w.Box13LineDesc2, SUM(w.Box14Line2) AS SumOfBox14Line2
	, SUM(w.Box14Line3) AS SumOfBox14Line3, w.Box13LineDesc3,  p.StartDate,  p.TerminationDate 
FROM dbo.tblPaW2 w 
INNER JOIN dbo.tblSmEmployee e ON w.EmployeeId = e.EmployeeId
INNER Join  dbo.tblPaEmployee p ON w.EmployeeId = e.EmployeeId 
INNER Join 
#tmpEmployeeList ee on ee.EmployeeId = e.EmployeeId  and w.EmployeeId = e.EmployeeId
and ee.EmployeeId  = p.EmployeeId 
GROUP BY w.EmployeeId, e.LastName, e.FirstName, e.MiddleInit, w.BoxB, w.BoxC, w.BoxC1, w.BoxA
	, e.AddressLine1, e.AddressLine2, w.BoxE, w.BoxF1, w.BoxF2, w.BoxF3, w.BoxF4
	, (CASE WHEN w.Box15a = 1 THEN - 1 ELSE 0 END)
	, (CASE WHEN w.Box15b = 1 THEN - 1 ELSE 0 END)
	, (CASE WHEN w.Box15c = 1 THEN - 1 ELSE 0 END)
	, (CASE WHEN w.Box15G = 1 THEN - 1 ELSE 0 END)
	, w.Box16A, w.Box16b, w.Box13LineDesc1, w.Box13LineDesc2, w.Box13LineDesc3, p.StartDate, p.TerminationDate 
HAVING (((w.BoxE) <> 'STATE TOTALS' AND (w.BoxE) <> 'GRAND TOTALS')
and  ((SUM([Box5]) = 0 and (SUM([Box17]) + SUM([Box18])) > 0) or  SUM([Box5]) <> 0)
) ORDER BY e.LastName



--Select * From  dbo.tblPaEmployee
--declare  @PaYear smallint
--set @PaYear = 2010

--'Weeks Worked'
UPDATE dbo.tblPaPrepMagMed SET WeeksNo = CASE WHEN Box16a <> 'PR' THEN ROUND(mm.Amount, 0) ELSE 0 END 
--SELECT P.EmployeeID,  Amount
FROM dbo.tblPaPrepMagMed P INNER JOIN 
(
Select P.EmployeeID, sum(M.Amount) Amount from dbo.tblPaEmpHistMisc M INNER JOIN dbo.tblPaPrepMagMed P
ON P.EmployeeID = M.EmployeeID AND M.MiscCodeId = 2 and M.PaYear = @PaYear
and P.SumOfBox5 <> 0 
group by P.EmployeeID, M.MiscCodeId
) mm
on P.EmployeeID = mm.EmployeeID

--declare @PaYear smallint
--set @PaYear = 2010

UPDATE dbo.tblPaPrepMagMed SET StateCode = T.NumericCode, ReportPeriod = '12' + CONVERT(varchar (4), @PaYear) 
-- SELECT P.EmployeeID, P.Box16a, T.PaYear, T.NumericCode, P.StateCode, ReportPeriod
FROM dbo.tblPaPrepMagMed P 
	INNER JOIN st.dbo.tblPASTStateTaxCodeHdr T ON P.Box16a = T.[State] AND T.PaYear = @PaYear

--Select * From dbo.tblPaPrepMagMed

----Select * From dbo.tblPaEmpFedWithhold
UPDATE dbo.tblPaPrepMagMed SET CivilStatus = T.MaritalStatus 
-- SELECT P.EmployeeID, T.MaritalStatus, P.CivilStatus
FROM dbo.tblPaPrepMagMed P 
	INNER JOIN  dbo.tblPaEmpWithhold T ON P.EmployeeID = T.EmployeeID 
WHERE P.CivilStatus IS NULL AND Box16a = 'PR'


UPDATE dbo.tblPaPrepMagMed 
	SET Territories = CASE WHEN  Box16a IN (SELECT Box16a FROM dbo.tblPaPrepMagMed WHERE Box16a IN ('PR', 'VI', 'AS', 'GU', 'MP')) 
				THEN 1 ELSE 0 END 
-- SELECT Territories, Box16a  
FROM dbo.tblPaPrepMagMed P

UPDATE dbo.tblPaPrepMagMed 
	SET UncollOASDIMed = CASE WHEN ((Box13LineDesc1 = 'A' OR Box13LineDesc1 = 'B') AND (Box13LineDesc2 = 'A' OR Box13LineDesc2 = 'B')) 
					THEN SumOfBox13Line1 + SumOfBox13Line2 ELSE 
					CASE WHEN (Box13LineDesc1 = 'A' OR Box13LineDesc1 = 'B') THEN  SumOfBox13Line1 ELSE 0 END END 
-- SELECT P.Box13LineDesc1, P.Box13LineDesc2, P.SumOfBox13Line1, P.SumOfBox13Line2, UncollOASDIMed
FROM dbo.tblPaPrepMagMed P

-- SELECT * FROM #tmpBox12

SELECT e.EmployeeID, SUM(e.Amount) AS Amount, LEFT(c.W2Code, 1) AS DescCode 
INTO #tmpBox11 
FROM dbo.tblPaEarnCode c
	INNER JOIN dbo.tblPaEmpHistEarn e ON c.Id = e.EarningCode
	Inner Join #tmpEmployeeList ee on ee.EmployeeId = e.EmployeeId
WHERE c.W2Box = '11' and e.PaYear = @PaYear  
GROUP BY e.EmployeeId, c.W2Code


INSERT INTO #tmpBox11 
SELECT  d.EmployeeID, SUM(d.Amount) AS Amount,  LEFT(c.W2Code, 1) AS DescCode 
FROM dbo.tblPaEmpHistDeduct d 
	INNER JOIN dbo.tblPaDeductCode c ON d.DeductionCode = c.DeductionCode 
	Inner Join #tmpEmployeeList ee on ee.EmployeeId = d.EmployeeId
WHERE c.W2Box = '11' and d.PaYear = @PaYear  
GROUP BY d.EmployeeId, c.W2Code


DELETE FROM #tmpBox11 WHERE Amount = 0

UPDATE dbo.tblPaPrepMagMed SET NON457 = COALESCE (T.Amount, 0) 
-- SELECT P.EmployeeID, NON457, T.Amount, T.DescCode
FROM dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox11 T ON P.EmployeeID = T.EmployeeID AND ISNULL(T.DescCode, '') = ''
	 and P.SumOfBox5 <> 0 

UPDATE dbo.tblPaPrepMagMed  SET sec457 = COALESCE (T.Amount, 0) 
-- SELECT P.EmployeeID, sec457, T.Amount, T.DescCode
FROM dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox11 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'G'
	 and P.SumOfBox5 <> 0 


--drop taBLE  #tmpBox12

--declare   @PaYear smallint
--set @PaYear = 2010
 
SELECT e.EmployeeID, SUM(e.Amount) AS Amount, LEFT(c.W2Code, 2) AS DescCode, 0 AS EmployerPaid
INTO #tmpBox12 
FROM dbo.tblPaEarnCode c 
	INNER JOIN dbo.tblPaEmpHistEarn e ON c.Id = e.EarningCode 
	Inner Join #tmpEmployeeList ee on ee.EmployeeId = e.EmployeeId
WHERE c.W2Box = '12' and e.PaYear = @PaYear  
GROUP BY e.EmployeeId, c.W2Code

--declare   @PaYear smallint
--set @PaYear = 2010

INSERT INTO #tmpBox12 
SELECT  d.EmployeeID,  SUM(d.Amount) AS Amount
	,  LEFT(c.W2Code, 2) AS DescCode, c.EmployerPaid
FROM dbo.tblPaEmpHistDeduct d 
	Inner Join #tmpEmployeeList ee on ee.EmployeeId = d.EmployeeId
	INNER JOIN dbo.tblPaDeductCode c ON d.DeductionCode = c.DeductionCode 
WHERE c.W2Box = '12' and d.PaYear = @PaYear  
GROUP BY d.EmployeeId, c.W2Code, c.EmployerPaid

INSERT INTO #tmpBox12
Select v.EmployeeId, sum(v.WithholdingEarnings) Amount, LEFT(v.W2Code,2) AS DescCode, 1
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


--Select * from tblPaEmpHistEarn
--Select * from dbo.tblPaEarnCode 
-- DROP  TABLE #tmpBox12

-- SELECT * FROM  #tmpBox12

--Select * From  dbo.tblPaDeductCode

DELETE FROM #tmpBox12 WHERE Amount = 0

	 
UPDATE dbo.tblPaPrepMagMed  SET dbo.tblPaPrepMagMed.GTLI = COALESCE (TT.Amount, 0)
--SELECT M.EmployeeID 
FROM 
(SElect sum(T.Amount) Amount, T.EmployeeID
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'C'
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID) TT
	WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 

	 
	 
	 

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DesigRothContrAA = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'AA' 
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 


---Select * FROM dbo.tblPaPrepMagMed
 

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DesigRothContrBB  = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'BB' 
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 





--UPDATE dbo.tblPaPrepMagMed SET DefCompD = COALESCE (sum(T.Amount), 0) 
---- SELECT P.EmployeeID, DefCompD, T.Amount, T.DescCode
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'D'
--	WHERE P.SumOfBox5 <> 0 
--	group by  P.EmployeeID 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DefCompD = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'D' 
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 


--UPDATE dbo.tblPaPrepMagMed SET DefCompE = COALESCE (sum(T.Amount), 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'E'
--	WHERE P.SumOfBox5 <> 0 
--	group by  P.EmployeeID 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DefCompE = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID, T.DescCode
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'E' 
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID, T.DescCode ) TT
	 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 
	 
	 


--UPDATE dbo.tblPaPrepMagMed SET DefCompF = COALESCE (sum(Amount), 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'F'
--	WHERE P.SumOfBox5 <> 0 
--	group by  P.EmployeeID 
UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DefCompF = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'F' 
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	 	 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 



--UPDATE dbo.tblPaPrepMagMed SET DefCompG = COALESCE (sum(Amount), 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'G'
--	WHERE P.SumOfBox5 <> 0 
--	group by  P.EmployeeID 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DefCompG = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'G' 
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 

--UPDATE dbo.tblPaPrepMagMed SET DefCompH = COALESCE (sum(Amount), 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'H'
--	WHERE P.SumOfBox5 <> 0 
--group by  P.EmployeeID 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DefCompH = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'H' 
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 
 
--UPDATE dbo.tblPaPrepMagMed SET MedSavAccount = COALESCE (sum(Amoun), 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'R'
--	WHERE P.SumOfBox5 <> 0 
--group by  P.EmployeeID 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.MedSavAccount  = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'R' 
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 

--UPDATE tblPaPrepMagMed SET UncollRRTA = COALESCE (sum(Amount), 0) 
--FROM tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'M'
--	WHERE P.SumOfBox5 <> 0
--	group by  P.EmployeeID  

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.UncollRRTA = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'M' 
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	   WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 

--UPDATE dbo.tblPaPrepMagMed SET UncollMed = COALESCE (sum(Amount), 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'N'
--WHERE P.SumOfBox5 <> 0 
--group by  P.EmployeeID 

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.UncollMed = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'N'
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
   WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 
--UPDATE dbo.tblPaPrepMagMed SET SimpRetAccount = COALESCE (sum(Amount), 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'S'
--	WHERE P.SumOfBox5 <> 0 
--	group by  P.EmployeeID 

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.SimpRetAccount= COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'S'
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 
	

--UPDATE dbo.tblPaPrepMagMed SET QualAdopExp = COALESCE (sum(Amount), 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'T'
--	WHERE P.SumOfBox5 <> 0 
--	group by  P.EmployeeID 

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.QualAdopExp = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'T'
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	 	 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 

--UPDATE dbo.tblPaPrepMagMed SET ExercNonStatOpt = COALESCE (sum(Amount), 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'V'
--WHERE P.SumOfBox5 <> 0 
--group by  P.EmployeeID 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.ExercNonStatOpt = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'V'
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 

--UPDATE dbo.tblPaPrepMagMed SET HSAW = COALESCE (sum(Amount), 0) 

--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'W'
--WHERE P.SumOfBox5 <> 0 
--group by  P.EmployeeID 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.HSAW = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'W'
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 

--UPDATE dbo.tblPaPrepMagMed SET NonTaxCmbPay = COALESCE (sum(Amount), 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'Q'
-- WHERE P.SumOfBox5 <> 0 
--group by  P.EmployeeID 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.NonTaxCmbPay = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'Q'
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 
	 

--UPDATE dbo.tblPaPrepMagMed SET Def409ANonQDC = COALESCE (sum(Amount), 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'Y'
--	WHERE P.SumOfBox5 <> 0 
--group by  P.EmployeeID 

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.Def409ANonQDC = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'Y'
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 


--UPDATE dbo.tblPaPrepMagMed SET Inc409ANonQDC = COALESCE (sum(Amount), 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'Z'
--WHERE P.SumOfBox5 <> 0 
--group by  P.EmployeeID 

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.Inc409ANonQDC = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'Z'
	WHERE  P.SumOfBox5 <> 0 
	 group by  T.EmployeeID ) TT
	   WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 

	
--	UPDATE dbo.tblPaPrepMagMed SET PRCommissions  = COALESCE (Amount, 0) 
--FROM dbo.tblPaPrepMagMed P 
--	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'CC'
	
		
	UPDATE dbo.tblPaPrepMagMed SET PRCommissions  = COALESCE (Amount, 0) 
--SElect T.EmployeeId, T.Amount,  T.DescCode, T.EmployerPaid, Box16a
FROM dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'CC'
	WHERE SumOfBox5 <> 0 
	
	
	
	
	SELECT * FROM dbo.tblPaPrepMagMed 	
	

--SELECT EmployeeId, BoxF1, BoxF2, BoxF3, BoxF4, StateRec, SumOfBox1, SumOfBox2
--	, SumOfBox3, SumOfBox4, SumOfBox5, SumOfBox6, SumOfBox7, SumOfBox8, SumOfBox9
--	, SumOfBox10, SumOfBox11, SumOfBox12, Box16a INTO #tmpPaPrepMagMedFed 
--FROM tblPaPrepMagMed WHERE Box16a = 'PR'
--
--SELECT F.EmployeeId, M.SumOfBox1, M.SumOfBox2, M.SumOfBox3, M.SumOfBox4, M.SumOfBox5, M.SumOfBox6
--	, M.SumOfBox7, M.SumOfBox8, M.SumOfBox9, M.SumOfBox10, M.SumOfBox11, M.SumOfBox12 
--INTO #tmpPaPrepMagMedPR 
--FROM #tmpPaPrepMagMedFed F 
--	INNER JOIN tblPaPrepMagMed M ON F.EmployeeId = M.EmployeeId 
--WHERE (((M.SumOfBox1) <> 0)) OR (((M.SumOfBox2) <> 0)) OR (((M.SumOfBox3) <> 0)) OR (((M.SumOfBox4) <> 0))
--
--UPDATE tblPaPrepMagMed 
--	SET tblPaPrepMagMed.SumOfBox1 = PR.SumOfBox1
--		, tblPaPrepMagMed.SumOfBox2 = PR.SumOfBox2
--		, tblPaPrepMagMed.SumOfBox3 = PR.SumOfBox3
--		, tblPaPrepMagMed.SumOfBox4 = PR.SumOfBox4
--		, tblPaPrepMagMed.SumOfBox5 = PR.SumOfBox5
--		, tblPaPrepMagMed.SumOfBox6 = PR.SumOfBox6
--		, tblPaPrepMagMed.SumOfBox7 = PR.SumOfBox7
--		, tblPaPrepMagMed.SumOfBox8 = PR.SumOfBox8
--		, tblPaPrepMagMed.SumOfBox9 = PR.SumOfBox9
--		, tblPaPrepMagMed.SumOfBox10 = PR.SumOfBox10
--		, tblPaPrepMagMed.SumOfBox11 = PR.SumOfBox11
--		, tblPaPrepMagMed.SumOfBox12 = PR.SumOfBox12 
--FROM tblPaPrepMagMed 
--	INNER JOIN #tmpPaPrepMagMedPR PR ON PR.EmployeeId = tblPaPrepMagMed.EmployeeId 
--WHERE (((tblPaPrepMagMed.SumOfBox1) = 0) OR ((tblPaPrepMagMed.SumOfBox2) = 0) 
--	OR ((tblPaPrepMagMed.SumOfBox3) = 0) OR ((tblPaPrepMagMed.SumOfBox4) = 0))
--
--DELETE FROM tblPaPrepMagMed WHERE tblPaPrepMagMed.SumOfBox1 = 0 
--	AND tblPaPrepMagMed.SumOfBox2 = 0 AND tblPaPrepMagMed.SumOfBox3 = 0 
--	AND tblPaPrepMagMed.SumOfBox4 = 0 AND tblPaPrepMagMed.SumOfBox5 = 0 
--	AND tblPaPrepMagMed.SumOfBox6 = 0 AND tblPaPrepMagMed.SumOfBox7 = 0 
--	AND tblPaPrepMagMed.SumOfBox17 = 0 AND tblPaPrepMagMed.SumOfBox18 = 0

--INSERT INTO tblPaPrepMagMed2 (EmployeeId, BoxA, FirstName, MiddleInit, LastName, Suffix
--	, BoxB, BoxC, BoxC1, BoxE, AddressLine1, AddressLine2, BoxF1, BoxF2, BoxF3, BoxF4
--	, StateRec, SumOfBox1, SumOfBox2, SumOfBox3, SumOfBox4, SumOfBox5, SumOfBox6
--	, SumOfBox7, SumOfBox8, SumOfBox9, SumOfBox10, SumOfBox11, SumOfBox12
--	, Box15a, Box15F, Box15c, Box15b, chkThirdPartySP, DesigRothContrAA
--	, DesigRothContrBB, DefCompD, DefCompE, DefCompF, DefCompG, DefCompH, Military
--	, NON457, sec457, GTLI, HSAW, NonTaxCmbPay, Def409ANonQDC, Inc409ANonQDC
--	, SumOfBox17, SumOfBox18, SumOfBox20, SumOfBox21, SUITotWages, SUITotTaxWages
--	, Box16b, Box16a, OptionalCode, ReportPeriod, StartDate, TerminDate, StateCode
--	, OtherStateData, SupplData1, SupplData2, StateControlNo, WeeksNo, TaxTypeCode) 
--SELECT EmployeeId, BoxA, FirstName, MiddleInit, LastName, Suffix, BoxB, BoxC, BoxC1, BoxE
--	, AddressLine1, AddressLine2, BoxF1, BoxF2, BoxF3, BoxF4, StateRec, SumOfBox1
--	, SumOfBox2, SumOfBox3, SumOfBox4, SumOfBox5, SumOfBox6, SumOfBox7, SumOfBox8
--	, SumOfBox9, SumOfBox10, SumOfBox11, SumOfBox12, Box15a, Box15F, Box15c, Box15b
--	, chkThirdPartySP, DesigRothContrAA, DesigRothContrBB, DefCompD, DefCompE, DefCompF
--	, DefCompG, DefCompH, Military, NON457, sec457, GTLI, HSAW, NonTaxCmbPay, Def409ANonQDC
--	, Inc409ANonQDC, SumOfBox17, SumOfBox18, SumOfBox20, SumOfBox21, SUITotWages, SUITotTaxWages
--	, Box16b, Box16a, OptionalCode, ReportPeriod, StartDate, TerminDate, StateCode, OtherStateData
--	, SupplData1, SupplData2, StateControlNo, WeeksNo, TaxTypeCode 
--FROM tblPaPrepMagMed




END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.10203.1229', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCreateTblMagMed_sp';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 13344', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCreateTblMagMed_sp';

