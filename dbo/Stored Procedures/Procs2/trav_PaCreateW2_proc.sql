
CREATE PROCEDURE [dbo].[trav_PaCreateW2_proc]


@Year smallint
--@CompName nvarchar(30)

AS

SET NOCOUNT ON
BEGIN TRY

--SELECT @PaYear= Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'
--SELECT @CompName= Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'CompName' 
--drop table #tmpEmployeeList
 
  --drop table #EmployeeList
 
 --CREATE TABLE #tmpEmployeeList (EmployeeId pEmpID NOT NULL PRIMARY KEY CLUSTERED ([EmployeeId]))
 --INSERT INTO #tmpEmployeeList ([EmployeeId]) SELECT  [EmployeeId] FROM dbo.tblPaEmployee
--CREATE TABLE #tmpEmployeeList(EmployeeId pEmpID NULL, StartDate datetime NULL,  TerminationDate datetime PRIMARY KEY CLUSTERED ([EmployeeId] ))
--INSERT INTO #tmpEmployeeList (EmployeeId, StartDate, TerminationDate) SELECT EmployeeId, StartDate, TerminationDate FROM dbo.tblPaEmployee
 --drop table #tmpEmpList
 --CREATE TABLE #tmpEmpList (EmployeeId pEmpID NOT NULL PRIMARY KEY CLUSTERED ([EmployeeId]))
 --INSERT INTO #tmpEmpList ([EmployeeId]) SELECT  [EmployeeId] FROM dbo.tblPaEmployee

 
-- #tmpVendorList
   
   if @Year = 0

	BEGIN
		RAISERROR(90025,16,1)
	END

declare @StartDate datetime 
declare @EndDate datetime

DECLARE @Count int, @13Count int, @14Count int
DECLARE @NewCreated bit


select @StartDate =  Cast(Cast(@Year as nvarchar(4)) + '0319' as datetime) 
select @EndDate =  Cast(Cast(@Year as nvarchar(4)) + '1231' as datetime) 


--declare  @PaYear  smallint
--declare @CompName nvarchar(40)
--set  @CompName  = 'CPU'
--set  @PaYear  = 2012

--drop table #tmpEmployeeList
--create table #tmpEmployeeList (EmployeeId  pEmpID)

--INSERT INTO #tmpEmployeeList (EmployeeId)
--Select EmployeeId from  dbo.tblPaEmployee


 
--#tmpBox11 
--drop table #tmpPaW2
Create Table #tmpPaW2
(
	EmployeeId pEmpId NOT NULL, 
	BoxA nvarchar(255) NULL, 
	BoxB nvarchar(17) NULL, 
	Box16a nvarchar(2) NULL, 
	Box16b nvarchar(20) NULL, 
	FirstLine bit Not Null, 
	BoxE nvarchar(70) NULL, 
	BoxE1 nvarchar(70) NULL, 
	BoxF nvarchar(100) NULL, 
	Box17 pDecimal  Not Null default(0),
	Box18 pDecimal  Not Null default(0),
	Box19 nvarchar(30) NULL,  
	Box19a nvarchar(30) NULL,
	Box21 pDecimal Not Null default(0),   
	Box20 pDecimal Not Null default(0),  
	Box20a pDecimal Not Null default(0),
	Box21a pDecimal Not Null default(0)
)

--Select * from #tmpPaW2
Insert Into #tmpPaW2(EmployeeId, BoxA, BoxB,Box16a, Box16b, FirstLine, BoxE, BoxE1,BoxF, Box17,Box18,Box19, 
Box19a,Box20, Box21,Box20a, Box21a)
SELECT w.EmployeeId, w.BoxA, w.BoxB, w.Box16a, w.Box16b, w.FirstLine,
	w.BoxE, w.BoxE1,w.BoxF, w.Box17,w.Box18,w.Box19, w.Box19a, w.Box20,  w.Box21, w.Box20a, w.Box21a
FROM  dbo.tblPaW2 w 
INNER JOIN dbo.tblSmEmployee e ON w.EmployeeId = e.EmployeeId
INNER Join  dbo.tblPaEmployee p ON w.EmployeeId = e.EmployeeId 
INNER Join 
#tmpEmpList ee on ee.EmployeeId = e.EmployeeId  and w.EmployeeId = e.EmployeeId
and ee.EmployeeId  = p.EmployeeId 
GROUP BY 
 w.EmployeeId, w.BoxA,  w.BoxB, e.LastName, w.BoxE, w.Box16a, w.Box16b, w.FirstLine, 
 w.BoxE1,w.BoxF, w.Box17, w.Box18, w.Box19, w.Box19a, w.Box20,  w.Box21, w.Box20a, w.Box21a
HAVING (((w.BoxE) <> 'STATE TOTALS' AND (w.BoxE) <> 'GRAND TOTALS')
and  (SUM(w.[Box1])+ SUM(w.[Box2])+ SUM(w.[Box3])+ SUM(w.[Box4]) +  SUM(w.[Box5])+ SUM(w.[Box6]) <> 0 or (SUM(w.[Box1])+ SUM(w.[Box2])+ SUM(w.[Box3])+ SUM(w.[Box4]) +  SUM(w.[Box5])+ SUM(w.[Box6])= 0 and (SUM(w.[Box17]) + SUM(w.[Box18])+SUM(w.[Box20])+ SUM(w.[Box21])
) > 0)))

