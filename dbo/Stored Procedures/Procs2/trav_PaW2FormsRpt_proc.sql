
CREATE  Procedure [dbo].[trav_PaW2FormsRpt_proc]

@Year  Smallint = 2010,
@PrintBy Smallint  = 1,
@ControlNumFrom int = 1,
@ControlNumThru int = 999999999
AS
SET NOCOUNT ON
BEGIN TRY
--PET:http://webfront:801/view.php?id=229520
--PET:http://webfront:801/view.php?id=229528
--PET:http://webfront:801/view.php?id=229520
--PET:http://webfront:801/view.php?id=229589
--PET:http://webfront:801/view.php?id=229688
--PET:http://webfront:801/view.php?id=229687
--PET:http://webfront:801/view.php?id=229688
--PET:http://webfront:801/view.php?id=229764
--PET:http://webfront:801/view.php?id=229741
--PET:http://webfront:801/view.php?id=229876
--PET:http://webfront:801/view.php?id=230120
--PET:http://webfront:801/view.php?id=235929
--PET:http://webfront:801/view.php?id=240772
--PET:http://webfront:801/view.php?id=244674
--PET:http://webfront:801/view.php?id=255112
--PET:http://problemtrackingsystem.osas.com/view.php?id=263204

Declare @curCounter  cursor
declare  @Count int 
declare @Counter int
declare @EmployeeId pEmpId
declare @BoxD int
set @Count=0
set @Counter = 0
set @EmployeeId = ''

--drop table  #EmployeeList 
--CREATE TABLE #EmployeeList (EmployeeId pEmpID NOT NULL PRIMARY KEY CLUSTERED ([EmployeeId]))
--INSERT INTO #EmployeeList ([EmployeeId]) SELECT  [EmployeeId] FROM dbo.tblPaEmployee 
--WHERE  dbo.tblPaEmployee.EmployeeId = 'MAINE_2'----
--INSERT INTO #EmployeeList ([EmployeeId]) Select 'zzzzzzzzzzz' as [EmployeeId] 

If @PrintBy  = 3
begin
   
	Select CASE W.EmployeeID WHEN 'zzzzzzzzzzz' THEN NULL ELSE W.EmployeeID END AS EmployeeID, 
		W.BoxA, W.BoxC, W.BoxD, W.BoxE, W.BoxE1,  
		--REPLACE(W.BoxF, 'EMPLOYEES', '') BoxF,
		CAST((SELECT  COUNT(*) FROM dbo.tblPaW2 WHERE  EmployeeID <> 'zzzzzzzzzzz') as varchar(4)) BoxF,
		 W.BoxF1,W.BoxF2,W.BoxF3,	W.BoxF4, 
		CASE W.Box1 WHEN 0 THEN NULL ELSE W.Box1 END Box1, 
		CASE W.Box2 WHEN 0 THEN NULL ELSE W.Box2 END Box2,
		CASE W.Box3 WHEN 0 THEN NULL ELSE W.Box3 END Box3, 
		CASE W.Box4 WHEN 0 THEN NULL ELSE W.Box4 END Box4,
		CASE W.Box5 WHEN 0 THEN NULL ELSE W.Box5 END Box5, 
		CASE W.Box6 WHEN 0 THEN NULL ELSE W.Box6 END Box6,
		CASE W.Box7 WHEN 0 THEN NULL ELSE W.Box7 END Box7, 
		CASE W.Box8 WHEN 0 THEN NULL ELSE W.Box8 END Box8,
		CASE W.Box9 WHEN 0 THEN NULL ELSE W.Box9 END Box9, 
		CASE W.Box10 WHEN 0 THEN NULL ELSE W.Box10 END Box10,
		CASE W.Box11 WHEN 0 THEN NULL ELSE W.Box11 END Box11, 
		CASE W.Box12 WHEN 0 THEN NULL ELSE W.Box12 END Box12,
		CASE W.Box13Line1 WHEN 0 THEN NULL ELSE W.Box13Line1 END Box13Line1, 
		CASE W.Box13Line2 WHEN 0 THEN NULL ELSE W.Box13Line2 END Box13Line2,
		CASE W.Box13Line3 WHEN 0 THEN NULL ELSE W.Box13Line3 END Box13Line3, 
		CASE W.Box13Line4 WHEN 0 THEN NULL ELSE W.Box13Line4 END Box13Line4, 
		CASE W.Box14Line1 WHEN 0 THEN NULL ELSE W.Box14Line1 END Box14Line1,
		CASE W.Box14Line2 WHEN 0 THEN NULL ELSE W.Box14Line2 END Box14Line2, 
		CASE W.Box14Line3 WHEN 0 THEN NULL ELSE W.Box14Line3 END Box14Line3,
		CASE WHEN (SELECT  COUNT(*)  FROM dbo.tblPaW2 WHERE  BoxE = 'STATE TOTALS') > 1 THEN 'X' ELSE 
			(SELECT  MIN(Box16a)  FROM dbo.tblPaW2 WHERE  ISNULL(Box16a, '') <> '') END Box16a, 
		CASE WHEN (SELECT  COUNT(*)  FROM dbo.tblPaW2 WHERE  BoxE = 'STATE TOTALS') > 1 THEN '' ELSE 
			(SELECT  MIN(Box16b)  FROM dbo.tblPaW2 WHERE  ISNULL(Box16b, '') <> '') END Box16b, 
		(SELECT SUM(CASE Box17 WHEN 0 THEN NULL ELSE Box17 END) FROM dbo.tblPaW2 WHERE  BoxE = 'STATE TOTALS') Box17, 
		(SELECT SUM(CASE Box18 WHEN 0 THEN NULL ELSE Box18 END) FROM dbo.tblPaW2 WHERE BoxE = 'STATE TOTALS')  Box18, 
		(SELECT SUM(CASE Box20 WHEN 0 THEN NULL ELSE Box20 + Box20a END) FROM dbo.tblPaW2 WHERE ISNULL(Box19, '') <> '')  Box20, 
		(SELECT SUM(CASE Box21 WHEN 0 THEN NULL ELSE Box21 + Box21a END) FROM dbo.tblPaW2 WHERE ISNULL(Box19, '') <> '')  Box21
		
	FROM dbo.tblPaW2 w  
