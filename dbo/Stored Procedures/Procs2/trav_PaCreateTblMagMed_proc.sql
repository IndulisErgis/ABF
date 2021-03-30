
CREATE PROCEDURE [dbo].[trav_PaCreateTblMagMed_proc]


@PaYear smallint,
@CompName nvarchar(30)

AS

SET NOCOUNT ON
BEGIN TRY

--CREATE TABLE #tmpEmployeeList(EmployeeId pEmpID NOT NULL PRIMARY KEY CLUSTERED ([EmployeeId]))
--INSERT INTO #tmpEmployeeList (EmployeeId) SELECT EmployeeId FROM dbo.tblPaEmployee

 
-- #tmpVendorList
   
   if @PaYear = 0

	BEGIN
		RAISERROR(90025,16,1)
	END

declare @StartDate datetime 
declare @EndDate datetime

select @StartDate =  Cast(Cast(@PaYear as nvarchar(4)) + '0319' as datetime) 
select @EndDate =  Cast(Cast(@PaYear as nvarchar(4)) + '1231' as datetime) 





--declare  @PaYear  smallint
--declare @CompName nvarchar(40)
--set  @CompName  = 'CPU'
--set  @PaYear  = 2010

--drop table #tmpEmployeeList
--create table #tmpEmployeeList (EmployeeId  pEmpID)

--INSERT INTO #tmpEmployeeList (EmployeeId)
--Select EmployeeId from  dbo.tblPaEmployee

--Select * from  #tmpEmployeeList


delete from dbo.tblPaPrepMagMed
 
INSERT INTO dbo.tblPaPrepMagMed (EmployeeId, LastName, FirstName, MiddleInit
	, BoxB, BoxC, BoxC1, BoxA, AddressLine1, AddressLine2, 
	 BoxE, BoxF1, BoxF2, BoxF3, BoxF4
	, Box15a, Box15b, Box15c, Box15f, Box16a, Box16b, SumOfBox17, SumOfBox18, 
	  SumOfBox1, SumOfBox2, SumOfBox3, SumOfBox4, SumOfBox5, SumOfBox6
	, SumOfBox7, SumOfBox8, SumOfBox9, SumOfBox10, SumOfBox11, SumOfBox12, SumOfBox13Line1
	, SumOfBox13Line2, SumOfBox13Line3, SumOfBox14Line1, Box13LineDesc1, Box13LineDesc2
	, SumOfBox14Line2, SumOfBox14Line3, Box13LineDesc3, StartDate, TerminDate, SumOfBox20, SumOfBox21) 
	
SELECT w.EmployeeId, e.LastName, e.FirstName, e.MiddleInit
	, w.BoxB, w.BoxC, w.BoxC1, w.BoxA, LEFT(e.AddressLine1, 35), LEFT(e.AddressLine2, 35)
	, w.BoxE, w.BoxF1, w.BoxF2, w.BoxF3, w.BoxF4
	, (CASE WHEN w.Box15a = 1 THEN - 1 ELSE 0 END) AS Box15a
	, (CASE WHEN w.Box15b = 1 THEN - 1 ELSE 0 END) AS Box15b
	, (CASE WHEN w.Box15c = 1 THEN - 1 ELSE 0 END) AS Box15c
	, (CASE WHEN w.Box15G = 1 THEN - 1 ELSE 0 END) AS Box15G
	, w.Box16A, w.Box16b, SUM([Box17]) AS SumOfBox17, SUM([Box18]) AS SumOfBox18
	, SUM([Box1]) AS SumOfBox1, SUM([Box2]) AS SumOfBox2, SUM([Box3]) AS SumOfBox3
	, SUM([Box4]) AS SumOfBox4, SUM([Box5]) AS SumOfBox5, SUM([Box6]) AS SumOfBox6
	, SUM([Box7]) AS SumOfBox7, SUM([Box8]) AS SumOfBox8, SUM([Box9]) AS SumOfBox9
	, SUM([Box10]) AS SumOfBox10, SUM([Box11]) AS SumOfBox11, SUM([Box12]) AS SumOfBox12
	, SUM([Box13Line1]) AS SumOfBox13Line1, SUM([Box13Line2]) AS SumOfBox13Line2
	, SUM([Box13Line3]) AS SumOfBox13Line3, SUM([Box14Line1]) AS SumOfBox14Line1
	, w.Box13LineDesc1, w.Box13LineDesc2, SUM(w.Box14Line2) AS SumOfBox14Line2
	, SUM(w.Box14Line3) AS SumOfBox14Line3, w.Box13LineDesc3,  p.StartDate,  p.TerminationDate 
	, SUM(w.Box20) AS SumOfBox20, SUM(w.Box21) AS SumOfBox21

	