--Select * from dbo.tblPaW2



delete  from dbo.tblPaW2

Update dbo.tblPaPrepMagMed  Set dbo.tblPaPrepMagMed.SumOfBox11 = COALESCE (TT.Amount, 0)
FROM 
(Select P.EmployeeID,  SUM(P.sec457) + SUM(P.NON457) Amount
from dbo.tblPaPrepMagMed P 
	Inner Join #tmpEmpList ee on ee.EmployeeId = P.EmployeeId WHERE  P.sec457 + P.NON457 <> 0
	 group by  P.EmployeeID ) TT
	  WHERE TT.EmployeeID = dbo.tblPaPrepMagMed.EmployeeID and dbo.tblPaPrepMagMed.SumOfBox1 + dbo.tblPaPrepMagMed.SumOfBox2 + dbo.tblPaPrepMagMed.SumOfBox3 + dbo.tblPaPrepMagMed.SumOfBox4 + dbo.tblPaPrepMagMed.SumOfBox5 + dbo.tblPaPrepMagMed.SumOfBox5 <> 0 


--delete  from dbo.tblPaW2
Insert Into dbo.tblPaW2(
	EmployeeID, BoxA,  BoxB, BoxD, BoxE, BoxE1, BoxF, BoxF1,BoxF2 ,BoxF3 ,BoxF4, 
	Box1,Box2,Box3,Box4, Box5,Box6,Box7,Box8,Box9,
	Box10,Box11,Box12,Box13Line1,Box13Line2,Box13Line3,Box13Line4,
	Box14Line1 ,Box14Line2,Box14Line3,
	Box13LineDesc1, Box13LineDesc2, Box13LineDesc3, Box13LineDesc4, 
	Box14LineDesc1, Box14LineDesc2 , Box14LineDesc3,
	Box15a, Box15b ,Box15c, Box15d , Box15e , Box15f , Box15g,
	Box16a ,Box16b ,Box17 , 
	Box18 ,  Box20 , Box21 , 
	Box19, Box19a , Box20a , Box21a , FirstLine, NJFLIAmt , AddnlBox13, AddnlBox14)

	Select m.EmployeeId, tot.BoxA, tot.BoxB, 0 as BoxD, m.BoxE, BoxE1, null as BoxF,  m.BoxF1, m.BoxF2,m.BoxF3, m.BoxF4,
	m.SumOfBox1,m.SumOfBox2,m.SumOfBox3,m.SumOfBox4,m.SumOfBox5, m.SumOfBox6, m.SumOfBox7, m.SumOfBox8, m.SumOfBox9,
	m.SumOfBox10, m.SumOfBox11,m.SumOfBox12, 0 as Box13Line1, 0 as Box13Line2,0 as Box13Line3,0 as Box13Line4, 
	0 as Box14Line1, 0 as Box14Line2, 0 as Box14Line3, 
	NUll as Box13LineDesc1, NUll as Box13LineDesc2,NUll as Box13LineDesc3,NUll Box13LineDesc4,
	NUll as Box14LineDesc1,NUll as Box14LineDesc2,NUll as Box14LineDesc3,
	Coalesce(m.Box15a, 0) Box15a, Coalesce(m.Box15b,0) Box15b, Coalesce(m.Box15c,0) Box15c, 0 as Box15d, Coalesce( m.chkThirdPartySP, 0) as Box15e, Coalesce(m.Box15f,0), 0 as Box15g, 
	m.Box16a, m.Box16b, Coalesce(m.SumOfBox17, 0) as SumOfBox17, 
	Coalesce(m.SumOfBox18, 0) as SumOfBox18, Coalesce(m.SumOfBox20, 0) as  SumOfBox20, Coalesce(m.SumOfBox21, 0) as SumOfBox21,
	tot.Box19, tot.Box19a, tot.Box20a, tot.Box21a,  tot.FirstLine, 0 as NJFLIAmt, 0 as AddnlBox13, 0 as AddnlBox14 
	from dbo.tblPaPrepMagMed m Inner Join
	#tmpPaW2 tot on  tot.EmployeeId = m.EmployeeId  WHERE tot.FirstLine = 1 and 
	( m.SumOfBox1 + m.SumOfBox2 + m.SumOfBox3 + m.SumOfBox4 + m.SumOfBox5 + m.SumOfBox6  <>0 )

  
	ORDER BY  m.LastName
	
	--Select * From #tmpPaW2


--UPDATE dbo.tblPaPrepMagMed 
--	SET UncollOASDIMed = CASE WHEN ((Box13LineDesc1 = 'A' OR Box13LineDesc1 = 'B') AND (Box13LineDesc2 = 'A' OR Box13LineDesc2 = 'B')) 
--					THEN SumOfBox13Line1 + SumOfBox13Line2 ELSE 
--					CASE WHEN (Box13LineDesc1 = 'A' OR Box13LineDesc1 = 'B') THEN  SumOfBox13Line1 ELSE 0 END END 
---- SELECT P.Box13LineDesc1, P.Box13LineDesc2, P.SumOfBox13Line1, P.SumOfBox13Line2, UncollOASDIMed
--FROM dbo.tblPaPrepMagMed P