INNER JOIn #EmployeeList t on t.EmployeeId = w.EmployeeId and W.BoxE = 'Grand Totals' 
ORDER BY W.BoxD
		  



end

else if @PrintBy  = 5
begin


--drop table #tmpPaW2
create Table #tmpPaW2 
(
EmployeeID pEmpId, 
BoxA nvarchar(225), BoxC nvarchar(17), BoxD int Not null, BoxE nvarchar(70), BoxE1 nvarchar(70),
BoxF nvarchar(100), BoxF1 nvarchar(25),BoxF2 nvarchar(2),BoxF3 nvarchar(10),BoxF4 nvarchar(10), 
Box1 float,Box2 float,Box3 float, Box4 float, Box5 float,
Box6 float,Box7 float,Box8 float,Box9 float,Box10 float,Box11 float,Box12 float,
Box13Line1 float,Box13Line2 float,Box13Line3 float,Box13Line4 float,
Box14Line1 float,Box14Line2 float,Box14Line3 float,Box14Line4 float,
Box13LineDesc1  nvarchar(10), Box13LineDesc2 nvarchar(10), Box13LineDesc3 nvarchar(10), Box13LineDesc4 nvarchar(10), Box14LineDesc1 nvarchar(10), 
Box14LineDesc2 nvarchar(10), Box14LineDesc3 nvarchar(10),
Box15a bit not Null, Box15b bit not Null,Box15c bit not Null,Box16a nvarchar(2),
Box16b nvarchar(20),Box15d bit not Null, Box15e bit not Null, 
Box15f bit not Null, Box15g bit not Null,
Box17 float, Box18 float, Box20 float, Box21 float, Box19 nvarchar(30), Box19a nvarchar(30),
Box20a float, Box21a float, NJFLIAmt float, Tot int
                        
)