FROM dbo.tblPaW2 w 
INNER JOIN dbo.tblSmEmployee e ON w.EmployeeId = e.EmployeeId
INNER Join  dbo.tblPaEmployee p ON w.EmployeeId = e.EmployeeId 
INNER Join 
#tmpEmployeeList ee on ee.EmployeeId = e.EmployeeId  and w.EmployeeId = e.EmployeeId
and ee.EmployeeId  = p.EmployeeId 
GROUP BY w.EmployeeId, e.LastName, e.FirstName, e.MiddleInit, w.BoxB, w.BoxC, w.BoxC1, w.BoxA
	, e.AddressLine1, e.AddressLine2, w.BoxE, w.BoxF1, w.BoxF2, w.BoxF3, w.BoxF4, w.Box19, w.Box19a
	, (CASE WHEN w.Box15a = 1 THEN - 1 ELSE 0 END)
	, (CASE WHEN w.Box15b = 1 THEN - 1 ELSE 0 END)
	, (CASE WHEN w.Box15c = 1 THEN - 1 ELSE 0 END)
	, (CASE WHEN w.Box15G = 1 THEN - 1 ELSE 0 END)
	, w.Box16A, w.Box16b, w.Box13LineDesc1, w.Box13LineDesc2, w.Box13LineDesc3, p.StartDate, p.TerminationDate 
HAVING (((w.BoxE) <> 'STATE TOTALS' AND (w.BoxE) <> 'GRAND TOTALS')
--and  
--((SUM([Box1])+ SUM([Box2])+ SUM([Box3])+ SUM([Box4]) +  SUM([Box5])+ SUM([Box6]) <> 0) 
--or ((SUM([Box1])+ SUM([Box2])+ SUM([Box3])+ SUM([Box4]) +  SUM(w.[Box5])+ SUM(w.[Box6])= 0)
--and (SUM([Box17]) + SUM([Box18])+SUM([Box20])+ SUM([Box21]) > 0)))
and  ((SUM([Box1])+ SUM([Box2])+ SUM([Box3])+ SUM([Box4]) +  SUM([Box5])+ SUM([Box6])= 0 and (SUM([Box17]) + SUM([Box18])) > 0) or  SUM([Box1])+ SUM([Box2])+ SUM([Box3])+ SUM([Box4]) +  SUM([Box5])+ SUM([Box6]) <> 0)

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
and P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
group by P.EmployeeID, M.MiscCodeId
) mm
on P.EmployeeID = mm.EmployeeID

--declare @PaYear smallint
--set @PaYear = 2010

UPDATE dbo.tblPaPrepMagMed SET StateCode = T.NumericCode, ReportPeriod = '12' + CONVERT(nvarchar (4), @PaYear) 
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


--The PRCommissions is no longer in use for PR

--Separated UncollOASDI and UncollMedicare
--UncollOASDI will be set to UncollOASDIMed  and UncollMedicare in PRCommissions
--It will be combined in MMREF


--UPDATE dbo.tblPaPrepMagMed 
--	SET UncollOASDIMed = CASE WHEN ((Box13LineDesc1 = 'A' OR Box13LineDesc1 = 'B') AND (Box13LineDesc2 = 'A' OR Box13LineDesc2 = 'B')) 
--					THEN SumOfBox13Line1 + SumOfBox13Line2 ELSE 
--					CASE WHEN (Box13LineDesc1 = 'A' OR Box13LineDesc1 = 'B') THEN  SumOfBox13Line1 ELSE 0 END END 
---- SELECT P.Box13LineDesc1, P.Box13LineDesc2, P.SumOfBox13Line1, P.SumOfBox13Line2, UncollOASDIMed
--FROM dbo.tblPaPrepMagMed P



-- SELECT * FROM #tmpBox12

SELECT e.EmployeeID, SUM(e.Amount) AS Amount, LEFT(c.W2Code, 1) AS DescCode 
INTO #tmpBox11 
FROM dbo.tblPaEarnCode c
	INNER JOIN dbo.tblPaEmpHistEarn e ON c.Id = e.EarningCode
	Inner Join #tmpEmployeeList ee on ee.EmployeeId = e.EmployeeId
WHERE c.W2Box = '11' and e.PaYear = @PaYear  
GROUP BY e.EmployeeId, c.W2Code