--The PRCommissions is no longer in use for PR

--Separated UncollOASDI and UncollMedicare
--UncollOASDI will be set to UncollOASDIMed  and UncollMedicare in PRCommissions
--It will be combined in MMREF
--drop table  #tmpBox13
--drop table #tmpBox13upd

Create Table #tmpBox13upd (EmployeeID PEmpID, Amount pDecimal, DescCode nvarchar(2))
Create Table #tmpBox13 (EmployeeID PEmpID, Amount pDecimal, DescCode nvarchar(2))

--declare @Year smallint
--set @Year = 2011

INSERT INTO #tmpBox13upd 
SELECT e.EmployeeID, Sum(e.Amount) Amount, LEFT(c.W2Code,1)  Description
FROM dbo.tblPaEarnCode c INNER JOIN dbo.tblPaEmpHistEarn e ON
	c.Id = e.EarningCode
WHERE c.W2Box='12' and e.PaYear = @Year

GROUP BY e.EmployeeId, c.W2Code


--declare @PaYear smallint
--set @PaYear = 2011

INSERT INTO #tmpBox13upd 
SELECT  EmployeeID, case when Sum(d.Amount) > 0  then Sum(d.Amount) else 0 end Amount, LEFT(c.W2Code,2)  Description
FROM dbo.tblPaEmpHistDeduct d INNER JOIN dbo.tblPaDeductCode c ON
	d.DeductionCode = c.DeductionCode
WHERE  (d.PaYear = @Year and c.W2Box='12' AND d.EmployerPaid =0 AND c.EmployerPaid =0) or 
(d.PaYear = @Year and c.W2Box='12' AND d.EmployerPaid = 1 AND c.EmployerPaid =1)

GROUP BY d.EmployeeId, c.W2Code




--'Uncollected OASDI' 13

Insert Into  #tmpBox13
SELECT c.EmployeeID, SUM(c.UncollOASDIMed)  AS Amount, 'A' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.UncollOASDIMed <>0

	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6  <> 0 
GROUP BY c.EmployeeId


--'Uncollected MEDICARE' 14
Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.PRCommissions)  AS Amount, 'B' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.PRCommissions <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId



Insert Into #tmpBox13(EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.GTLI)  AS Amount, 'C' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.GTLI <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId

Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.DesigRothContrAA)  AS Amount, 'AA' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.DesigRothContrAA <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0  
GROUP BY c.EmployeeId

Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.DesigRothContrBB)  AS Amount, 'BB' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.DesigRothContrBB <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0  
GROUP BY c.EmployeeId



Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.EmplrCostSpsCovrg)  AS Amount, 'DD' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.EmplrCostSpsCovrg <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId

--Select EmplrCostSpsCovrg From  dbo.tblPaPrepMagMed WHERE EmployeeID = 'Nat001'



Insert Into #tmpBox13(EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.DefCompD)  AS Amount, 'D' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.DefCompD <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId



Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.ContrUnder457b)  AS Amount, 'EE' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.ContrUnder457b <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0  
GROUP BY c.EmployeeId



Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.DefCompE)  AS Amount, 'E' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.DefCompE <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId

Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.DefCompF)  AS Amount, 'F' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.DefCompF <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId



Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.DefCompG)  AS Amount, 'G' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.DefCompG <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId


Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.DefCompH)  AS Amount, 'H' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.DefCompH <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId

Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.MedSavAccount)  AS Amount, 'R' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList ee on ee.EmployeeId = c.EmployeeId Where c.MedSavAccount <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId

Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.UncollRRTA)  AS Amount, 'M' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.UncollRRTA <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId



Insert Into #tmpBox13(EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.UncollMed)  AS Amount, 'N' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.UncollMed<>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId



Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.SimpRetAccount)  AS Amount, 'S' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.SimpRetAccount <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId


Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.QualAdopExp)  AS Amount, 'T' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.QualAdopExp <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId

--Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
--SELECT c.EmployeeID, SUM(c.ExercNonStatOpt)  AS Amount, 'V' AS DescCode 
--FROM dbo.tblPaPrepMagMed c
--	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.ExercNonStatOpt <>0
--	and c.SumOfBox5 <> 0 
--GROUP BY c.EmployeeId


Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.ExercNonStatOpt)  AS Amount, 'V' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.ExercNonStatOpt <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0  
GROUP BY c.EmployeeId


Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.HSAW)  AS Amount, 'W' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.HSAW <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0  
GROUP BY c.EmployeeId


Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.NonTaxCmbPay)  AS Amount, 'Q' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.NonTaxCmbPay <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId

Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.Def409ANonQDC)  AS Amount, 'Y' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.Def409ANonQDC <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0  
GROUP BY c.EmployeeId

  Insert Into #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.Inc409ANonQDC)  AS Amount, 'Z' AS DescCode 
FROM dbo.tblPaPrepMagMed c
	Inner Join #tmpEmpList  ee on ee.EmployeeId = c.EmployeeId Where c.Inc409ANonQDC <>0
	and c.SumOfBox1 + c.SumOfBox2  + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0  