Insert Into #tmpPaW2(
EmployeeID, BoxA,  BoxD, BoxE, BoxE1,BoxF, BoxF1,BoxF2 ,BoxF3 ,BoxF4, Box1,Box2,Box3,Box4, Box5,
Box6,Box7,Box8,Box9,Box10,Box11,Box12,Box13Line1,Box13Line2,Box13Line3,Box13Line4,
Box14Line1 ,Box14Line2,Box14Line3,Box13LineDesc1, Box13LineDesc2, Box13LineDesc3, Box13LineDesc4, Box14LineDesc1, 
Box14LineDesc2 , Box14LineDesc3,Box15a , Box15b ,Box15c, Box15d , Box15e , Box15f , Box15g ,
Box16a ,Box16b ,Box17 , Box18 , Box19, Box20 , Box21 , Box19a , Box20a , Box21a , NJFLIAmt , Tot )
--when 
   SELect w.EmployeeID, w.BoxA, w.BoxD, w.BoxE, w.BoxE1,w.BoxF,  w.BoxF1,  w.BoxF2, w.BoxF3,  w.BoxF4, 
		CASE  WHEN w.Box1 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box1 END Box1, 
		CASE  WHEN w.Box2 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box2 END Box2,
		CASE  WHEN w.Box3 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box3 END Box3, 
		CASE  WHEN w.Box4 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box4 END Box4,
		CASE  WHEN w.Box5 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box5 END Box5, 
		CASE  WHEN w.Box6 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box6 END Box6,
		CASE  WHEN w.Box7 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box7 END Box7, 
		CASE  WHEN w.Box8 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box8 END Box8,
		CASE  WHEN w.Box9 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box9 END Box9, 
		CASE  WHEN w.Box10 = 0 or w.EmployeeID ='zzzzzzzzzzz' THEN NULL ELSE  w.Box10 END Box10,
		CASE  WHEN w.Box11 = 0 or w.EmployeeID ='zzzzzzzzzzz' THEN NULL ELSE  w.Box11 END Box11, 
		CASE  WHEN w.Box12 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box12 END Box12,
		CASE  WHEN w.Box13Line1 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box13Line1 END Box13Line1, 
		CASE  WHEN w.Box13Line2 = 0  or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box13Line2 END Box13Line2,
		CASE  WHEN w.Box13Line3 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box13Line3 END Box13Line3, 
		CASE  WHEN w.Box13Line4  = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box13Line4 END Box13Line4, 
		CASE  WHEN w.Box14Line1 = 0 THEN NULL ELSE  w.Box14Line1 END Box14Line1,
		CASE  WHEN w.Box14Line2 = 0 THEN NULL ELSE  w.Box14Line2 END Box14Line2, 
		CASE  WHEN w.Box14Line3 = 0 THEN NULL ELSE  w.Box14Line3 END Box14Line3,
    
		CASE  WHEN w.EmployeeID = 'zzzzzzzzzzz'  THEN NULL  ELSE w.Box13LineDesc1 END Box13LineDesc1,  
        CASE  WHEN  w.EmployeeID = 'zzzzzzzzzzz'  THEN NULL  ELSE w.Box13LineDesc2 END Box13LineDesc2, 
        CASE  WHEN  w.EmployeeID = 'zzzzzzzzzzz'  THEN NULL  ELSE w.Box13LineDesc3 END Box13LineDesc3,
        CASE  WHEN  w.EmployeeID = 'zzzzzzzzzzz'  THEN NULL  ELSE w.Box13LineDesc4 END Box13LineDesc4,
		LEFT( w.Box14LineDesc1, 8) Box14LineDesc1, LEFT( w.Box14LineDesc2, 8) Box14LineDesc2, 
        LEFT( w.Box14LineDesc3, 8) Box14LineDesc3,
		w.Box15a, w.Box15b, w.Box15c, w.Box15d, w.Box15e, w.Box15f, w.Box15g,
       isnull(Box16a, '') Box16a, Box16b,

       --case WHEN w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE   w.Box16b END  Box16b,
		
		CASE  WHEN w.Box17 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box17 END Box17, 
		CASE  WHEN w.Box18 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box18 END Box18, 
        CASE  WHEN w.Box19 = NULL or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box19 END Box19, 
		
		CASE  WHEN w.Box20 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box20 END Box20, 
		CASE  WHEN w.Box21 = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box21 END Box21,
       --CASE  WHEN w.Box19a = null or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box19a END Box19a, 
		Box19a,
        CASE  WHEN w.Box20a = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box20a END Box20a, 
		CASE  WHEN w.Box21a = 0 or w.EmployeeID = 'zzzzzzzzzzz' THEN NULL ELSE  w.Box21a END Box21a,

		CASE  w.NJFLIAmt WHEN 0 THEN NULL ELSE  w.NJFLIAmt END NJFLIAmt, 1 as Tot
	FROM dbo.tblPaW2 w Inner JOIn #EmployeeList t on t.EmployeeId = w.EmployeeId
	ORDER BY w.BoxD 
	
	--SELect * from dbo.tblPaW2

	SELECT  CASE w.EmployeeID WHEN 'zzzzzzzzzzz' THEN NULL ELSE w.EmployeeID END AS EmployeeID, 
	CASE WHEN w.BoxE = 'STATE TOTALS'
	THEN  'Number of Employees:'  ELSE '' END AS BoxFCount, 
	CASE WHEN w.BoxE = 'STATE TOTALS' THEN 'Totals for ' + w.BOX16A  ELSE '' END AS StateTotal,
	CASE WHEN w.BoxE = 'GRAND TOTALS' then NULL else w.BoxE + ' ' +  ISNULL(w.BoxE1, '') end EmployeeName,
	CASE WHEN w.BOXE ='STATE TOTALS' Or w.BOXE ='GRAND TOTALS' then '' else w.EmployeeId end EmpId,
	w.BoxA,  w.BoxD, w.BoxE , w.BoxE1, w.BoxF , w.BoxF1 ,w.BoxF2 ,w.BoxF3 ,w.BoxF4 , 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox1 else w.Box1  end as Box1, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox2 else w.Box2  end as Box2, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox3 else w.Box3  end as Box3, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox4 else w.Box4  end as Box4, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox5 else w.Box5  end as Box5, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox6 else w.Box6  end as Box6, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox7 else w.Box7  end as Box7, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox8 else w.Box8  end as Box8, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox9 else w.Box9  end as Box9, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox10 else w.Box10  end as Box10, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox11 else w.Box11  end as Box11, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox12 else w.Box12  end as Box12, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox17 else w.Box17  end as Box17, 
	CAse when w.BOXE ='STATE TOTALS'  then  st.sumBox18 else w.Box18  end as Box18, 
	CAse when w.BOXE ='STATE TOTALS' then case when st.sumBox13line1 = 0 then  Null else st.sumBox13line1 end else w.Box13Line1 end Box13line1, 
	w.Box13Line1 ,w.Box13Line2 ,w.Box13Line3 ,Box13Line4 ,
	w.Box14Line1 ,w.Box14Line2 ,Box14Line3 ,Box14Line4 ,
	w.Box13LineDesc1, w.Box13LineDesc2 , w.Box13LineDesc3 ,  w.Box13LineDesc4 ,w.Box14LineDesc1 , 
	w.Box14LineDesc2 , w.Box14LineDesc3 ,
	w.Box15a , w.Box15b ,w.Box15c, 
	 w.Box15d , w.Box15e , 
	w.Box15f , w.Box15g ,isnull(w.Box16a, '') Box16a, w.Box16b as Box16b,
	w.Box17 , w.Box18 , w.Box20 , w.Box21 , w.Box19 , w.Box19a ,
	w.Box20a , w.Box21a , w.NJFLIAmt , w.Tot, stt.StCountTotal StCountTotal, 
	TT.TCountTotal TCountTotal, COALESCE(GT.TsumBox1, 0) TsumBox1,COALESCE(GT.TsumBox2, 0) TsumBox2,
	COALESCE(GT.TsumBox3, 0) TsumBox3,COALESCE(GT.TsumBox4, 0) TsumBox4,COALESCE(GT.TsumBox5, 0) TsumBox5,
	COALESCE(GT.TsumBox6, 0) TsumBox6,
	COALESCE(GT.TsumBox7, 0) TsumBox7,COALESCE(GT.TsumBox8, 0) TsumBox8, 
	COALESCE(GT.TsumBox9, 0) TsumBox9, COALESCE(GT.TsumBox10, 0) TsumBox10, 
	COALESCE(GT.TsumBox11, 0) TsumBox11, 
	Null as  TsumBox17,
	Null as TsumBox18,
	Null as  TsumBox20,
	Null as  TsumBox21,
	COALESCE(GT.TsumBox13line1, Null) TsumBox13line1, GT.TsumBox13line2HRAct
