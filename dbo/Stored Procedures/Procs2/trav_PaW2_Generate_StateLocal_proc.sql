
CREATE PROCEDURE [dbo].[trav_PaW2_Generate_StateLocal_proc]
@PaYear smallint
AS
BEGIN TRY

--http://webfront:801/view.php?id=229528
--PET:http://webfront:801/view.php?id=229720
--PET:http://webfront:801/view.php?id=229911
--PET:http://webfront:801/view.php?id=229881
--PET:http://webfront:801/view.php?id=230036
--PET:http://webfront:801/view.php?id=236887
--MOD:Fixed Add Param State to the Loop
--MOD:Fix for Local description with no amount
--PET:http://webfront:801/view.php?id=244541

declare @FicaLimit decimal(28,10)
DECLARE
@BoxC   nvarchar(50),
@BoxB      nvarchar(17),
@BoxC1   nvarchar(70),
@BoxC2 nvarchar(50)

Declare @curEmployee cursor
Declare @curState cursor
Declare @curLocal cursor
Declare @FirstState bit
Declare @LocalCount int
Declare @Counter int
Declare @EmployeeId pEmpId
Declare @State nchar(2)
Declare @TaxId nvarchar(17)
Declare @Local nchar(2)
Declare @Code pCode
Declare @StateTaxableYTD pDecimal
Declare @StateWithholdYTD pDecimal
Declare @LocalDescr nvarchar(30)
Declare @LocalTaxableYTD pDecimal
Declare @LocalWithholdYTD pDecimal

--use a temp table to hold a list of employee/state details
--PET:http://webfront:801/view.php?id=229908
Create table #tmpStateWH 
(
	EmployeeID pEmpId,
	State nchar(2),
	TaxId nvarchar(17),
	TaxableYTD pDecimal, --Box17
	WithholdYTD pDecimal --Box18
)

--use a temp table to hold a list of employee/local details
Create table #tmpLocalWH 
(
	EmployeeID pEmpId,
	State nchar(2),
	Local nchar(2),
	Code pCode,
	Description nvarchar(30), --Box19/19a
	TaxableYTD pDecimal, --Box20/20a
	WithholdYTD pDecimal --Box21/21a
)

--use a temp table to build/subdivide the state/local totals
Create table #tmpStateLocal
(
	Counter int,
	FirstState bit, --flag to identify the first state processed for a given employee
	EmployeeID pEmpId,
	State nchar(2), --Box16a
	TaxId nvarchar(17), --Box16b
	StateTaxableYTD pDecimal, --Box17
	StateWithholdYTD pDecimal, --Box18
	LocalCodeDescr1 nvarchar(30), --Box19
	LocalTaxableYTD1 pDecimal, --Box20
	LocalWithholdYTD1 pDecimal, --Box21
	LocalCodeDescr2 nvarchar(30), --Box19a
	LocalTaxableYTD2 pDecimal, --Box20a
	LocalWithholdYTD2 pDecimal --Box21a
)


 declare @RecCount int
 Select @RecCount  =  count(*) from dbo.tblPaW2
 --SELECT @PaYear= Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'
  
   
   if @PaYear = 0

	BEGIN
		RAISERROR(90025,16,1)
	END

Select @FicaLimit=Column2 FROM ST..tblPASTTaxTablesDtl WHERE TableId='FED__FIC' AND Status='NA'
AND SequenceNumber = 1 AND PaYear = @PaYear
SET @FicaLimit=Coalesce(@FicaLimit,0)


--BEGIN: State/Local code processing
	
--build a list of state values to process for each employee
INSERT INTO #tmpStateWH (EmployeeID, State, TaxId, TaxableYTD, WithholdYTD)

SELECT w.EmployeeID, w.State,  td.TaxID, SUM(w.TaxableAmount), SUM(w.WithholdAmount)
FROM dbo.tblPaEmpHistWithhold w 
Left Join  dbo.tblPaTaxAuthorityDetail td 
    Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYEAR
	on 	w.State = th.State and w.WithholdingCode = td.Code and w.EmployerPaid= td.EmployerPaid 