INSERT INTO #tmpBox11 
SELECT  d.EmployeeID, case when SUM(d.Amount) > 0 then SUM(d.Amount) else 0 end AS Amount,  LEFT(c.W2Code, 1) AS DescCode 
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
	 and P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0

UPDATE dbo.tblPaPrepMagMed  SET sec457 = COALESCE (T.Amount, 0) 
-- SELECT P.EmployeeID, sec457, T.Amount, T.DescCode
FROM dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox11 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'G'
	 and P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0


--drop taBLE  #tmpBox12

--declare   @PaYear smallint
--set @PaYear = 2010
 
 
 --'Uncollected OASDI' 13
 
 --declare   @PaYear smallint
 --set @PaYear = 2011
 

SELECT e.EmployeeID, sum(e.Amount) AS Amount, Convert(nvarchar(2),'A') AS DescCode
--,  0 AS EmployerPaid 
INTO #tmpBox12
FROM dbo.tblPaEmpHistMisc e 
Inner Join #tmpEmployeeList ee on ee.EmployeeId = e.EmployeeId
WHERE e.MiscCodeId = 13 and PaYear = @PaYear
group by e.EmployeeID, e.MiscCodeId, e.PaYear


--'Uncollected MEDICARE' 14

 --declare   @PaYear smallint
 --set @PaYear = 2011
 

INSERT INTO #tmpBox12
SELECT e.EmployeeID, sum(e.Amount) AS Amount, 'B' AS DescCode
--, 0 AS EmployerPaid
FROM dbo.tblPaEmpHistMisc e
Inner Join #tmpEmployeeList ee on ee.EmployeeId = e.EmployeeId
WHERE e.MiscCodeId = 14 and e.PaYear = @PaYear
group by e.EmployeeID, e.MiscCodeId, e.PaYear


 
 
INSERT INTO #tmpBox12 
SELECT e.EmployeeID, SUM(e.Amount) AS Amount, LEFT(c.W2Code, 2) AS DescCode
--, 0 AS EmployerPaid
FROM dbo.tblPaEarnCode c 
	INNER JOIN dbo.tblPaEmpHistEarn e ON c.Id = e.EarningCode 
	Inner Join #tmpEmployeeList ee on ee.EmployeeId = e.EmployeeId
WHERE c.W2Box = '12' and e.PaYear = @PaYear  
GROUP BY e.EmployeeId, c.W2Code

--declare   @PaYear smallint
--set @PaYear = 2010

--INSERT INTO #tmpBox12 
--declare   @PaYear smallint
--set @PaYear = 2011

--SELECT  d.EmployeeID,  SUM(d.Amount) AS Amount
--	,  LEFT(c.W2Code, 2) AS DescCode, c.EmployerPaid
--FROM dbo.tblPaEmpHistDeduct d 
--	Inner Join #tmpEmployeeList ee on ee.EmployeeId = d.EmployeeId
--	INNER JOIN dbo.tblPaDeductCode c ON d.DeductionCode = c.DeductionCode 
--WHERE c.W2Box = '12' and d.PaYear = @PaYear  
--GROUP BY d.EmployeeId, c.W2Code, c.EmployerPaid


INSERT INTO #tmpBox12
SELECT  d.EmployeeID, case when Sum(d.Amount) > 0 then  Sum(d.Amount) else 0 end Amount, LEFT(c.W2Code,2)  DescCode
--, c.EmployerPaid
FROM dbo.tblPaEmpHistDeduct d 
Inner Join #tmpEmployeeList ee on ee.EmployeeId = d.EmployeeId
INNER JOIN dbo.tblPaDeductCode c ON
	d.DeductionCode = c.DeductionCode
WHERE 
(d.PaYear = @PaYear and c.W2Box='12' AND d.EmployerPaid =0 AND c.EmployerPaid =0) or 
(d.PaYear = @PaYear and c.W2Box='12' AND d.EmployerPaid = 1 AND c.EmployerPaid =1) 
GROUP BY d.EmployeeId, c.W2Code
--, c.EmployerPaid


DELETE FROM #tmpBox12 WHERE Amount = 0


--The PRCommissions is no longer in use for PR

--Separated UncollOASDI and UncollMedicare
--UncollOASDI will be set to UncollOASDIMed  and UncollMedicare in PRCommissions
--It will be combined in MMREF
	

UPDATE dbo.tblPaPrepMagMed  SET dbo.tblPaPrepMagMed.UncollOASDIMed  = COALESCE (TT.Amount, 0)
 
FROM 
(SElect sum(T.Amount) Amount, T.EmployeeID
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'A'
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID) TT
	WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	--and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 