From #tmpPaW2  w
Left Join
(Select  1 as Tot, MIN('STATE TOTALS') as BoxE, 
--count(*) as StCountTotal, 
		ISNULL(w.Box16a, '') Box16a, 
		
        CASE sum(W.Box1) WHEN 0 THEN NULL ELSE sum(W.Box1) END sumBox1, 
		CASE sum(W.Box2) WHEN 0 THEN NULL ELSE sum(W.Box2) END sumBox2,
		CASE sum(W.Box3) WHEN 0 THEN NULL ELSE sum(W.Box3) END sumBox3, 
		CASE sum(W.Box4) WHEN 0 THEN NULL ELSE sum(W.Box4) END sumBox4,
		CASE sum(W.Box5) WHEN 0 THEN NULL ELSE sum(W.Box5) END sumBox5, 
		CASE sum(W.Box6) WHEN 0 THEN NULL ELSE sum(W.Box6) END sumBox6,
		CASE sum(W.Box7) WHEN 0 THEN NULL ELSE sum(W.Box7) END sumBox7, 
		CASE sum(W.Box8) WHEN 0 THEN NULL ELSE sum(W.Box8) END sumBox8,
		CASE sum(W.Box9) WHEN 0 THEN NULL ELSE sum(W.Box9) END sumBox9, 
		CASE sum(W.Box10) WHEN 0 THEN NULL ELSE sum(W.Box10) END sumBox10,
		CASE sum(W.Box11) WHEN 0 THEN NULL ELSE sum(W.Box11) END sumBox11, 
        CASE sum(W.Box12) WHEN 0 THEN NULL ELSE sum(W.Box12) END sumBox12, 
		CASE sum(W.Box17) WHEN 0 THEN NULL ELSE sum(w.Box17) END sumBox17, 
		CASE sum(W.Box18) WHEN 0 THEN NULL ELSE sum(W.Box18) END sumBox18, 
		CASE sum(W.Box20) WHEN 0 THEN NULL ELSE sum(W.Box20) END sumBox20, 
		CASE sum(W.Box21) WHEN 0 THEN NULL ELSE sum(W.Box21) END sumBox21,
		SUM(CASE  W.Box13lineDesc1 WHEN 'D'  THEN W.Box13line1 WHEN 'E' THEN W.Box13line1  WHEN 'F' THEN Box13line1
		WHEN 'G'  THEN W.Box13line1 WHEN 'H'  THEN W.Box13line1 WHEN 'S'  THEN W.Box13line1 WHEN 'Y'  THEN Box13line1 WHEN 'AA'  THEN W.Box13line1 WHEN 'BB' THEN W.Box13line1 WHEN 'EE' THEN Box13line1 ELSE 0 end)
		+ SUM(CASE  W.Box13lineDesc2 WHEN 'D'  THEN W.Box13line2 WHEN 'E' THEN W.Box13line2  WHEN 'F' THEN Box13line2
		WHEN 'G'  THEN W.Box13line2 WHEN 'H'  THEN W.Box13line2 WHEN 'S'  THEN W.Box13line2 WHEN 'Y'  THEN Box13line2 WHEN 'AA'  THEN W.Box13line2 WHEN 'BB' THEN W.Box13line2 WHEN 'EE' THEN Box13line2 ELSE 0 end)
		+ SUM(CASE  W.Box13lineDesc3 WHEN 'D'  THEN W.Box13line3 WHEN 'E' THEN W.Box13line3  WHEN 'F' THEN Box13line3
		WHEN 'G'  THEN W.Box13line3 WHEN 'H'  THEN W.Box13line3 WHEN 'S'  THEN W.Box13line3  WHEN 'Y'  THEN Box13line3 WHEN 'AA'  THEN W.Box13line3 WHEN 'BB' THEN W.Box13line3 WHEN 'EE' THEN Box13line3 ELSE 0 end)
		+ SUM(CASE  W.Box13lineDesc4 WHEN 'D'  THEN W.Box13line4 WHEN 'E' THEN W.Box13line4  WHEN 'F' THEN Box13line4
		WHEN 'G'  THEN W.Box13line4 WHEN 'H'  THEN W.Box13line4 WHEN 'S'  THEN W.Box13line4 WHEN 'Y'  THEN Box13line4 WHEN 'AA'  THEN W.Box13line4 WHEN 'BB' THEN W.Box13line4 WHEN 'EE' THEN Box13line4 ELSE 0 end) sumBox13line1 
      FROM dbo.tblPaW2 w Inner JOIn #EmployeeList t on t.EmployeeId = w.EmployeeId
WHERE  w.EmployeeId  <> 'zzzzzzzzzzz' 
   group by   w.Box16a) st