GROUP BY c.EmployeeId 

INSERT INTO #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.QSEHRA) AS Amount, 'FF' AS DescCode 
FROM dbo.tblPaPrepMagMed c 
	INNER JOIN #tmpEmpList ee ON ee.EmployeeId = c.EmployeeId WHERE c.QSEHRA <> 0 
		AND c.SumOfBox1 + c.SumOfBox2 + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId

INSERT INTO #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.GGQEG) AS Amount, 'GG' AS DescCode 
FROM dbo.tblPaPrepMagMed c 
	INNER JOIN #tmpEmpList ee ON ee.EmployeeId = c.EmployeeId WHERE c.GGQEG <> 0 
		AND c.SumOfBox1 + c.SumOfBox2 + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId

INSERT INTO #tmpBox13 (EmployeeID, Amount, DescCode) 
SELECT c.EmployeeID, SUM(c.HHADF) AS Amount, 'HH' AS DescCode 
FROM dbo.tblPaPrepMagMed c 
	INNER JOIN #tmpEmpList ee ON ee.EmployeeId = c.EmployeeId WHERE c.HHADF <> 0 
		AND c.SumOfBox1 + c.SumOfBox2 + c.SumOfBox3 + c.SumOfBox4 + c.SumOfBox5 + c.SumOfBox6 <> 0 
GROUP BY c.EmployeeId

DELETE FROM #tmpBox13 WHERE Amount = 0
DELETE FROM #tmpBox13upd WHERE Amount = 0


Insert Into  #tmpBox13(EmployeeID, Amount, DescCode) 
Select u.EmployeeID, u.Amount, u.DescCode 
from #tmpBox13upd u WHERE u.DescCode Not In ('AA', 'C','BB', 'DD', 'EE', 'D', 'E','F','G','H','R', 'M','N', 'S','T', 'V','W','Q','Y','Z', 'FF', 'GG', 'HH') 
order by u.EmployeeID, u.DescCode


	 
--declare @Year smallint
--set @Year = 2011
 --drop table  #tmpBox14
--setup box14
SELECT e.EmployeeID, Sum(e.Amount) Amount, 
Case When IsNULL(convert(nvarchar(10), c.W2Code), '') <> '' 
then convert(nvarchar(10), c.W2Code) else convert(nvarchar(10), e.EarningCode) end as Description,
	'E' + Case When IsNULL(convert(nvarchar(10), c.W2Code), '') <> '' 
then convert(nvarchar(10), c.W2Code) else convert(nvarchar(10), e.EarningCode) end as LineCode, '00' as LocalCode
INTO #tmpBox14
FROM dbo.tblPaEarnCode c INNER JOIN dbo.tblPaEmpHistEarn e ON
	c.Id = e.EarningCode
WHERE c.W2Box='14' and e.PaYear = @Year

GROUP BY e.EmployeeId, c.W2Code, e.EarningCode


--declare @PaYear smallint
--set @PaYear = 2011

INSERT INTO #tmpBox14
SELECT  d.EmployeeID, case when Sum(d.Amount) > 0 then Sum(d.Amount) else 0 end Amount,  LEFT(c.W2Code,10)  Description,
	'D' + Cast(c.W2Code AS nvarchar(4)) LineCode, '00' as LocalCode
FROM dbo.tblPaEmpHistDeduct d INNER JOIN dbo.tblPaDeductCode c ON
	d.DeductionCode = c.DeductionCode
WHERE c.W2Box='14' and d.PaYear = @Year

--AND EmployerPaidFlag=0 AND ERFlag='E'
GROUP BY d.EmployeeId, c.W2Code

--declare @PaYear smallint
--set @PaYear = 2011

--exclude NJ; unique method required
INSERT INTO #tmpBox14

SELECT w.EmployeeID, sum(w.WithholdAmount) Amount, LEFT(td.Description,10)  Description, 
	'O' + Cast(w.WithholdingCode AS nvarchar(4)) LineCode, '00' as LocalCode
FROM dbo.tblPaEmpHistWithhold w 
Left Join  dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @Year
	on 	w.State = th.State  and w.WithholdingCode = td.Code and w.EmployerPaid = td.EmployerPaid 
WHERE w.EmployerPaid = 0  and  w.PaYear = @Year and w.TaxAuthorityType  = 1 and td.CodeType =0 AND w.State <> 'NJ'
GROUP BY w.EmployeeID, w.State, w.WithholdingCode, td.Description


--declare @PaYear smallint
--set @PaYear = 2011
--handle NJ 12/14/2000 -- JRS
--so2 and so3
INSERT INTO #tmpBox14

SELECT w.EmployeeID, Sum(w.WithholdAmount) Amount, 'UI/WF/SWF' Description, 
	'NJ141' LineCode, '00' as LocalCode
FROM dbo.tblPaEmpHistWithhold w 
Left Join  dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @Year
	on 	w.State = th.State  and w.WithholdingCode = td.Code and w.EmployerPaid = td.EmployerPaid 
WHERE w.EmployerPaid = 0  and  w.PaYear = @Year and w.TaxAuthorityType  = 1 and td.CodeType =0 