and th.Type = 1  and  w.PaYear = @PaYear and th.STATe Is Not NULL 
--and td.TaxId Is Not NULL  
	 WHERE w.TaxAuthorityType = 1 and w.WithholdingCode = 'SWH' AND w.EmployerPaid= 0 and td.CodeType = 1
	AND (w.EarningAmount <> 0 or w.TaxableAmount <> 0 or w.WithholdAmount <> 0)
GROUP BY w.EmployeeID, w.TaxAuthorityType , w.WithholdingCode, w.State, td.TaxID




--SELECT w.EmployeeID, s.State, s.TaxID, SUM(w.TaxableYTD), SUM(w.WithholdYtd)
--FROM dbo.tblPaEmpHistoryWithhold w 
--	INNER JOIN dbo.tblPaStateTaxCodeDtl s 
--	ON w.TaxAuthority = s.State AND w.WithholdingCode = s.Code
--WHERE s.Code = 'SWH' AND s.ERFlag = 'E' AND w.EmployerPaidFlag = 0
--	AND (w.EarningsYTD > 0 or w.TaxableYTD > 0 or w.WithholdYTD > 0)
--GROUP BY w.EmployeeID, s.State, s.TaxID


INSERT INTO #tmpLocalWH (EmployeeID, State, Local, Code, Description, TaxableYTD, WithholdYTD)
SELECT w.EmployeeID, w.State, w.Local, w.WithholdingCode, td.Description, SUM(w.TaxableAmount), SUM(w.WithholdAmount)
FROM dbo.tblPaEmpHistWithhold w 
Left Join  dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYear
	on 	w.State = th.State and  w.Local = th.Local and w.WithholdingCode = td.Code and w.EmployerPaid=  td.EmployerPaid 
WHERE w.EmployerPaid = 0 and  w.PaYear = @PaYEAR and w.TaxAuthorityType  = 2 and td.CodeType = 1
AND (w.EarningAmount <> 0 or w.TaxableAmount <> 0 or w.WithholdAmount <> 0)
GROUP BY w.EmployeeID, w.State, w.Local, w.WithholdingCode, td.Description



--Initialize the counter for the state/local temp table
Set @Counter = 0

--loop through the list of employees to process
Set @curEmployee = cursor forward_only static for
	Select EmployeeID From dbo.tblPaW2 Where FirstLine = 1