on  w.BoxE = st.BoxE and w.Box16a = st.Box16a  and st.Tot = w.Tot
Left Join 
(Select 1 Tot,   MIN('STATE TOTALS') as BoxE, sum(ST.STCountTotal) AS STCountTotal,  min(ST.EmployeeId) EmployeeId, ST.Box16a FROM 
  (Select min(1) as STCountTotal, EmployeeId, ISNULL(Box16a, '') Box16a from dbo.tblPaW2 
  WHERE EmployeeId  <> 'zzzzzzzzzzz' group by EmployeeId, ISNULL(Box16a, '')) ST
  group by ST.Box16a) Stt
  on  st.BoxE =Stt.BoxE and Stt.Box16a = st.Box16a  and st.Tot = Stt.Tot
   
Left Join 
(Select 1 as Tot,  MIN('GRAND TOTALS') as BoxE,   

       --SUM(ET.TCountTotal) as  TCountTotal,
        CASE sum(W.Box1) WHEN 0 THEN NULL ELSE sum(W.Box1) END TsumBox1, 
		CASE sum(W.Box2) WHEN 0 THEN NULL ELSE sum(W.Box2) END TsumBox2,
		CASE sum(W.Box3) WHEN 0 THEN NULL ELSE sum(W.Box3) END TsumBox3, 
		CASE sum(W.Box4) WHEN 0 THEN NULL ELSE sum(W.Box4) END TsumBox4,
		CASE sum(W.Box5) WHEN 0 THEN NULL ELSE sum(W.Box5) END TsumBox5, 
		CASE sum(W.Box6) WHEN 0 THEN NULL ELSE sum(W.Box6) END TsumBox6,
		CASE sum(W.Box7) WHEN 0 THEN NULL ELSE sum(W.Box7) END TsumBox7, 
		CASE sum(W.Box8) WHEN 0 THEN NULL ELSE sum(W.Box8) END TsumBox8,
		CASE sum(W.Box9) WHEN 0 THEN NULL ELSE sum(W.Box9) END TsumBox9, 
		CASE sum(W.Box10) WHEN 0 THEN NULL ELSE sum(W.Box10) END TsumBox10,
		CASE sum(W.Box11) WHEN 0 THEN NULL ELSE sum(W.Box11) END TsumBox11, 
		CASE sum(W.Box17) WHEN 0 THEN NULL ELSE sum(w.Box17) END TsumBox17, 
		CASE sum(W.Box18) WHEN 0 THEN NULL ELSE sum(W.Box18) END TsumBox18, 
		CASE sum(W.Box20) WHEN 0 THEN NULL ELSE sum(W.Box20) END TsumBox20, 
		CASE sum(W.Box21) WHEN 0 THEN NULL ELSE sum(W.Box21) END TsumBox21,
		SUM(CASE  W.Box13lineDesc1 WHEN 'D'  THEN W.Box13line1 WHEN 'E' THEN W.Box13line1  WHEN 'F' THEN Box13line1
		WHEN 'G'  THEN W.Box13line1 WHEN 'H'  THEN W.Box13line1 WHEN 'S'  THEN W.Box13line1 WHEN 'Y'  THEN Box13line1 WHEN 'AA'  THEN W.Box13line1 WHEN 'BB' THEN W.Box13line1 WHEN 'EE' THEN Box13line1 ELSE 0 end)
		+ SUM(CASE  W.Box13lineDesc2 WHEN 'D'  THEN W.Box13line2 WHEN 'E' THEN W.Box13line2  WHEN 'F' THEN Box13line2
		WHEN 'G'  THEN W.Box13line2 WHEN 'H'  THEN W.Box13line2 WHEN 'S'  THEN W.Box13line2 WHEN 'Y'  THEN Box13line2 WHEN 'AA'  THEN W.Box13line2 WHEN 'BB' THEN W.Box13line2 WHEN 'EE' THEN Box13line2 ELSE 0 end)
		+ SUM(CASE  W.Box13lineDesc3 WHEN 'D'  THEN W.Box13line3 WHEN 'E' THEN W.Box13line3  WHEN 'F' THEN Box13line3
		WHEN 'G'  THEN W.Box13line3 WHEN 'H'  THEN W.Box13line3 WHEN 'S'  THEN W.Box13line3  WHEN 'Y'  THEN Box13line3 WHEN 'AA'  THEN W.Box13line3 WHEN 'BB' THEN W.Box13line3 WHEN 'EE' THEN Box13line3 ELSE 0 end)
		+ SUM(CASE  W.Box13lineDesc4 WHEN 'D'  THEN W.Box13line4 WHEN 'E' THEN W.Box13line4  WHEN 'F' THEN Box13line4
		WHEN 'G'  THEN W.Box13line4 WHEN 'H'  THEN W.Box13line4 WHEN 'S'  THEN W.Box13line4 WHEN 'Y'  THEN Box13line4 WHEN 'AA'  THEN W.Box13line4 WHEN 'BB' THEN W.Box13line4 WHEN 'EE' THEN Box13line4 ELSE 0 end) TsumBox13line1, 

	 --   SUM(CASE  W.Box13lineDesc1 WHEN 'CC' THEN W.Box13line1 ELSE 0 end)
		--+ SUM(CASE  W.Box13lineDesc2 WHEN 'CC' THEN W.Box13line2 ELSE 0 end)
		--+ SUM(CASE  W.Box13lineDesc3 WHEN 'CC' THEN W.Box13line3 ELSE 0 end)
		--+ SUM(CASE  W.Box13lineDesc4 WHEN 'CC' THEN W.Box13line4 ELSE 0 end) 
		0 as TsumBox13line2HRAct

	FROM dbo.tblPaW2 W Inner JOIn #EmployeeList t on t.EmployeeId = W.EmployeeId
WHERE  w.EmployeeId  <> 'zzzzzzzzzzz')GT
on W.Tot = GT.Tot and  W.BoxE = GT.BoxE 
Left Join 
(Select 1 Tot,  sum(T.TCountTotal) AS TCountTotal FROM 
  (Select min(1) as TCountTotal from dbo.tblPaW2 WHERE EmployeeId  <> 'zzzzzzzzzzz' group by EmployeeId) T)TT on  TT.Tot = GT.Tot
	ORDER BY W.BoxD