AND w.State = 'NJ'  AND (w.WithholdingCode = 'SO2' OR w.WithholdingCode = 'SO3')
GROUP BY w.EmployeeID

--declare @PaYear smallint
--set @PaYear = 2011
--so1
INSERT INTO #tmpBox14

SELECT w.EmployeeID, Sum(w.WithholdAmount) Amount, 'DI', 
	'NJ142' LineCode, '00' as LocalCode
FROM dbo.tblPaEmpHistWithhold w 
Left Join  dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @Year
	on 	w.State = th.State  and w.WithholdingCode = td.Code and w.EmployerPaid = td.EmployerPaid 
WHERE w.EmployerPaid = 0  and  w.PaYear = @Year and w.TaxAuthorityType  = 1 and td.CodeType =0 

AND w.State = 'NJ'  AND w.WithholdingCode = 'SO1'
GROUP BY w.EmployeeID
 
--declare @PaYear smallint
--set @PaYear = 2011

--so4
UPDATE dbo.tblPaW2 SET NJFLIAmt = t.Total
FROM (SELECT w.EmployeeId, Sum(w.WithholdAmount) AS Total 
FROM dbo.tblPaEmpHistWithhold w 
Left Join  dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @Year
	on 	w.State = th.State  and w.WithholdingCode = td.Code and w.EmployerPaid = td.EmployerPaid 
WHERE w.EmployerPaid = 0  and  w.PaYear = @Year and w.TaxAuthorityType  = 1 and td.CodeType =0 

AND w.State = 'NJ'  AND w.WithholdingCode = 'SO4'
GROUP BY w.EmployeeID

) t 
WHERE dbo.tblPaW2.EmployeeId = t.EmployeeId

--declare @PaYear smallint
--set @PaYear = 2011
--local others

INSERT INTO #tmpBox14
SELECT w.EmployeeID, sum(w.WithholdAmount), LEFT(td.Description,10), 
	'Z' + Cast(w.WithholdingCode AS nvarchar(4)) LineCode, w.Local as LocalCode
FROM dbo.tblPaEmpHistWithhold w 
Left Join  dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @Year
	on 	w.State = th.State and  w.Local = th.Local and w.WithholdingCode = td.Code and w.EmployerPaid = td.EmployerPaid 

WHERE w.EmployerPaid = 0 and  w.PaYear = @Year and w.TaxAuthorityType  = 2 and td.CodeType =0
GROUP BY w.EmployeeID, w.State, w.Local, w.WithholdingCode, td.Description
	

DELETE FROM #tmpBox14 WHERE Amount=0


------------------
--DECLARE @Count int, @13Count int, @14Count int
--DECLARE @NewCreated bit
---------------------

SELECT @13Count=Count(*) FROM #tmpBox13
SELECT @14Count=Count(*) FROM #tmpBox14
SET @Count = @13Count+@14Count
SET @NewCreated=0

WHILE Coalesce(@count,0) > 0
BEGIN
IF @13Count > 0
BEGIN
	--Line 1
	SELECT EmployeeID, MIN(DescCode) AS FirstDescr
	INTO #tmpBox13First
	FROM #tmpBox13
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box13Line1= Amount, Box13LineDesc1=DescCode
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.DescCode=F.FirstDescr)
		ON B.EmployeeID= dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox13=0

	DELETE #tmpBox13 FROM #tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.DescCode=F.FirstDescr

	--Line 2
	DELETE FROM #tmpBox13First

	INSERT INTO #tmpBox13First
	SELECT EmployeeID, MIN(DescCode) AS FirstDescr
	FROM #tmpBox13
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box13Line2= Amount, Box13LineDesc2=DescCode
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.DescCode=F.FirstDescr)
		ON B.EmployeeID= dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox13=0

	DELETE #tmpBox13 FROM #tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.DescCode=F.FirstDescr

	--Line 3
	DELETE FROM #tmpBox13First

	INSERT INTO #tmpBox13First
	SELECT EmployeeID, MIN(DescCode) AS FirstDescr
	FROM #tmpBox13
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box13Line3= Amount, Box13LineDesc3=DescCode
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.DescCode=F.FirstDescr)
		ON B.EmployeeID=dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox13=0

	DELETE #tmpBox13 FROM #tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.DescCode=F.FirstDescr

	--Line 4
	DELETE FROM #tmpBox13First

	INSERT INTO #tmpBox13First
	SELECT EmployeeID, MIN(DescCode) AS FirstDescr
	FROM #tmpBox13
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box13Line4= Amount, Box13LineDesc4=DescCode
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.DescCode=F.FirstDescr)
		ON B.EmployeeID=dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox13=0

	DELETE #tmpBox13 FROM #tmpBox13 B INNER JOIN #tmpBox13First F 
		ON B.EmployeeID=F.EmployeeID AND B.DescCode=F.FirstDescr



	SELECT @13Count=Count(*) FROM #tmpBox13
	SET @13Count=Coalesce(@13Count,0)
	DROP TABLE #tmpBox13First
END --13Count>0