UPDATE dbo.tblPaPrepMagMed  SET dbo.tblPaPrepMagMed.PRCommissions  = COALESCE (TT.Amount, 0)

FROM 
(SElect sum(T.Amount) Amount, T.EmployeeID
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'B'
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID) TT
	WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	--and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 



	 
UPDATE dbo.tblPaPrepMagMed  SET dbo.tblPaPrepMagMed.GTLI = COALESCE (TT.Amount, 0)
--SELECT M.EmployeeID 
FROM 
(SElect sum(T.Amount) Amount, T.EmployeeID
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'C'
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID) TT
	WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	--and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 

	 
	 

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DesigRothContrAA = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'AA' 
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	  and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	  --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 


 

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DesigRothContrBB  = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'BB' 
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0 
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID
	  and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	  -- and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 



UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.EmplrCostSpsCovrg  = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'DD' 
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	  and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	  --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 
	  
	  
	  
	  
UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.ContrUnder457b  = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'EE' 
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	  and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	  --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 



UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DefCompD = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'D' 
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
	 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	 and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	 --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 



UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DefCompE = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID, T.DescCode
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'E' 
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID, T.DescCode ) TT
	 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	 and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	 --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 
	 
	 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DefCompF = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'F' 
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0 
	 group by  T.EmployeeID ) TT
	 	 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID
		 and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
		 -- and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 





UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DefCompG = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'G' 
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
 and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
 --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 



UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.DefCompH = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'H' 
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
 and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
 --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 
 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.MedSavAccount  = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'R' 
	WHERE P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	  and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	  --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 



UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.UncollRRTA = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'M' 
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0 
	 group by  T.EmployeeID ) TT
	   WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	   and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	   --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.UncollMed = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'N'
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
   WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
   and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
   --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.SimpRetAccount= COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'S'
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
	 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	 and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	 --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 
	


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.QualAdopExp = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'T'
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
	 	 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
		 and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
		 --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 



UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.ExercNonStatOpt = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'V'
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0 
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	  and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	  --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 




UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.HSAW = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'W'
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	  and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	  --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.NonTaxCmbPay = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'Q'
	WHERE  P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
	 WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	 and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	 --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 
	 


UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.Def409ANonQDC = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'Y'
	WHERE P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0 
	 group by  T.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	  and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	--and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 



UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.Inc409ANonQDC = COALESCE (TT.Amount, 0) 

FROM 
(SElect sum(T.Amount) Amount , T.EmployeeID 
from dbo.tblPaPrepMagMed P 
	INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'Z'
	WHERE P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0
	 group by  T.EmployeeID ) TT
	   WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	   and (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6 )<> 0
	   --and dbo.tblPaPrepMagMed.SumOfBox5 <> 0 

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.QSEHRA = COALESCE (TT.Amount, 0) 
FROM 
(
	SELECT SUM(T.Amount) Amount, T.EmployeeID, T.DescCode 
	FROM dbo.tblPaPrepMagMed P 
		INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'FF' 
	WHERE P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0 
	GROUP BY T.EmployeeID, T.DescCode
) TT 
WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	AND (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 
			+ dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6) <> 0

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.GGQEG = COALESCE (TT.Amount, 0) 
FROM 
(
	SELECT SUM(T.Amount) Amount, T.EmployeeID, T.DescCode 
	FROM dbo.tblPaPrepMagMed P 
		INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'GG' 
	WHERE P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0 
	GROUP BY T.EmployeeID, T.DescCode
) TT 
WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	AND (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 
			+ dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6) <> 0

UPDATE dbo.tblPaPrepMagMed SET dbo.tblPaPrepMagMed.HHADF = COALESCE (TT.Amount, 0) 
FROM 
(
	SELECT SUM(T.Amount) Amount, T.EmployeeID, T.DescCode 
	FROM dbo.tblPaPrepMagMed P 
		INNER JOIN #tmpBox12 T ON P.EmployeeID = T.EmployeeID AND T.DescCode = 'HH' 
	WHERE P.SumOfBox1 + P.SumOfBox2 + P.SumOfBox3 + P.SumOfBox4 + P.SumOfBox5 + P.SumOfBox6 <> 0 
	GROUP BY T.EmployeeID, T.DescCode
) TT 
WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID 
	AND (dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 
			+ dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox6) <> 0
	
SELECT * FROM dbo.tblPaPrepMagMed
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCreateTblMagMed_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCreateTblMagMed_proc';