end



else
begin
--sELECT * fROM dbo.tblPaW2





--
-- Select  1 as Tot,  count(*) as CountGroup
--  
--	FROM dbo.tblPaW2 W Inner JOIn #EmployeeList t on t.EmployeeId = W.EmployeeId
--WHERE  w.EmployeeId  <> 'GRAND TOTAL'
--Group by w.Box16a
--


--SElect  * from  dbo.tblPaW2

----drop table  #tmp
Create 	table #tmp (
[Counter] [int] IDENTITY(1,1) NOT NULL,
[EmployeeId] [dbo].[pEmpID] NOT NULL,
[BoxD] int,
[Grpcounter] int)

--
--
--Insert into #tmp
--Select EmployeeId, 1 as  Grpcounter from #EmployeeList
--
--Select count(Counter) From #tmp
--
--
Insert Into #tmp (EmployeeId, BoxD ) 
Select w.EmployeeId, w.BoxD from dbo.tblPaW2 w 
inner JOIn #EmployeeList t on t.EmployeeId = w.EmployeeId
order by BoxD


Set @curCounter = cursor forward_only static for
Select w.Counter, w.EmployeeId, w.BoxD from #tmp  w 
inner JOIn #EmployeeList t on t.EmployeeId = w.EmployeeId
order by w.BoxD
Open @curCounter
If @@cursor_rows <> 0
Begin
	Fetch next from @curCounter
		into @Counter, @EmployeeId, @BoxD  
	While @@Fetch_Status = 0
	Begin