IF @14Count>0
BEGIN
	--Line 1
	SELECT EmployeeID, Min(LocalCode + LineCode) LineCode
	INTO #tmpBox14First
	FROM #tmpBox14
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box14Line1= Amount, Box14LineDesc1=Description
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox14 B INNER JOIN #tmpBox14First F 
		ON B.EmployeeID=F.EmployeeID AND B.LocalCode + B.LineCode=F.Linecode)
		ON B.EmployeeID=dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox14=0

	DELETE #tmpBox14 FROM #tmpBox14 B INNER JOIN #tmpBox14First F 
		ON B.EmployeeID=F.EmployeeID AND B.LocalCode + B.LineCode=F.Linecode

	--Line 2
	DELETE FROM #tmpBox14First

	INSERT INTO #tmpBox14First
	SELECT EmployeeID, Min(LocalCode + LineCode) LineCode
	FROM #tmpBox14
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box14Line2= Amount, Box14LineDesc2=Description
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox14 B INNER JOIN #tmpBox14First F 
		ON B.EmployeeID=F.EmployeeID AND B.LocalCode + B.LineCode=F.Linecode)
		ON B.EmployeeID=dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox14=0

	DELETE #tmpBox14 FROM #tmpBox14 B INNER JOIN #tmpBox14First F 
		ON B.EmployeeID=F.EmployeeID AND B.LocalCode + B.LineCode=F.Linecode

	--Line 3
	DELETE FROM #tmpBox14First

	INSERT INTO #tmpBox14First
	SELECT EmployeeID, Min(LocalCode + LineCode) LineCode
	FROM #tmpBox14
	GROUP BY EmployeeID

	UPDATE dbo.tblPaW2 SET Box14Line3= Amount, Box14LineDesc3=Description
	FROM dbo.tblPaW2 INNER JOIN (#tmpBox14 B INNER JOIN #tmpBox14First F 
		ON B.EmployeeID=F.EmployeeID AND B.LocalCode + B.LineCode=F.Linecode)
		ON B.EmployeeID=dbo.tblPaW2.EmployeeID
	WHERE dbo.tblPaW2.AddnlBox14=0

	DELETE #tmpBox14 FROM #tmpBox14 B INNER JOIN #tmpBox14First F 
		ON B.EmployeeID=F.EmployeeID AND B.LocalCode + B.LineCode=F.Linecode

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

Update dbo.tblPaW2 Set 
	 Box16a =  w2.Box16a, Box16b = w2.Box16b

from dbo.tblPaW2  v
INNER JOin 
(Select tot.EmployeeId, m.Box16a, tot.Box16b from dbo.tblPaPrepMagMed m  INNER JOIn #tmpPaW2 tot  
on m.EmployeeID = tot.EmployeeID WHERE tot.FirstLine = 1 and m.SumOfBox1 + m.SumOfBox2 + m.SumOfBox3 + m.SumOfBox4 + m.SumOfBox5 + m.SumOfBox6 <>0 ) w2
 on w2.EmployeeID= v.EmployeeID WHERE  v.FirstLine = 0
 
 --v.AddnlBox13 = 1 
	

--Select v.EmployeeID , v.Box16a, v.Box16b, v.AddnlBox13,  v.FirstLine, w2.EmployeeID , w2.Box16a, w2.Box16b
--from dbo.tblPaW2  v
--INNER JOin 
--(Select tot.EmployeeId, m.Box16a, tot.Box16b from dbo.tblPaPrepMagMed m  INNER JOIn #tmpPaW2 tot  
--on m.EmployeeID = tot.EmployeeID WHERE tot.FirstLine = 1 and m.SumOfBox5 <>0 ) w2
-- on w2.EmployeeID= v.EmployeeID WHERE   v.FirstLine = 0
 
 --v.AddnlBox13 = 1
 
 
 
----create new W2 records for additional states or multiple local codes
--INSERT INTO dbo.tblPaW2(EmployeeID, Box16a, Box16b, Box17, Box18
--	, Box19, Box20, Box21, Box19a, Box20a, Box21a)
--SELECT tot.EmployeeID, tot.Box16a, m.Box16b, m.SumOfBox17, m.SumOfBox18,
--	tot.Box19,  m.SumOfBox20, m.SumOfBox21, tot.Box19a, tot.Box20a, tot.Box21a
--from dbo.tblPaPrepMagMed m Inner Join
--	#tmpPaW2 tot on  tot.EmployeeId = m.EmployeeId 
--Where  tot.FirstLine = 0 and m.SumOfBox1 + m.SumOfBox2 + m.SumOfBox3 + m.SumOfBox4 + m.SumOfBox5 + m.SumOfBox6 = 0



--Select h.State, m.Box16a from  dbo.tblPaPrepMagMed m 
Update dbo.tblPaPrepMagMed set Box16a =  h.State
from  dbo.tblPaPrepMagMed m 
Left Join ST.dbo.tblPASTStateTaxCodeHdr h on m.StateCode = h.NumericCode and h.PaYEar = @Year
WHERE m.SumOfBox1 + m.SumOfBox2 + m.SumOfBox3 + m.SumOfBox4 + m.SumOfBox5 + m.SumOfBox6 = 0
 
--create new W2 records for additional states or multiple local codes
INSERT INTO dbo.tblPaW2(EmployeeID, Box16a, Box16b, Box17, Box18
	, Box19, Box20, Box21, Box19a, Box20a, Box21a, FirstLine)