Open @curEmployee
If @@cursor_rows <> 0
Begin
	Fetch next from @curEmployee
		into @EmployeeId
	While @@Fetch_Status = 0
	Begin
		--increment the new record key
		Select @Counter = @Counter + 1

		--initialiaze the first state code flag for each Employee processed
		set @FirstState = 1

		--Loop through the list of states for each employee
		Set @curState = cursor forward_only static for
			Select State, TaxId, TaxableYTD, WithholdYTD 
				From #tmpStateWH
				Where EmployeeId = @EmployeeId
				Order by State
		Open @curState
		If @@cursor_rows <> 0
		Begin
			Fetch next from @curState
				into @State, @TaxId, @StateTaxableYTD, @StateWithholdYTD
			While @@Fetch_Status = 0
			Begin
				--create a record for the state being processed
				Insert into #tmpStateLocal (Counter, FirstState
					, EmployeeID, State, TaxId
					, StateTaxableYTD, StateWithholdYTD
					, LocalCodeDescr1, LocalTaxableYTD1, LocalWithholdYTD1
					, LocalCodeDescr2, LocalTaxableYTD2, LocalWithholdYTD2)
				Values (@Counter, @FirstState
					, @EmployeeId, @State, @TaxId
					, @StateTaxableYTD, @StateWithholdYTD
					, null, 0, 0, null, 0, 0)
				--IF @@ERROR<>0 GOTO ErrHandler

				--clear the first state flag
				set @FirstState = 0

				--initialize the local code counter for each state processed
				set @LocalCount = 1

				--Loop through the list of Locals for each Employee/State
				Set @curLocal = cursor forward_only static for
					Select t.Local, t.Code, t.Description, t.TaxableYTD, t.WithholdYTD
						From #tmpLocalWH t
						Where t.EmployeeId = @EmployeeId And t.State = @State
						Order by t.Local, t.Code
				Open @curLocal
				If @@cursor_rows <> 0
				Begin
					Fetch next from @curLocal
						into @Local, @Code, @LocalDescr, @LocalTaxableYTD, @LocalWithholdYTD
					While @@Fetch_Status = 0
					Begin
						IF @LocalCount = 1
						Begin
							--update local 1 of the current record (@counter)
							Update #tmpStateLocal
								Set LocalCodeDescr1 = @LocalDescr
									, LocalTaxableYTD1 = @LocalTaxableYTD
									, LocalWithholdYTD1 = @LocalWithholdYTD
							Where Counter = @Counter And State = @State
							
						End	
						Else IF (@LocalCount % 2) = 0
						Begin
							--update local 2 of the current record (@counter) when count is evenly divisible by 2 
							Update #tmpStateLocal
								Set LocalCodeDescr2 = @LocalDescr
									, LocalTaxableYTD2 = @LocalTaxableYTD
									, LocalWithholdYTD2 = @LocalWithholdYTD
							Where Counter = @Counter  And State = @State
						
						End
						Else 
						Begin
							--increment the new record key
							Select @Counter = @Counter + 1

							--create a new record for the Local totals and populate local 1 values
							Insert into #tmpStateLocal (Counter, FirstState
								, EmployeeID, State, TaxId
								, StateTaxableYTD, StateWithholdYTD
								, LocalCodeDescr1, LocalTaxableYTD1, LocalWithholdYTD1
								, LocalCodeDescr2, LocalTaxableYTD2, LocalWithholdYTD2)
							Values (@Counter, @FirstState
								, @EmployeeId, @State, @TaxId
								, 0, 0 --(state totals don't duplicate)
								, @LocalDescr, @LocalTaxableYTD, @LocalWithholdYTD
								, null, 0, 0)

						End

						--increment the local count 
						Select @LocalCount = @LocalCount + 1

						Fetch next from @curLocal
							into @Local, @Code, @LocalDescr, @LocalTaxableYTD, @LocalWithholdYTD
					End
					Close @curLocal
				End
				Deallocate @curLocal

				Fetch next from @curState
					into @State, @TaxId, @StateTaxableYTD, @StateWithholdYTD
			End
			Close @curState
		End
		Deallocate @curState

		--process the next employee
		Fetch next from @curEmployee
			into @EmployeeId
	End
	Close @curEmployee
End
Deallocate @curEmployee

--update the default W2 records with the values from the first state processed
Update dbo.tblPaW2 Set 
	Box16a = State,
	Box16b = TaxId,
	Box17 = Case When FirstLine = 1 Then StateTaxableYTD Else 0 End,
	Box18 = Case When FirstLine = 1 Then StateWithholdYTD Else 0 End,
	Box19 = Case When FirstLine = 1 Then LocalCodeDescr1 Else Null End,
	Box20 = Case When FirstLine = 1 Then LocalTaxableYTD1 Else 0 End,
	Box21 = Case When FirstLine = 1 Then LocalWithholdYTD1 Else 0 End,
	Box19a = Case When FirstLine = 1 Then LocalCodeDescr2 Else Null End,
	Box20a = Case When FirstLine = 1 Then LocalTaxableYTD2 Else 0 End,
	Box21a = Case When FirstLine = 1 Then LocalWithholdYTD2 Else 0 End 
From #tmpStateLocal
Where dbo.tblPaW2.EmployeeId = #tmpStateLocal.EmployeeId
	And #tmpStateLocal.FirstState = 1 

--create new W2 records for additional states or multiple local codes
INSERT INTO dbo.tblPaW2(EmployeeID, Box16a, Box16b, Box17, Box18
	, Box19, Box20, Box21, Box19a, Box20a, Box21a)
SELECT EmployeeID, State, TaxID, StateTaxableYTD, StateWithholdYTD
	, LocalCodeDescr1, LocalTaxableYTD1,LocalWithholdYTD1
	, LocalCodeDescr2, LocalTaxableYTD2, LocalWithholdYTD2
From #tmpStateLocal
Where #tmpStateLocal.FirstState = 0

--END: State/Local code processing

UPDATE dbo.tblPaW2 SET BoxA=s.SocialSecurityNo, BoxE=UPPER(COALESCE (s.FirstName, '') + ' ' + COALESCE (s.MiddleInit, '')), BoxE1 = UPPER(COALESCE (s.LastName, '')), BoxF=coalesce(s.AddressLine1,'') + '  ' + coalesce(s.AddressLine2,''),
BoxF1 = LEFT(s.ResidentCity, 25), BoxF2=s.ResidentState, BoxF3=s.ZipCode, BoxF4=s.CountryCode,
	Box15a=v.StatutoryEmployee, Box15b=v.Deceased, 
	Box15c=(v.ParticipatingIn401k | v.EligibleForPension),
	Box15g=v.ParticipatingIn401k
FROM dbo.tblPaW2 INNER JOIN dbo.tblPaEmployee v ON dbo.tblPaW2.EmployeeID=v.EmployeeID
Inner Join dbo.tblSmEmployee s on dbo.tblPaW2.EmployeeID=s.EmployeeID

--sp_helptext 'dbo.trav_tblSmEmployee_view'

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
declare --@TaxAuth nvarchar(2), @Emp nvarchar(11), 
@Count int, 
@Lastname nvarchar(20)
set @Count=0
declare curControl cursor for
	SELECT case a.employeeid when 'zzzzzzzzzzz' then 'zzzzzzzzzzz' else b.lastname end lastname
	FROM dbo.tblPaW2 a LEFT JOIN dbo.tblSmEmployee b 
	ON a.EmployeeID = b.EmployeeID order by a.box16a, lastname, a.EmployeeID, a.Box13lineDesc1, a.Box13lineDesc2, a.Box13lineDesc3
	
	
open curControl
fetch next from curControl INTO  @Lastname
While (@@FETCH_STATUS=0)
begin
	set @Count=@Count+1
	Update dbo.tblPaW2 SET BoxD=@Count
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
WHEN 'G'  THEN Box13line4 WHEN 'H'  THEN Box13line4 WHEN 'S' THEN Box13line4  WHEN 'Y' THEN Box13line4 WHEN 'AA'  THEN Box13line4 WHEN 'BB' THEN Box13line4  WHEN 'EE' THEN Box13line4 ELSE 0 end),
--SUM(CASE  Box13lineDesc1 WHEN 'CC'  THEN Box13line1 ELSE 0 end)
-- + SUM(CASE  Box13lineDesc2 WHEN 'CC'  THEN Box13line2 ELSE 0 end)
-- + SUM(CASE  Box13lineDesc3 WHEN 'CC'  THEN Box13line3 ELSE 0 end)
-- + SUM(CASE  Box13lineDesc4 WHEN 'CC'  THEN Box13line4 ELSE 0 end),
0, 'GRAND TOTALS', CONVERT(nvarchar(10),COUNT(DISTINCT employeeid)) + ' EMPLOYEES' 
FROM dbo.tblPaW2
WHERE EmployeeID <> 'zzzzzzzzzzz'

end


--BoxB, BoxC, BoxC1, BoxC2
--SELECT @BoxB =  TaxId FROM  dbo.tblPaTaxAuthorityDetail WHERE CodeType=1
SELECT @BoxB = td.TaxId from dbo.tblPaTaxAuthorityDetail td 
   Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId  WHERE  td.CodeType=1  and th.Type = 0
and  td.PaYear = @PaYear

--SELECT @BoxC = [Name], @BoxC1 = ISNULL(Addr1,'') + '  ' + ISNULL(Addr2,'') , @BoxC2 = City + ' ' +  Region + ' ' + PostalCode FROM dbo.tblSysCompInfo

UPDATE dbo.tblPaW2 SET BoxB = @BoxB, BoxC= @BoxC, BoxC1 = @BoxC1, BoxC2 = @BoxC2

Select * from dbo.tblPaW2




Return @@Error

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaW2_Generate_StateLocal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaW2_Generate_StateLocal_proc';