--set @ExpEec = 0
--SELECT @ExpEec = COUNT(W.BoxD) FROM dbo.tblPaW2  W Inner JOIn #EmployeeList t on t.EmployeeId = W.EmployeeId

if (@Counter % 2) = 1
begin
     Select @Count = @Count + 1
end 
    Update #tmp set Grpcounter = @Count WHERE EmployeeId = @EmployeeId 
        
		Fetch next from @curCounter
			into @Counter, @EmployeeId, @BoxD  
	End
	Close @curCounter
End
Deallocate @curCounter



SELECT CASE w.EmployeeID WHEN 'zzzzzzzzzzz' THEN NULL ELSE w.EmployeeID END AS EmployeeID, 
		w.BoxA, w.BoxD, w.BoxE, w.BoxE1, 
		CASE WHEN w.BoxE = 'STATE TOTALS' OR w.BoxE = 'GRAND TOTALS' 
			THEN REPLACE(w.BoxF, 'EMPLOYEES', '') ELSE '' END AS BoxFCount, 
		w.BoxF, w.BoxF1, w.BoxF2,w.BoxF3, w.BoxF4, 
		CASE w.Box1 WHEN 0 THEN NULL ELSE w.Box1 END Box1, 
		CASE w.Box2 WHEN 0 THEN NULL ELSE w.Box2 END Box2,
		CASE w.Box3 WHEN 0 THEN NULL ELSE w.Box3 END Box3, 
		CASE w.Box4 WHEN 0 THEN NULL ELSE w.Box4 END Box4,
		CASE w.Box5 WHEN 0 THEN NULL ELSE w.Box5 END Box5, 
		CASE w.Box6 WHEN 0 THEN NULL ELSE w.Box6 END Box6,
		CASE w.Box7 WHEN 0 THEN NULL ELSE w.Box7 END Box7, 
		CASE w.Box8 WHEN 0 THEN NULL ELSE w.Box8 END Box8,
		CASE w.Box9 WHEN 0 THEN NULL ELSE w.Box9 END Box9, 
		CASE w.Box10 WHEN 0 THEN NULL ELSE w.Box10 END Box10,
		CASE w.Box11 WHEN 0 THEN NULL ELSE w.Box11 END Box11, 
		CASE w.Box12 WHEN 0 THEN NULL ELSE w.Box12 END Box12,
		CASE w.Box13Line1 WHEN 0 THEN NULL ELSE w.Box13Line1 END Box13Line1, 
		CASE w.Box13Line2 WHEN 0 THEN NULL ELSE w.Box13Line2 END Box13Line2,
		CASE w.Box13Line3 WHEN 0 THEN NULL ELSE w.Box13Line3 END Box13Line3, 
		CASE w.Box13Line4 WHEN 0 THEN NULL ELSE w.Box13Line4 END Box13Line4, 
		CASE w.Box14Line1 WHEN 0 THEN NULL ELSE w.Box14Line1 END Box14Line1,
		CASE w.Box14Line2 WHEN 0 THEN NULL ELSE w.Box14Line2 END Box14Line2, 
		CASE w.Box14Line3 WHEN 0 THEN NULL ELSE w.Box14Line3 END Box14Line3,
		w.Box13LineDesc1, w.Box13LineDesc2, Box13LineDesc3,  Box13LineDesc4,
		LEFT(w.Box14LineDesc1, 8) Box14LineDesc1, LEFT(w.Box14LineDesc2, 8) Box14LineDesc2, LEFT(w.Box14LineDesc3, 8) Box14LineDesc3,
		case WHEN w.Box15a = 1 then 'X'  else '' end as Box15a,
	    w.Box15b, case WHEN w.Box15c = 1 then 'X'  else '' end as Box15c, w.Box15d, case WHEN w.Box15E = 1 then 'X'  else '' end as Box15e, w.Box15f, w.Box15g,
		w.Box16a, w.Box16b, 
		CASE w.Box17 WHEN 0 THEN NULL ELSE w.Box17 END Box17, 
		CASE w.Box18 WHEN 0 THEN NULL ELSE w.Box18 END Box18, 
		w.Box19, 
		CASE w.Box20 WHEN 0 THEN NULL ELSE w.Box20 END Box20, 
		CASE w.Box21 WHEN 0 THEN NULL ELSE w.Box21 END Box21,
		w.Box19a, 
		CASE w.Box20a WHEN 0 THEN NULL ELSE w.Box20a END Box20a, 
		CASE w.Box21a WHEN 0 THEN NULL ELSE w.Box21a END Box21a, 
		CASE NJFLIAmt WHEN 0 THEN NULL ELSE w.NJFLIAmt END NJFLIAmt, #tmp.Grpcounter
	FROM dbo.tblPaW2 w inner JOIn #EmployeeList t on t.EmployeeId = w.EmployeeId
  Inner Join #tmp on  #tmp.EmployeeId = w.EmployeeId  and w.BoxD = #tmp.BoxD
	WHERE w.BoxD BETWEEN @ControlNumFrom AND @ControlNumThru
	ORDER BY BoxD


end



END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaW2FormsRpt_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaW2FormsRpt_proc';