SELECT tot.EmployeeID, tot.Box16a, tot.Box16b, tot.Box17, tot.Box18,tot.Box19, tot.Box20, tot.Box21, tot.Box19a, tot.Box20a, tot.Box21a,  tot.FirstLine from 
#tmpPaW2 tot  
Where  tot.FirstLine = 0  
Order by tot.EmployeeID,  tot.Box16a, tot.Box16b, tot.Box19



Update 	dbo.tblPaW2 set Box17 = m.Box17, Box18 = m.Box18
--Select w2.Box17 ,m.Box17, w2.Box18, m.Box18
From 
(Select EmployeeID, Box16a, SumOfBox17 as Box17, SumOfBox18 as Box18 from dbo.tblPaPrepMagMed
 WHERE SumOfBox1 + SumOfBox2 + SumOfBox3 +  SumOfBox4 + SumOfBox4 + SumOfBox6  + SumOfBox6 =0
)m
right Join dbo.tblPaW2 W2 on m.EmployeeID = w2.EmployeeID  
and m.Box16a = w2.Box16a WHERE FirstLine = 0 and w2.Box17 + w2.Box17 <> 0



UPDATE dbo.tblPaW2 SET BoxA=s.SocialSecurityNo, BoxE=UPPER(COALESCE (s.FirstName, '') + ' ' + COALESCE (s.MiddleInit, '')), BoxE1 = UPPER(COALESCE (s.LastName, '')), BoxF=coalesce(s.AddressLine1,'') + '  ' + coalesce(s.AddressLine2,''),
BoxF1 = LEFT(s.ResidentCity, 25), BoxF2=s.ResidentState, BoxF3=s.ZipCode, BoxF4=s.CountryCode
--,
	--Box15a=v.StatutoryEmployee, Box15b=v.Deceased, 
	--Box15c=v.ParticipatingIn401k,
	--Box15g=v.ParticipatingIn401k

FROM dbo.tblPaW2 INNER JOIN dbo.tblPaEmployee v ON dbo.tblPaW2.EmployeeID=v.EmployeeID
Inner Join dbo.tblSmEmployee s on dbo.tblPaW2.EmployeeID=s.EmployeeID

	


	
-- state total
INSERT INTO dbo.tblPaW2(EmployeeID,Box16a, Box16b, Box1, Box2, Box3, Box4, Box5,Box6,Box7,Box8,Box9,Box10,
Box11,Box13Line1,Box17,Box18,BoxE, BoxF)
SELECT  'zzzzzzzzzzz', Box16a,max(Box16b) , SUM(Box1) , SUM(Box2)  ,SUM(Box3) ,SUM(Box4),SUM(Box5),SUM(Box6) ,
SUM(Box7) ,SUM(Box8),SUM(Box9),SUM(Box10),SUM(Box11) ,
SUM(CASE  Box13lineDesc1 WHEN 'D'  THEN Box13line1 WHEN 'E' THEN Box13line1  WHEN 'F' THEN Box13line1
WHEN 'G'  THEN Box13line1 WHEN 'H'  THEN Box13line1 WHEN 'S'  THEN Box13line1 WHEN 'Y'  THEN Box13line1 WHEN 'AA'  THEN Box13line1 WHEN 'BB' THEN Box13line1 WHEN 'EE' THEN Box13line1 ELSE 0 end)
 + SUM(CASE  Box13lineDesc2 WHEN 'D'  THEN Box13line2 WHEN 'E' THEN Box13line2  WHEN 'F' THEN Box13line2
WHEN 'G'  THEN Box13line2 WHEN 'H'  THEN Box13line2 WHEN 'S'  THEN Box13line2 WHEN 'Y'  THEN Box13line2 WHEN 'AA'  THEN Box13line2 WHEN 'BB' THEN Box13line2 WHEN 'EE' THEN Box13line2 ELSE 0 end)
 + SUM(CASE  Box13lineDesc3 WHEN 'D'  THEN Box13line3 WHEN 'E' THEN Box13line3  WHEN 'F' THEN Box13line3
WHEN 'G'  THEN Box13line3 WHEN 'H'  THEN Box13line3 WHEN 'S'  THEN Box13line3  WHEN 'Y'  THEN Box13line3 WHEN 'AA'  THEN Box13line3 WHEN 'BB' THEN Box13line3 WHEN 'EE' THEN Box13line3 ELSE 0 end)
+ SUM(CASE  Box13lineDesc4 WHEN 'D'  THEN Box13line4 WHEN 'E' THEN Box13line4  WHEN 'F' THEN Box13line4
WHEN 'G'  THEN Box13line4 WHEN 'H'  THEN Box13line4 WHEN 'S'  THEN Box13line4 WHEN 'Y'  THEN Box13line4 WHEN 'AA'  THEN Box13line4 WHEN 'BB' THEN Box13line4 WHEN 'EE' THEN  Box13line4  ELSE 0 end),
SUM(Box17) ,SUM(Box18) , 'STATE TOTALS' ,CONVERT(nvarchar(10),COUNT(DISTINCT employeeid)) + ' EMPLOYEES' 
FROM dbo.tblPaW2 GROUP BY Box16a



--generate control numbers ordered by state and employee
 --@TaxAuth nvarchar(2), @Emp nvarchar(11), 
declare @Counter int 
declare @Lastname nvarchar(20)
set @Counter=0
declare curControl cursor for
	SELECT case a.employeeid when 'zzzzzzzzzzz' then 'zzzzzzzzzzz' else b.lastname end lastname
	FROM dbo.tblPaW2 a LEFT JOIN dbo.tblSmEmployee b 
	ON a.EmployeeID = b.EmployeeID order by a.box16a, lastname,a.EmployeeID, Isnull(a.Box13lineDesc1, 'Z'), Isnull(a.Box13lineDesc2, 'Z'), Isnull(a.Box13lineDesc3, 'Z'), Isnull(a.boxB, 'ZZZZZZ')
		
open curControl
fetch next from curControl INTO  @Lastname
While (@@FETCH_STATUS=0)
begin
	set @Counter=@Counter+1
	Update dbo.tblPaW2 SET BoxD=@Counter
	WHERE CURRENT OF  curControl
	-- WHERE Box16A=@TaxAuth AND EmployeeID=@Emp AND BoxD = 0
	fetch next from curControl INTO  @lastname
end
close curControl
deallocate curControl

IF (Select COUNT(*) from dbo.tblPaW2) > 0
begin

-- Grand total
INSERT INTO dbo.tblPaW2(EmployeeID,BoxD, Box1, Box2, Box3, Box4, Box5,Box6,Box7,Box8,Box9,Box10,
                    Box11,Box13Line1, Box13Line2, BoxE, BoxF)
SELECT  'zzzzzzzzzzz', MAX(BoxD) + 2, SUM(Box1) , SUM(Box2)  ,SUM(Box3) ,SUM(Box4),SUM(Box5),SUM(Box6) ,
SUM(Box7) ,SUM(Box8),SUM(Box9),SUM(Box10),SUM(Box11) ,
SUM(CASE  Box13lineDesc1 WHEN 'D'  THEN Box13line1 WHEN 'E' THEN Box13line1  WHEN 'F' THEN Box13line1
WHEN 'G'  THEN Box13line1 WHEN 'H'  THEN Box13line1 WHEN 'S'  THEN Box13line1 WHEN 'Y'  THEN Box13line1 WHEN 'AA'  THEN Box13line1 WHEN 'BB' THEN Box13line1  WHEN 'EE' THEN Box13line1 ELSE 0 end)
 + SUM(CASE  Box13lineDesc2 WHEN 'D'  THEN Box13line2 WHEN 'E' THEN Box13line2  WHEN 'F' THEN Box13line2
WHEN 'G'  THEN Box13line2 WHEN 'H'  THEN Box13line2 WHEN 'S'  THEN Box13line2 WHEN 'Y'  THEN Box13line2 WHEN 'AA'  THEN Box13line2 WHEN 'BB' THEN Box13line2  WHEN 'EE' THEN Box13line2 ELSE 0 end)
+ SUM(CASE  Box13lineDesc3 WHEN 'D'  THEN Box13line3 WHEN 'E' THEN Box13line3  WHEN 'F' THEN Box13line3
WHEN 'G'  THEN Box13line3 WHEN 'H'  THEN Box13line3 WHEN 'S'  THEN Box13line3 WHEN 'Y'  THEN Box13line3 WHEN 'AA'  THEN Box13line3 WHEN 'BB' THEN Box13line3  WHEN 'EE' THEN Box13line3 ELSE 0 end)
 + SUM(CASE  Box13lineDesc4 WHEN 'D'  THEN Box13line4 WHEN 'E' THEN Box13line4  WHEN 'F' THEN Box13line4
WHEN 'G'  THEN Box13line4 WHEN 'H'  THEN Box13line4 WHEN 'S' THEN Box13line4  WHEN 'Y' THEN Box13line4 WHEN 'AA'  THEN Box13line4 WHEN 'BB' THEN Box13line4  WHEN 'EE' THEN Box13line4  ELSE 0 end),
--SUM(CASE  Box13lineDesc1 WHEN 'CC'  THEN Box13line1 ELSE 0 end)
-- + SUM(CASE  Box13lineDesc2 WHEN 'CC'  THEN Box13line2 ELSE 0 end)
-- + SUM(CASE  Box13lineDesc3 WHEN 'CC'  THEN Box13line3 ELSE 0 end)
-- + SUM(CASE  Box13lineDesc4 WHEN 'CC'  THEN Box13line4 ELSE 0 end),
0, 'GRAND TOTALS', CONVERT(nvarchar(10),COUNT(DISTINCT employeeid)) + ' EMPLOYEES' 
FROM dbo.tblPaW2
WHERE EmployeeID <> 'zzzzzzzzzzz'

end
--declare @Year smallint
--set @Year = 2011	
declare @BoxB  nvarchar(17)
SELECT @BoxB = td.TaxId from dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId  WHERE  td.CodeType=1  and th.Type = 0
and  td.PaYear = @Year


UPDATE dbo.tblPaW2 SET BoxB = @BoxB
--Return @@Error


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCreateW2_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCreateW2_proc';

