
CREATE PROCEDURE [dbo].[trav_PaAatrixrecords_proc]
AS
SET NOCOUNT ON
BEGIN TRY

--MOD:Fixed SET QUOTED_IDENTIFIER ON for the Hier Act.
--PET:http://webfront:801/view.php?id=230899
--PET:http://webfront:801/view.php?id=230898
--PET:http://webfront:801/view.php?id=230985
--MOD:fixed condition for CLI record 
--MOD:Fixed for NY Uunempl report
--PET:http://webfront:801/view.php?id=236653
--MOD:changes for the AUF_0212
--MOD:changes for the AUF_0226
--MOD:changes for History reports, send CompEIN and comp record in History mode.
--MOD:ADD Line 5d additional Medicare Wages over 200000 for 941 report.
--Works with the AUF_0230 Version 2.30
--PET:http://webfront:801/view.php?id=249000
--MOD:change for the AUF_0247 Version 2.47 removed fix for PET:http://webfront:801/view.php?id=249000
--MOD:fix for the Multiple departments
--PET:http://webfront:801/view.php?id=249971

Create table #EmpRef
( EmpNum [int] IDENTITY (1, 1) NOT NULL ,
  EmployeeId nvarchar(11),
  --HireAct bit
)

--Capture the employee HireAct settings 
--	(use dynamic SQL for referencing the custom field value)

EXEC('SET QUOTED_IDENTIFIER ON ;
Insert Into #EmpRef (EmployeeId)
Select e.EmployeeId from dbo.tblPaEmployee e
INNER Join dbo.trav_tblSmEmployee_view v on e.EmployeeId = v.EmployeeId')

Declare @VersNum decimal(10,2), @SrcVendor nvarchar(30), @CompName nvarchar(50),
@SrcProgram nvarchar(30), @COMPID nvarchar(3), @PaYEAR smallint, 
@Qtr smallint, @Month smallint, @StartDate datetime, 
@EndDate datetime, @STFEFlag as nvarchar(2), 
@FrmId nvarchar(32), @Mode nvarchar(8), @CompEIN as nvarchar(10), @NumOfEmp int, 
@FormType nvarchar(15), @DataBreakout int, @VendorCode as nvarchar(10), @CompNum int
declare @DCBLimit as decimal, @ConfigValue nvarchar(255), @AddressLine1 nvarchar(30), 
@AddressLine2 nvarchar(30), @City nvarchar(30), 
@PostalCode nvarchar(10), @Region nvarchar(10), @PhoneNumber nvarchar(20) 
declare @Country nvarchar(6), @FaxNumber nvarchar(20), @Email nvarchar(255), @CountryName nvarchar(50)
Declare @UserId pUserId, @WrkStnId pWrkStnId
Declare @MedAmtLimit pdec
set @MedAmtLimit = 0


SElect  @DCBLimit = 0


--
----Header Records:
----VER
-----@VersNum = 1.77
--Select @COMPID = Cast([Value] AS nvarchar(3)) from #GlobalValues WHERE [Key] = 'CompID' 
--Select @SrcVendor = Cast([Value] AS nvarchar(30)) from #GlobalValues WHERE [Key] = 'SourceVendor' 
--Select @SrcProgram = Cast([Value] AS nvarchar(30)) from #GlobalValues WHERE  [Key] = 'SourceProgram' 
--Select @VersNum = ROUND(Cast([Value] as decimal), 2) from #GlobalValues WHERE [Key] = 'VersNum'
--Select @Email = Cast([Value] AS nvarchar(255)) from #GlobalValues WHERE [Key] = 'Email'  
--Select * From dbo.tblPaAatrixInfo


--Config Info.
Select @FrmId = Cast([Value] AS nvarchar(32)) from dbo.tblPaAatrixInfo WHERE [ID] = 'FormName' 
Select @Mode = Cast([Value]  AS nvarchar(8)) from dbo.tblPaAatrixInfo WHERE [ID] = 'Mode' 
Select @VendorCode = Cast([Value] AS nvarchar(10)) from dbo.tblPaAatrixInfo WHERE [ID] = 'VendorCode'

Select @STFEFlag = Cast([Value] AS nvarchar(2)) from  dbo.tblPaAatrixInfo WHERE [ID] = 'STFEFlag' 
Select @FormType = Cast([Value] AS nvarchar(15)) from dbo.tblPaAatrixInfo WHERE [ID] = 'FormType' 
Select @DataBreakout =  Cast([Value] AS smallint) from dbo.tblPaAatrixInfo WHERE [ID] = 'DataBreakout' 
 

--Header Records:
--VER
---@VersNum = 1.77
Select @COMPID=SUBSTRING(DB_NAME(),1,3)
Select @SrcVendor = Cast([Value] AS nvarchar(30)) from dbo.tblPaAatrixInfo WHERE [ID] = 'SourceVendor' 
Select @SrcProgram = Cast([Value] AS nvarchar(30)) from dbo.tblPaAatrixInfo WHERE [ID] = 'SourceProgram' 

Select @VersNum = ROUND(convert(decimal(10,2), CONVERT(nvarchar(20), Value)), 2) from dbo.tblPaAatrixInfo WHERE [ID] = 'VersNum' 

--DAT
--default value
Select @PaYEAR = Cast([Value] AS smallint) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'PaYear'
SELECT @Month = Cast([Value] AS smallint) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'Month'
SELECT @Qtr = Cast([Value] AS smallint) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'Qtr' 

--Select @StartDate=coalesce(convert(datetime, Value), convert(datetime,'01/01/2004')) from dbo.stpPaAatrixInfo WHERE [ID] = 'StartDate' 
--Select @EndDate=coalesce(convert(datetime, Value), convert(datetime,'12/31/2004')) from dbo.stpPaAatrixInfo WHERE [ID] = 'EndDate' 
SELECT @StartDate = Cast([Value] AS datetime) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'StartDate'
SELECT @EndDate = Cast([Value] AS datetime) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'EndDate'

Select @CompName = Cast([Value] AS nvarchar(30)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'CompName' 
Select @Country  = Cast([Value] AS nvarchar(6)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'Country' 

Select @CompEIN = Left(Cast([Value] AS nvarchar(15)) , 10) from dbo.tblPaAatrixInfo WHERE [ID] = 'FEIN' 
Select @NumOfEmp = Cast([Value] AS int) from dbo.tblPaAatrixInfo WHERE [ID] = 'NumOfEmp'
Select @DCBLimit = Cast([Value] AS Decimal(28,10)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'DCBLimit' 

Select @City = Cast([Value] AS nvarchar(30)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'City' 

Select @Region  = Cast([Value] AS nvarchar(10)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'Region' 

Select @PostalCode  = Cast([Value] AS nvarchar(10)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'PostalCode' 

Select @Email  = Cast([Value] AS nvarchar(255)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'Email' 

Select @AddressLine1  = Cast([Value] AS nvarchar(30)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'AddressLine1' 

Select @AddressLine2  = Cast([Value] AS nvarchar(30)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'AddressLine2' 

Select @PhoneNumber  = Cast([Value] AS nvarchar(30)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'PhoneNumber' 

Select @FaxNumber = Cast([Value] AS nvarchar(20)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'FaxNumber' 
Select @CountryName = Cast([Value] AS nvarchar(50)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'CountryName' 

Select @UserId  = Cast([UserId] AS nvarchar(255)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'CompId' 

Select @WrkStnId  = Cast([WrkStnId] AS nvarchar(255)) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'CompId' 

SElect  @MedAmtLimit= Column1 From [ST].dbo.tblPaSTTaxTablesDtl Where PaYear = @PaYEAR and Left(TableId, 3) = 'FED' and right(TableId, 3) = 'MED' and status = 'NA' and  SequenceNumber = 2 
	


Select @CompNum  = 1




   IF @FrmId IS NULL  OR @VendorCode IS NULL OR @FormType IS NULL OR @Month IS NULL OR @CompEIN IS NULL Or
	@PaYEAR IS NULL or @StartDate IS NULL  or @EndDate IS NULL 



	BEGIN
		RAISERROR(90025,16,1)
	END
   



--//----------------------------
--
----Config Info.
--Select @FrmId = Cast([Value] AS nvarchar(32)) from #GlobalValues WHERE [Key] = 'FormName' 
--Select @Mode = Cast([Value]  AS nvarchar(8)) from #GlobalValues WHERE [Key] = 'Mode' 
--Select @VendorCode = Cast([Value] AS nvarchar(10)) from #GlobalValues WHERE [Key] = 'VendorCode'
--
--Select @STFEFlag = Cast([Value] AS nvarchar(2)) from d#GlobalValues WHERE [Key] = 'STFEFlag' 
--Select @FormType = Cast([Value] AS nvarchar(15)) from #GlobalValues WHERE [Key] = 'FormType' 
--Select @DataBreakout =  Cast([Value] AS smallint) from #GlobalValues WHERE [Key] = 'DataBreakout' 
-- 
--
----Header Records:
----VER
-----@VersNum = 1.77
--Select @COMPID=SUBSTRING(DB_NAME(),1,3)
--Select @SrcVendor = Cast([Value] AS nvarchar(3)) from #GlobalValues WHERE [Key] = 'SourceVendor' 
--Select @SrcProgram = Cast([Value] AS nvarchar(3)) from #GlobalValues WHERE [Key] = 'SourceProgram' 
--
--Select @VersNum = ROUND(convert(decimal(10,2), CONVERT(nvarchar(20), Value)), 2) from #GlobalValues WHERE [Key] = 'VersNum' 
--
----DAT
----default value
--Select @PaYEAR = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'
--SELECT @Month = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Month'
--SELECT @Qtr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Qtr' 
--
----Select @StartDate=coalesce(convert(datetime, Value), convert(datetime,'01/01/2004')) from dbo.stpPaAatrixInfo WHERE [ID] = 'StartDate' 
----Select @EndDate=coalesce(convert(datetime, Value), convert(datetime,'12/31/2004')) from dbo.stpPaAatrixInfo WHERE [ID] = 'EndDate' 
--SELECT @StartDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'StartDate'
--SELECT @EndDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'EndDate'
--
--Select @CompName = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'CompName' 
--Select @Country  = Cast([Value] AS nvarchar(50)) FROM #GlobalValues WHERE [Key] = 'Country' 
--
--Select @CompEIN = Left(Cast([Value] AS nvarchar(15)) , 10) from #GlobalValues WHERE [Key] = 'FEIN' 
--Select @NumOfEmp = Cast([Value] AS int) from #GlobalValues WHERE [Key] = 'NumOfEmp' 
--Select @DCBLimit = Cast([Value] AS Decimal(28,10)) FROM #GlobalValues WHERE [Key] = 'DCBLimit'
--//--------------------------------------------










--Select @NumOfEmp = Count(*) from dbo.tblPaEmpEmployee

--EXEC dbo.glbPaSmGetSingleConfigValue_sp 'PA',null,'DCBLmt', @ConfigValue out 
--SET @DCBLimit = case when CAST(@ConfigValue AS Decimal(28,10)) = 0 then 5000 else ISNULL(CAST(@ConfigValue AS Decimal(28,10)), 5000) end 
--DCBLmt




--Insert into ST.dbo.tblPaAatrixPIMRef (State, Code, TaxType, Descr)
--Select s.State, s.Code, 0, s.[Description] 
	--From dbo.tblPaStateTaxCodeDtl s
	--Left Join ST.dbo.tblPaAatrixPIMRef p on s.State = p.State and s.Code = p.Code
	--Where p.Code is null

--HierAct

declare @MonthBegin smallint 
declare @MonthEnd smallint

declare @Year smallint
select @Year = 2010

Select @Qtr = convert(smallint, Value) from dbo.tblPaAatrixInfo WHERE [ID] = 'Qtr' 

SELECT @MonthBegin = (@Qtr * 3) - 2
SELECT @MonthEnd = @Qtr * 3




--Config Info.

Select 'ConfInfo' as ConfInfo, @FrmId FormName, 
@Mode Mode, @FormType FormType, @DataBreakout DataBreakout, @VendorCode VendorCode, @CompEIN Company
If @Mode = 'History'
begin
--CMP	
	Select 
		'CMP' as CMP
		, @CompNum as [ID]
		, @CompName as CompanyName
		, @CompName as TradeName
		, substring(@AddressLine1, 1 , 22) AddressLine1
		, substring(@AddressLine2, 1, 22) AddressLine2
		, @City as City
		, @Region as State
		, NULL as County
		, NULL as CountyCode
		, @PostalCode as ZipCode
		, @Country as Country
		, @CountryName as CountryCode --Name
		, NULL CountryZipCode
		, NULL as DBA
		, NULL as Branch
		, NULL as TaxArea
		, @PhoneNumber as PhoneNumber
		, NULL as PhoneExt
		, @FaxNumber as FaxNumber
		, NULL IndustryCode
		, @CompEIN EIN
		, null
		, null
		, NULL as ContactTitle
		, NULL as ContactName
		, NULL as ContactPhone
		, NULL as ContactPhoneExt
		, NULL as ContactAddress
		, coalesce(@NumOfEmp,0) NumberOfEmployees
		, null
        , case When cast(CHARINDEX('#', @Email) as int) > 0 then LEFT(cast(@Email as nvarchar(40)), Cast(CHARINDEX('#', @Email) as int) -1) end EMailAddress
		, null
		, null
		, null
      	, NULL as TerminationDate
  --   , NULL ForeignStateProvince
       , NULL NonUSStateProvince
        , 'R' EmploymentCode
     --  'R','M''A''H''F''X' 
      ,  NULL as NationalIDNumber
        --Version 2.8
--Enter the kind of employer, which corresponds to the Kind of Employer on the W3. 
--?N = None apply - None of the codes below apply.
-- ?T = 501c non-govt. (tax exempt employer) - Use this code if this is a non-governmental tax-exempt section 501(c) organization.
-- ?S = State/local non-501c (state and local governmental employer) - Use this code if this is a state or local government or instrumentality that is not a tax-exempt section 501(c) organization.
-- ?Y = State/local 501c (state and local tax exempt employer) - Use this code if this is a dual status state or local government or instrumentality that is also a tax-exempt section 501(c) organization.
-- ?F = Federal govt. - Use this code if this is a Federal government entity or instrumentality.
 
       ,NULL as KindOfEmployer
      
     
	--FROM sys.dbo.glbCompInfo c Inner Join  sys.dbo.lkpSmCountry t on c.Country =  t.Country  
		--WHERE c.CompID = @CompId 

end


If @Mode <> 'History'
begin
	--VER
	
	Select 'VER' as VER, 'ID' as [ID], @VersNum VersionNumber, @SrcVendor SourceVendor, @SrcProgram SourceProgram 
	
	--DAT
	
	Select 'DAT' DAT, 'ID' as [ID], @PaYEAR [YEAR], @Qtr [Quarter], 
	@Month  [Month], @StartDate  FirstDate, @EndDate  LastDate 
	
	--PIM
	
	
--PIM
--declare  @PAYEAR smallint
--set  @PAYEAR = 2010
--
--declare @StartDate Datetime,  @EndDate  Datetime 
--set @StartDate = '1/1/2010'
--set  @EndDate = '1/31/2010'


	Select 'PIM' as PIM, 'ID' as [ID], 
	case WHEN (h.TaxAuthority = 'FE' and IsNULL(h.code, '') <> '') then
	h.code else CASE WHEN ISnULL(p.LocalCode, '') <> '' then  p.State + ISnULL(p.LocalCode, '') + p.Code else p.State + p.Code end end  
	Title, p.PIMID, p.Descr, p.TaxType, p.State, 
	case WHEN p.State = 'FE' then 'W2Code' else Null end  as W2LocalityTaxTypeCode, ISNULL(td.TaxId, '') AcctNumber 
	From St.dbo.trav_PaAatrixPIMRef_view p
	Left Join  dbo.tblPaTaxAuthorityDetail td 
    Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYEAR
	on 	p.State = th.State and p.Code = td.Code and p.EmployerPaid = td.EmployerPaid and th.Type = 1  and th.STATe Is Not NULL and td.TaxId Is Not NULL 
   
   left Join 
  (Select w.TaxAuthority, w.WithholdingCode, w.code
	from 
	(Select case wh.[TaxAuthorityType] when (0) then 'FED' 
	when (1) then wh.[State] else wh.[State]+ wh.[Local] end as TaxAuthority,
	  wh.WithholdingCode, '' as code
			From dbo.tblPaCheckHistWithhold wh 
			Inner Join dbo.tblPaCheckHist ch 
				on wh.PostRun = ch.PostRun and wh.CheckId  = ch.Id and  ch.CheckDate Between @StartDate And @EndDate 
	) w
	  
	Group By w.TaxAuthority, w.WithholdingCode, w.code

    union all

	Select  R.TaxAuthority, R.WithholdingCode, R.code
	from 
	(Select  case wh.[TaxAuthorityType] when (0) then 'FED' 
	when (1) then wh.[State] else wh.[State]+ wh.[Local] end as TaxAuthority,
	  wh.WithholdingCode, '' as code
			From dbo.tblPaCheckHistEmplrTax wh 
			Inner Join dbo.tblPaCheckHist ch 
				on wh.PostRun = ch.PostRun and wh.CheckId  = ch.Id and  ch.CheckDate Between @StartDate And @EndDate 
	 ) R
		 
		Group By R.TaxAuthority,R.WithholdingCode, R.code

		Union all

		Select 'FE' TaxAuthority,  
		ISNULL(D.W2Box, Ec.W2Box) + Left(ISNULL(D.W2Code, Ec.W2Code), 1) as WithholdingCode, ISNULL(D.W2Code, Ec.W2Code) as code
		from
		(Select D.W2Box, D.W2Code, h.PostRun, h.CheckId
			from dbo.tblPaCheckHistDeduct h 
			Inner Join dbo.tblPaDeductCode D on
			h.DeductionCode = D.DeductionCode and  D.EmployerPaid = 0
			union All
			SElect D.W2Box, D.W2Code, h.PostRun, h.CheckId
			from dbo.tblPaCheckHistEmplrCost h 
			Inner Join dbo.tblPaDeductCode D on
			h.DeductionCode = D.DeductionCode  and  D.EmployerPaid = 1

			) D
			Inner Join dbo.tblPaCheckHist ch 
			on D.PostRun = ch.PostRun and D.CheckId = ch.Id
			Left Join dbo.tblPaCheckHistEarn e 
			Inner Join dbo.tblPaEarnCode ec on
			e.EarningCode = ec.Id
			on e.PostRun = D.PostRun and e.CheckId = D.CheckId
			WHERE (D.W2Code Is Not NULL and D.W2Box = '14') or (Ec.W2Code Is Not NULL and Ec.W2Box = '14') 
			and ch.CheckDate Between @StartDate And @EndDate 
			Group By ISNULL(D.W2Box, Ec.W2Box) + Left(ISNULL(D.W2Code, Ec.W2Code), 1), ISNULL(D.W2Code, Ec.W2Code) 
		) h
    
		on p.State = h.TaxAuthority and p.Code = h.WithholdingCode  
		--WHERE P.state = 'FE'



	--CMP	
	Select 
		'CMP' as CMP
		, @CompNum as [ID]
		, @CompName as CompanyName
		, @CompName as TradeName
		, substring(@AddressLine1, 1 , 22) AddressLine1
		, substring(@AddressLine2, 1, 22) AddressLine2
		, @City as City
		, @Region as State
		, NULL as County
		, NULL as CountyCode
		, @PostalCode as ZipCode
		, @Country as Country
		, @CountryName as CountryCode --Name
		, NULL CountryZipCode
		, NULL as DBA
		, NULL as Branch
		, NULL as TaxArea
		, @PhoneNumber as PhoneNumber
		, NULL as PhoneExt
		, @FaxNumber as FaxNumber
		, NULL IndustryCode
		, @CompEIN EIN
		, null
		, null
		, NULL as ContactTitle
		, NULL as ContactName
		, NULL as ContactPhone
		, NULL as ContactPhoneExt
		, NULL as ContactAddress
		, coalesce(@NumOfEmp,0) NumberOfEmployees
		, null
        , case When cast(CHARINDEX('#', @Email) as int) > 0 then LEFT(cast(@Email as nvarchar(40)), Cast(CHARINDEX('#', @Email) as int) -1) end EMailAddress
		, null
		, null
		, null
      	, NULL as TerminationDate
  --   , NULL ForeignStateProvince
       , NULL NonUSStateProvince
        , 'R' EmploymentCode
     --  'R','M''A''H''F''X' 
      ,  NULL as NationalIDNumber
        --Version 2.8
--Enter the kind of employer, which corresponds to the Kind of Employer on the W3. 
--?N = None apply - None of the codes below apply.
-- ?T = 501c non-govt. (tax exempt employer) - Use this code if this is a non-governmental tax-exempt section 501(c) organization.
-- ?S = State/local non-501c (state and local governmental employer) - Use this code if this is a state or local government or instrumentality that is not a tax-exempt section 501(c) organization.
-- ?Y = State/local 501c (state and local tax exempt employer) - Use this code if this is a dual status state or local government or instrumentality that is also a tax-exempt section 501(c) organization.
-- ?F = Federal govt. - Use this code if this is a Federal government entity or instrumentality.
 
       ,NULL as KindOfEmployer
      
     
	--FROM sys.dbo.glbCompInfo c Inner Join  sys.dbo.lkpSmCountry t on c.Country =  t.Country  
		--WHERE c.CompID = @CompId 

	
	--GTO - general totals 

	Select 
		'GTO' as GTO
		, 'ID' as [ID]
		, null
		, ch.CheckDate
		, Sum(ch.GrossPay) GrossPay
		, Sum(ch.NetPay) NetPay
		, null
		, sum(WhSum.SSEarnings) - Sum(ch.FicaTips) SSWages
		, Sum(WhSum.SSWithheld) SSLiability
		, Sum(WhSum.MedEarnings) MedWages
		, Sum(WhSum.MedWithheld) MedLiability
		, Sum(WhSum.FedEarnings) FedEarnings
		, Sum(WhSum.FedWithheld) FedLiability
		, Sum(etSum.FUTAEarnings) TaxableFUTAWages
		, Sum(etSum.FUTAWithheld) FUTALiability
		, null
		, null
		, null
		, null
		, Sum(WhSum.EICWithheld * -1) EIC
		, Sum(ch.FicaTips) SSTips
		, Sum(etSum.FUTAGrossEarnings) TotalFUTAWages
		, null PayPeriodStartDate
		, null PayPeriodEndDate
		, null
		, null
		, null
		, null [940Deposit]
		, null [941Deposit]
		, null [943Deposit]
		, null [945Deposit]
		, Sum(etSum.EOAWithheld) SSEmployerMatch
		, Sum(etSum.EMEWithheld) MedicareEmployerMatch
		, Coalesce(0,0) AdditionalMedicareTax
		, Sum(Coalesce(wsum.AdditionalMedicareWages, 0)) AdditionalMedicareWages
		
		, @CompNum as [PID]
	From dbo.tblPaCheckHist ch
	 Left JOIN (
 

  Select  adwh.PostRun,   adwh.CheckID, sum( adwh.AdditionalMedicareTax) AdditionalMedicareTax, sum( adwh.AdditionalMedicareWages)AdditionalMedicareWages
  from
  (

   Select addmed.EmployeeId, addmed.EmpNum, Max(addmed.PostRun) PostRun, Max(addmed.CheckID) CheckID
	, SUM(addmed.MEDCurrWithheld) as AdditionalMedicareTax
	, SUM(CASE WHEN addmed.MEDPRIEREarnings + addmed.MEDCurrEarnings <= @MedAmtLimit THEN 0 ELSE
    CASE WHEN addmed.MEDPRIEREarnings >= @MedAmtLimit THEN MEDCurrEarnings
    ELSE addmed.MEDCurrEarnings - (@MedAmtLimit - addmed.MEDPRIEREarnings) END END) AS AdditionalMedicareWages
		 
	from
	(
	Select c.EmployeeId, r.EmpNum
			, Max(Case When w.WithholdingCode = 'MED' and c.CheckDate Between  @StartDate And  @EndDate Then w.PostRun Else '' End) PostRun
			, Max(Case When w.WithholdingCode = 'MED' and c.CheckDate Between  @StartDate And  @EndDate Then w.CheckID Else '' End) CheckID
			, sum(Case When w.WithholdingCode = 'MED' and c.CheckDate Between  Cast(Cast(@PaYEAR  as nvarchar(4)) + '0101' as datetime) And  @StartDate and @PaYEAR >= 2013 Then w.WithholdingAmount Else 0 End) MEDPRIERWithheld
			, sum(Case When w.WithholdingCode = 'MED' and c.CheckDate Between  Cast(Cast(@PaYEAR  as nvarchar(4)) + '0101' as datetime) And  @StartDate and @PaYEAR >= 2013 Then w.WithholdingEarnings Else 0 End) MEDPRIEREarnings
			, sum(Case When w.WithholdingCode = 'MED' and c.CheckDate Between  @StartDate And  @EndDate Then w.WithholdingAmount Else 0 End) MEDCurrWithheld
			, sum(Case When w.WithholdingCode = 'MED' and c.CheckDate Between  @StartDate And  @EndDate Then w.WithholdingEarnings Else 0 End) MEDCurrEarnings
			From dbo.tblPaCheckHistWithhold w inner Join  dbo.tblPaCheckHist c on  w.PostRun = c.PostRun and c.Id= w.CheckId
			INNer Join #EmpRef r on c.EmployeeId = r.EmployeeId
		Where c.Voided = 0 and w.TaxAuthorityType = 0
		-- and @PaYEAR >= 2013
	   Group by  c.EmployeeId, r.EmpNum
	   ) addmed Group by  addmed.EmployeeId, addmed.EmpNum) adwh  Group by adwh.PostRun, adwh.CheckId) wsum
	  on  wsum.PostRun = ch.PostRun and wsum.CheckID = ch.Id
	  
	Left Join
	(Select PostRun, CheckId, sum(SSWithheld) SSWithheld, sum(SSEarnings) SSEarnings, sum(MEDWithheld) MEDWithheld,
	  sum(MEDEarnings) MEDEarnings, sum(FEDWithheld) FEDWithheld, sum(FEDEarnings) FEDEarnings, 
	  sum(EICWithheld) EICWithheld, sum(EICEarnings) EICEarnings           
	  From (Select PostRun, CheckId
			, Case When WithholdingCode = 'OAS' Then WithholdingAmount Else 0 End SSWithheld
			, Case When WithholdingCode = 'OAS' Then WithholdingEarnings Else 0 End SSEarnings
			, Case When WithholdingCode = 'MED' Then WithholdingAmount Else 0 End MEDWithheld
			, Case When WithholdingCode = 'MED' Then WithholdingEarnings Else 0 End MEDEarnings
			, Case When WithholdingCode = 'FWH' Then WithholdingAmount Else 0 End FEDWithheld
			, Case When WithholdingCode = 'FWH' Then WithholdingEarnings Else 0 End FEDEarnings
			, Case When WithholdingCode = 'EIC' Then WithholdingAmount Else 0 End EICWithheld
			, Case When WithholdingCode = 'EIC' Then WithholdingEarnings Else 0 End EICEarnings
			From dbo.tblPaCheckHistWithhold
			Where  TaxAuthorityType = 0) wh 
	Group by PostRun, CheckId) WhSum
	on ch.PostRun = WhSum.PostRun and ch.Id = WhSum.CheckId
		Left Join 
	
	(Select PostRun, CheckId, sum(FUTAWithheld) FUTAWithheld, sum(FUTAEarnings) FUTAEarnings, 
	sum(FUTAGrossEarnings) FUTAGrossEarnings, 
	sum(EMEEarnings) EMEAEarnings, sum(EMEGrossEarnings) EMEGrossEarnings, sum(EMEWithheld) EMEWithheld,
	sum(EOAEarnings) EOAEarnings, sum(EOAGrossEarnings) EOAGrossEarnings, sum(EOAWithheld) EOAWithheld        
    
	from
	(Select PostRun, TaxAuthorityType, WithholdingCode, CheckId
			, Case When WithholdingCode = 'FUT' Then max(WithholdingAmount) Else 0 End FUTAWithheld
			, Case When WithholdingCode = 'FUT' Then max(WithholdingEarnings) Else 0 End FUTAEarnings
			, Case When WithholdingCode = 'FUT' Then max(GrossEarnings) Else 0 End FUTAGrossEarnings
			, Case When WithholdingCode = 'EME' Then max(WithholdingAmount) Else 0 End EMEWithheld
			, Case When WithholdingCode = 'EME' Then max(WithholdingEarnings) Else 0 End EMEEarnings
			, Case When WithholdingCode = 'EME' Then max(GrossEarnings) Else 0 End EMEGrossEarnings
			, Case When WithholdingCode = 'EOA' Then max(WithholdingAmount) Else 0 End EOAWithheld
			, Case When WithholdingCode = 'EOA' Then max(WithholdingEarnings) Else 0 End EOAEarnings
			, Case When WithholdingCode = 'EOA' Then max(GrossEarnings) Else 0 End EOAGrossEarnings
		
			From dbo.tblPaCheckHistEmplrTax
			Where TaxAuthorityType = 0 group by PostRun, CheckId, DepartmentID, TaxAuthorityType, WithholdingCode) et
			
		----To Take only first records in case of the W department
			
	Group by PostRun, CheckId)  etSum
	on ch.PostRun = etSum.PostRun and ch.Id= etSum.CheckId
	
		Where CheckDate Between @StartDate And @EndDate and ch.Voided = 0 
		--and ch.PaYear = @PaYEAR
		Group By ch.CheckDate
		Order by ch.CheckDate
	
	--Select 
	--	'GTO' as GTO
	--	, 'ID' as [ID]
	--	, null
	--	, ch.CheckDate
	--	, Sum(ch.GrossPay) GrossPay
	--	, Sum(ch.NetPay) NetPay
	--	, null
	--	, sum(WhSum.SSEarnings) - Sum(ch.FicaTips) SSWages
	--	, Sum(WhSum.SSWithheld) SSLiability
	--	, Sum(WhSum.MedEarnings) MedWages
	--	, Sum(WhSum.MedWithheld) MedLiability
	--	, Sum(WhSum.FedEarnings) FedEarnings
	--	, Sum(WhSum.FedWithheld) FedLiability
	--	, Sum(etSum.FUTAEarnings) TaxableFUTAWages
	--	, Sum(etSum.FUTAWithheld) FUTALiability
	--	, null
	--	, null
	--	, null
	--	, null
	--	, Sum(WhSum.EICWithheld * -1) EIC
	--	, Sum(ch.FicaTips) SSTips
	--	, Sum(etSum.FUTAGrossEarnings) TotalFUTAWages
	--	, null PayPeriodStartDate
	--	, null PayPeriodEndDate
	--	, null
	--	, null
	--	, null
	--	, null [940Deposit]
	--	, null [941Deposit]
	--	, null [943Deposit]
	--	, null [945Deposit]
	--	, Sum(etSum.EOAWithheld) SSEmployerMatch
	--	, Sum(etSum.EMEWithheld) MedicareEmployerMatch
	--	, @CompNum as [PID]
	--From dbo.tblPaCheckHist ch
	--Left Join
	--(Select PostRun, CheckId, sum(SSWithheld) SSWithheld, sum(SSEarnings) SSEarnings, sum(MEDWithheld) MEDWithheld,
	--  sum(MEDEarnings) MEDEarnings, sum(FEDWithheld) FEDWithheld, sum(FEDEarnings) FEDEarnings, 
	--  sum(EICWithheld) EICWithheld, sum(EICEarnings) EICEarnings           
	--  From (Select PostRun, CheckId
	--		, Case When WithholdingCode = 'OAS' Then WithholdingAmount Else 0 End SSWithheld
	--		, Case When WithholdingCode = 'OAS' Then WithholdingEarnings Else 0 End SSEarnings
	--		, Case When WithholdingCode = 'MED' Then WithholdingAmount Else 0 End MEDWithheld
	--		, Case When WithholdingCode = 'MED' Then WithholdingEarnings Else 0 End MEDEarnings
	--		, Case When WithholdingCode = 'FWH' Then WithholdingAmount Else 0 End FEDWithheld
	--		, Case When WithholdingCode = 'FWH' Then WithholdingEarnings Else 0 End FEDEarnings
	--		, Case When WithholdingCode = 'EIC' Then WithholdingAmount Else 0 End EICWithheld
	--		, Case When WithholdingCode = 'EIC' Then WithholdingEarnings Else 0 End EICEarnings
	--		From dbo.tblPaCheckHistWithhold
	--		Where  TaxAuthorityType = 0) wh 
	--Group by PostRun, CheckId) WhSum
	--on ch.PostRun = WhSum.PostRun and ch.Id = WhSum.CheckId
	--	Left Join 
	
	--(Select PostRun, CheckId, sum(FUTAWithheld) FUTAWithheld, sum(FUTAEarnings) FUTAEarnings, 
	--sum(FUTAGrossEarnings) FUTAGrossEarnings, 
	--sum(EMEEarnings) EMEAEarnings, sum(EMEGrossEarnings) EMEGrossEarnings, sum(EMEWithheld) EMEWithheld,
	--sum(EOAEarnings) EOAEarnings, sum(EOAGrossEarnings) EOAGrossEarnings, sum(EOAWithheld) EOAWithheld        
    
	--from
	--(Select PostRun, TaxAuthorityType, WithholdingCode, CheckId
	--		, Case When WithholdingCode = 'FUT' Then max(WithholdingAmount) Else 0 End FUTAWithheld
	--		, Case When WithholdingCode = 'FUT' Then max(WithholdingEarnings) Else 0 End FUTAEarnings
	--		, Case When WithholdingCode = 'FUT' Then max(GrossEarnings) Else 0 End FUTAGrossEarnings
	--		, Case When WithholdingCode = 'EME' Then max(WithholdingAmount) Else 0 End EMEWithheld
	--		, Case When WithholdingCode = 'EME' Then max(WithholdingEarnings) Else 0 End EMEEarnings
	--		, Case When WithholdingCode = 'EME' Then max(GrossEarnings) Else 0 End EMEGrossEarnings
	--		, Case When WithholdingCode = 'EOA' Then max(WithholdingAmount) Else 0 End EOAWithheld
	--		, Case When WithholdingCode = 'EOA' Then max(WithholdingEarnings) Else 0 End EOAEarnings
	--		, Case When WithholdingCode = 'EOA' Then max(GrossEarnings) Else 0 End EOAGrossEarnings
		
	--		From dbo.tblPaCheckHistEmplrTax
	--		Where TaxAuthorityType = 0 group by PostRun, CheckId, DepartmentID, TaxAuthorityType, WithholdingCode) et
			
	--	----To Take only first records in case of the W department
			
	--Group by PostRun, CheckId)  etSum
	--on ch.PostRun = etSum.PostRun and ch.Id= etSum.CheckId
	
	--	Where CheckDate Between @StartDate And @EndDate and ch.Voided = 0
	--	Group By ch.CheckDate
	--	Order by ch.CheckDate


If  @FormType <> 'W2'
begin
	--CSI query


	Select
		'CSI' as CSI
		, 'ID' as [ID]
		, wh.TaxAuthority State
		, ch.CheckDate
		, p.PIMID
		, ISNULL(td.TaxId, '') AcctNumber
		, Sum(wh.GrossEarnings) TotalWagesTips
		, Sum(wh.WithholdingEarnings) TaxableWagesTips
		, Null Tips
		, Sum(wh.WithholdingAmount) Amount
		, isnull(Rates.Rate, 0) Rate
		, Case When wh.TaxAuthority  = 'FE' then 0 else Sum(ch.HoursWorked) end Hours
		, Null Days
		, Case When wh.TaxAuthority  = 'FE' then 0 else Sum(ch.WeeksWorked) end Weeks
		, Null PayPeriodStartDate
		, Null PayPeriodEndDate
		, @CompNum as [PID]
	From (
			Select PostRun, CheckId, case TaxAuthorityType when (0) then 'FED' 
	        when (1) then [State] else [State]+ [Local] end as TaxAuthority, WithholdingCode
				, GrossEarnings, WithholdingEarnings, WithholdingAmount
			From dbo.tblPaCheckHistWithhold 
			Where TaxauthorityType <> 0
	
			Union all
				
		--To Take a only first records in case of the W department
			Select PostRun, CheckId, case TaxAuthorityType when (0) then 'FED' 
	        when (1) then [State] else [State]+ [Local] end as TaxAuthority,
            WithholdingCode, max(GrossEarnings) GrossEarnings, max(WithholdingEarnings)WithholdingEarnings, max(WithholdingAmount) WithholdingAmount
			From dbo.tblPaCheckHistEmplrTax 
			Where TaxauthorityType <> 0  group by PostRun, CheckId, DepartmentID, case TaxAuthorityType when (0) then 'FED' 
	        when (1) then [State] else [State]+ [Local] end, WithholdingCode

			Union all
			
			Select h.PostRun, h.checkID, 'FE' as TaxAuthority, W2Box + W2Code AS Code, 
			0, 0, h.Amount 
			from dbo.tblPaCheckHistDeduct h 
			Inner Join dbo.tblPaDeductCode D on
			h.DeductionCode = d.DeductionCode WHERE d.W2Box Is Not NULL and  D.EmployerPaid = 0

			Union all
	
			Select h.PostRun, h.checkID, 'FE' as TaxAuthority, W2Box + W2Code AS Code, 
			0, 0, h.EarningsAmount 
			from dbo.tblPaCheckHistEarn h 
			Inner Join dbo.tblPaEarnCode D on
			h.EarningCode = d.Id WHERE d.W2Box Is Not NULL

		) wh
		Inner Join dbo.tblPaCheckHist ch 
			on wh.PostRun = ch.PostRun and wh.CheckId = ch.Id
		Left Join St.dbo.trav_PaAatrixPIMRef_view  p 
			on wh.TaxAuthority = p.State and wh.WithholdingCode = p.Code
		--Left Join dbo.tblPaStateTaxCodeDtl td
		--	on wh.TaxAuthority = td.State and wh.WithholdingCode = td.Code
       Left Join  dbo.tblPaTaxAuthorityDetail td 
       Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYEAR
	   on wh.TaxAuthority  = th.State and wh.WithholdingCode = td.Code and p.EmployerPaid = td.EmployerPaid and th.Type = 1  
	  and th.STATe Is Not NULL 
		Left Join (Select Replace(Substring(TableId, 2, 4), '_', '') State
				, Substring(TableId, 6, 3) Code
				, Column1 Rate
				From [ST].dbo.tblPaSTTaxTablesDtl
				Where PaYear = @PaYEAR  --Substring(DB_NAME(), 4, 4)  @PAYEAR
				and Left(TableId, 3) <> 'FED' and (Substring(TableId, 6, 3) = 'SUI' or Substring(TableId, 6, 2) = 'SO') 
				and Status = 'NA' and SequenceNumber = 1
			) Rates
			on wh.TaxAuthority = Rates.State and wh.WithholdingCode = Rates.Code
		Where CheckDate Between @StartDate And @EndDate
		AND   Len(wh.TaxAuthority) = 2 and ch.Voided = 0
		--Where CheckDate Between '20040101' and '20041231'
		Group by wh.TaxAuthority, ch.CheckDate, p.PimId, td.TaxId, Rates.Rate
		Order By wh.TaxAuthority, ch.CheckDate	


end
else
begin

--CSI query


	  Select
		'CSI' as CSI
		, 'ID' as [ID]
		, qry.TaxAuthority State
		, qry.CheckDate
		, p.PIMID
		, ISNULL(td.TaxId, '') AcctNumber
		, Sum(qry.GrossEarnings) TotalWagesTips
		, Sum(qry.WithholdingEarnings) TaxableWagesTips
		, Null Tips
		, Sum(qry.WithholdingAmount) Amount
		, isnull(Rates.Rate, 0) Rate
		, Sum(qry.Hours) Hours
		, Null Days
		, Sum(qry.Weeks) Weeks
		, Null PayPeriodStartDate
		, Null PayPeriodEndDate
		, @CompNum as [PID]
From 
	(Select SUB.CheckDate, SUB.TaxAuthority, SUB.WithholdingCode
			,SUB.GrossEarnings, SUB.WithholdingEarnings, SUB.WithholdingAmount, SUB.Hours, SUB.Weeks
	 from
		(Select WHTH.CheckDate, WHTH.TaxAuthority, WHTH.WithholdingCode
			, WHTH.GrossEarnings, WHTH.WithholdingEarnings, WHTH.WithholdingAmount, 
			WHTH.Hours, WHTH.Weeks	
		   from
		        (
			Select ch.CheckDate, wh.PostRun, wh.CheckId, wh.TaxAuthority, wh.WithholdingCode
			, wh.GrossEarnings, wh.WithholdingEarnings, wh.WithholdingAmount,
			case when wh.TaxAuthority = 'FE' then 0 else ch.HoursWorked end Hours,
			case when wh.TaxAuthority = 'FE' then 0 else ch.WeeksWorked end Weeks
			from

			(Select PostRun, CheckId, case TaxAuthorityType when (0) then 'FED' 
	        when (1) then [State] else [State]+ [Local] end as TaxAuthority, WithholdingCode
			, GrossEarnings, WithholdingEarnings, WithholdingAmount
			From dbo.tblPaCheckHistWithhold 
			Where TaxauthorityType <> 0

			Union all
			
			--To Take a only first records in case of the W department
			Select PostRun,  CheckId, case TaxAuthorityType when (0) then 'FED' 
	        when (1) then [State] else [State]+ [Local] end as TaxAuthority, WithholdingCode 
				, max(GrossEarnings) GrossEarnings, max(WithholdingEarnings)WithholdingEarnings, max(WithholdingAmount) WithholdingAmount
			From dbo.tblPaCheckHistEmplrTax 
			Where TaxauthorityType <> 0
			  group by PostRun, CheckId, DepartmentID, case TaxAuthorityType when (0) then 'FED' 
	        when (1) then [State] else [State]+ [Local] end, WithholdingCode

			Union all
	
			Select h.PostRun, h.CheckId, 'FE' as TaxAuthority, 
			--case W2Box when '10' then W2Box + ISNULL(W2Code, 'B') when  '14' then W2Box + 'B' else W2Box + W2Code end AS Code, 
			case W2Box when '10' then W2Box + ISNULL(W2Code, 'B') when  '14' then W2Box + Left(W2Code, 1) else W2Box + W2Code end AS Code, 
			0, 0, h.Amount 
			from dbo.tblPaCheckHistDeduct h 
			Inner Join dbo.tblPaDeductCode D on
			h.DeductionCode = d.DeductionCode WHERE d.W2Box Is Not NULL and D.EmployerPaid = 0

			Union all


			Select h.PostRun, h.CheckId, 'FE' as TaxAuthority, 
			--case W2Box when '10' then W2Box + ISNULL(W2Code, 'B') when  '14' then W2Box + 'B' else W2Box + W2Code end AS Code, 
			case W2Box when '10' then W2Box + ISNULL(W2Code, 'B') when  '14' then W2Box + Left(W2Code, 1) else W2Box + W2Code end AS Code, 
			0, 0, h.Amount 
			from dbo.tblPaCheckHistEmplrCost h 
			Inner Join dbo.tblPaDeductCode D on
			h.DeductionCode = d.DeductionCode   WHERE  d.W2Box Is Not NULL and D.EmployerPaid = 1



			Union all
	
			
			Select h.PostRun, h.Id, 'FE' as TaxAuthority, 
			Case W2Box when '10' then W2Box + ISNULL(W2Code, 'B')  when '11' then W2Box + ISNULL(W2Code, 'N') 
			--When '14' then W2Box + 'B' else W2Box + W2Code end AS Code,
			When '14' then W2Box + Left(W2Code, 1) else W2Box + W2Code end AS Code,
			0, 0, h.EarningsAmount 
			from dbo.tblPaCheckHistEarn h 
			Inner Join dbo.tblPaEarnCode D on
			h.EarningCode = D.Id WHERE D.W2Box Is Not NULL


				) wh
			Inner Join dbo.tblPaCheckHist ch 
			--inner Join #EmpRef r on ch.EmployeeId = r.EmployeeId
			on wh.PostRun = ch.PostRun and wh.CheckId = ch.Id WHERE  ch.Voided = 0
		) 	WHTH

			Union all

		     Select Cast(Cast(@PaYEAR as nvarchar(4)) + '1231' as datetime) as [Date], Msc.TaxAuthority, Msc.code, 0 as WithholdingCode, 
			0 as GrossEarningsMsc, Msc.Amount, 0 as Hours,0 as Weeks
		     from
			(SElect m.TaxAuthority, m.code, m.Amount
			from
			(SELECT m.EmployeeID, 'FE' as TaxAuthority, 
			CASE c.Descr WHEN 'Uncollected OASDI' then m.Amount WHEN 'Uncollected MEDICARE' then  m.Amount 
			WHEN 'Allocated Tips' then m.Amount else 0 end as Amount,
			CASE c.Descr WHEN 'Uncollected OASDI' then '12A' WHEN 'Uncollected MEDICARE' then  '12B' 
			WHEN 'Allocated Tips' then  '8BX' 
			else '' end as code
			FROM dbo.tblPaEmpHistMisc m INNER JOIn dbo.tblPaMiscCode c on  m.MiscCodeId = c.Id) M
			Inner Join #EmpRef r on m.EmployeeId = r.EmployeeId
			WHERE m.code <> '' and m.Amount <> 0
			) Msc 

		) SUB 
           )qry
		Left Join St.dbo.trav_PaAatrixPIMRef_view  p 
			on qry.TaxAuthority = p.State and qry.WithholdingCode = p.Code
		--Left Join dbo.tblPaStateTaxCodeDtl td
       Left Join  dbo.tblPaTaxAuthorityDetail td on qry.TaxAuthority = p.State and qry.WithholdingCode =p.Code
       Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYEAR
	   and qry.TaxAuthority = th.State and qry.WithholdingCode = td.Code and p.EmployerPaid = td.EmployerPaid and th.Type = 1  
	   and th.STATe Is Not NULL
		Left Join (Select Replace(Substring(TableId, 2, 4), '_', '') State
				, Substring(TableId, 6, 3) Code
				, Column1 Rate
				From [ST].dbo.tblPaSTTaxTablesDtl
				Where PaYear = @PaYEAR --Substring(DB_NAME(), 4, 4) @PaYEAR
				and Left(TableId, 3) <> 'FED' and (Substring(TableId, 6, 3) = 'SUI' or Substring(TableId, 6, 2) = 'SO') 
				and Status = 'NA' and SequenceNumber = 1
			) Rates
			on qry.TaxAuthority = Rates.State and qry.WithholdingCode = Rates.Code
		--Where CheckDate Between @StartDate And @EndDate 
		WHERE CheckDate Between @StartDate AND Cast(Cast(@PaYEAR as nvarchar(4)) + '1231' as datetime)
		AND   Len(qry.TaxAuthority) = 2	
		Group by qry.TaxAuthority, qry.CheckDate, p.PimId, td.TaxId, Rates.Rate
		Order By qry.TaxAuthority, qry.CheckDate


end

	--CSP?????
	--CLI???
	
	--CBI???
	
	---EMP
	--Employee Query EMP
	
	
If  @FormType <> 'W2'
begin
	--CLI query


	Select
		'CLI' as CSI
		, 'ID' as [ID]
		, Left(wh.TaxAuthority,2) State
		, ch.CheckDate
		, p.PIMID
		,  NULL AcctNumber
		, 0 TotalWagesTips
		, Sum(wh.WithholdingEarnings) TaxableWagesTips
		, Null Tips
		, Sum(wh.WithholdingAmount) Amount
		, isnull(Rates.Rate, 0) Rate
		, 0 Hours
		, Null Days
		, 0  Weeks
		, Null PayPeriodStartDate
		, Null PayPeriodEndDate
		, @CompNum as [PID]
	From (
			Select PostRun, CheckId, 
			 case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end as TaxAuthority,
            WithholdingCode, GrossEarnings, WithholdingEarnings, WithholdingAmount
			From dbo.tblPaCheckHistWithhold 
			Where TaxauthorityType <> 0

			Union all
			
			Select PostRun, CheckId,  case TaxAuthorityType when (0) then 'FED'  when (1) then [State] else [State]+ [Local] end as TaxAuthority,
			WithholdingCode, max(GrossEarnings) GrossEarnings, max(WithholdingEarnings)WithholdingEarnings, max(WithholdingAmount) WithholdingAmount
			From dbo.tblPaCheckHistEmplrTax 
			Where TaxauthorityType <> 0 group by PostRun, CheckId, DepartmentID, case TaxAuthorityType when (0) then 'FED'  when (1) then [State] else [State]+ [Local] end, WithholdingCode


			Union all
			
			Select h.PostRun, h.Id, 'FE' as TaxAuthority, W2Box + W2Code AS Code, 
			0, 0, h.Amount 
			from dbo.tblPaCheckHistDeduct h 
			Inner Join dbo.tblPaDeductCode D on
			h.DeductionCode = d.DeductionCode WHERE d.W2Box Is Not NULL and D.EmployerPaid =0 
		) wh
		Inner Join dbo.tblPaCheckHist ch 
			on wh.PostRun = ch.PostRun and wh.CheckId = ch.Id
		Left Join St.dbo.trav_PaAatrixPIMRef_view  p 
			on Left(wh.TaxAuthority, 2) = p.State and wh.WithholdingCode = p.Code
  Left Join  dbo.tblPaTaxAuthorityDetail td 
       Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYEAR
	and th.Type = 2 
	on lEFT(wh.TaxAuthority, 2) = th.State and wh.WithholdingCode = td.Code

		Left Join (Select Replace(Substring(TableId, 2, 4), '_', '') State
				, Substring(TableId, 6, 3) Code
				, Column1 Rate
				From [ST].dbo.tblPaSTTaxTablesDtl
				Where PaYear = @PaYEAR  --Substring(DB_NAME(), 4, 4)  @PAYEAR
				and Left(TableId, 3) <> 'FED' and (Substring(TableId, 6, 3) = 'SUI' or Substring(TableId, 6, 2) = 'SO') 
				and Status = 'NA' and SequenceNumber = 1
			) Rates
			on Left(wh.TaxAuthority, 2) = Rates.State and wh.WithholdingCode = Rates.Code
		AND ch.Voided = 0 and
(((Len(wh.TaxAuthority) = 4 and right(wh.TaxAuthority, 2) = p.LocalCode) and right(th.Local, 2) = p.LocalCode)  or (Left(wh.TaxAuthority, 2) = 'NJ')

AND p.TaxType = 2020)
		--Where CheckDate Between '20040101' and '20041231'
		WHERE CheckDate Between @StartDate and @EndDate
		Group by wh.TaxAuthority, ch.CheckDate, p.PimId, td.TaxId, Rates.Rate
		Order By wh.TaxAuthority, ch.CheckDate	


end
else
begin

--CSI query




	  Select
		'CLI' as CSI
		, 'ID' as [ID]
		, Left(qry.TaxAuthority,2) State
		, qry.CheckDate
		, p.PIMID
		, NULL AcctNumber
		, 0 TotalWagesTips
		, Sum(qry.WithholdingEarnings) TaxableWagesTips
		, 0 Tips
		, Sum(qry.WithholdingAmount) Amount
		, isnull(Rates.Rate, 0) Rate
		, 0 Hours
		, 0 Days
		, 0 Weeks
		, Null PayPeriodStartDate
		, Null PayPeriodEndDate
		, @CompNum as [PID]
From 
	(Select SUB.CheckDate, SUB.TaxAuthority, SUB.WithholdingCode
			,SUB.GrossEarnings, SUB.WithholdingEarnings, SUB.WithholdingAmount, SUB.Hours, SUB.Weeks
	 from
		(Select WHTH.CheckDate, WHTH.TaxAuthority, WHTH.WithholdingCode
			, WHTH.GrossEarnings, WHTH.WithholdingEarnings, WHTH.WithholdingAmount, 
			WHTH.Hours, WHTH.Weeks	
		   from
		        (
			Select ch.CheckDate, wh.PostRun, wh.CheckId, wh.TaxAuthority, wh.WithholdingCode
			, wh.GrossEarnings, wh.WithholdingEarnings, wh.WithholdingAmount,
			case when wh.TaxAuthority = 'FE' then 0 else ch.HoursWorked end Hours,
			case when wh.TaxAuthority = 'FE' then 0 else ch.WeeksWorked end Weeks
			from

			(
			Select PostRun, CheckId, 
			 case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end as TaxAuthority, WithholdingCode
			, GrossEarnings, WithholdingEarnings, WithholdingAmount
			From dbo.tblPaCheckHistWithhold 
			Where TaxauthorityType <> 0

			Union all
		
		--To Take a only first records in case of the W department
			Select PostRun, CheckId, 
			 case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end as TaxAuthority, WithholdingCode 
				, max(GrossEarnings) GrossEarnings, max(WithholdingEarnings)WithholdingEarnings, max(WithholdingAmount) WithholdingAmount
			From dbo.tblPaCheckHistEmplrTax 
			Where TaxauthorityType <> 0  group by PostRun, CheckId, DepartmentID, case TaxAuthorityType when (0) then 'FED'  when (1) then [State] else [State]+ [Local] end, WithholdingCode

			Union all
			
			Select h.PostRun, h.Id, 'FE' as TaxAuthority, 
			case W2Box when '10' then W2Box + ISNULL(W2Code, 'B') When '14' then W2Box + Left(W2Code, 1) else W2Box + W2Code end AS Code, 
			0, 0, h.Amount 
			from dbo.tblPaCheckHistDeduct h 
			Inner Join dbo.tblPaDeductCode D on
			h.DeductionCode = D.DeductionCode WHERE d.W2Box Is Not NULL and  D.EmployerPaid = 0

			Union all

			Select h.PostRun, h.Id, 'FE' as TaxAuthority, 
			Case W2Box when '10' then W2Box + ISNULL(W2Code, 'B')  when '11' then W2Box + ISNULL(W2Code, 'N') 
			When '14' then 	W2Box + Left(W2Code, 1) else W2Box + W2Code end AS Code,
			0, 0, h.EarningsAmount 
			from dbo.tblPaCheckHistEarn h 
			Inner Join dbo.tblPaEarnCode D on
			h.EarningCode = D.Id WHERE D.W2Box Is Not NULL

				) wh
			Inner Join dbo.tblPaCheckHist ch 
			on wh.PostRun = ch.PostRun and wh.CheckId = ch.Id and ch.Voided = 0
		) 	WHTH

			Union all

		 Select Cast(Cast(@PaYEAR as nvarchar(4)) + '1231' as datetime) as [Date], Msc.TaxAuthority, Msc.code, 0 as WithholdingCode, 
			0 as GrossEarningsMsc, Msc.Amount, 0 as Hours,0 as Weeks
		     from
			(SElect m.TaxAuthority, m.code, m.Amount
			from
			(SELECT m.EmployeeID, 'FE' as TaxAuthority, 
			CASE c.Descr WHEN 'Uncollected OASDI' then m.Amount WHEN 'Uncollected MEDICARE' then  m.Amount 
			WHEN 'Allocated Tips' then m.Amount else 0 end as Amount,
			CASE c.Descr WHEN 'Uncollected OASDI' then '12A' WHEN 'Uncollected MEDICARE' then  '12B' 
			WHEN 'Allocated Tips' then  '8BX' 
			else '' end as code
			FROM dbo.tblPaEmpHistMisc m INNER JOIn dbo.tblPaMiscCode c on  m.MiscCodeId = c.Id) M
			Inner Join #EmpRef r on m.EmployeeId = r.EmployeeId
			WHERE m.code <> '' and m.Amount <> 0
			) Msc 
		) SUB 
           )qry
		
	Left Join St.dbo.trav_PaAatrixPIMRef_view  p 
			on Left(qry.TaxAuthority, 2) = p.State and qry.WithholdingCode = p.Code
  Left Join  dbo.tblPaTaxAuthorityDetail td 
       Inner Join dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYEAR
	and th.Type = 2 
	on lEFT(qry.TaxAuthority, 2) = th.State and qry.WithholdingCode = td.Code

		Left Join (Select Replace(Substring(TableId, 2, 4), '_', '') State
				, Substring(TableId, 6, 3) Code
				, Column1 Rate
				From [ST].dbo.tblPaSTTaxTablesDtl
				Where PaYear = @PaYEAR --Substring(DB_NAME(), 4, 4) @PAYEAR
				and Left(TableId, 3) <> 'FED' and (Substring(TableId, 6, 3) = 'SUI' or Substring(TableId, 6, 2) = 'SO') 
				and Status = 'NA' and SequenceNumber = 1
			) Rates
			on Left(qry.TaxAuthority,2) = Rates.State and qry.WithholdingCode = Rates.Code
		WHERE CheckDate Between @StartDate AND Cast(Cast(@PaYEAR as nvarchar(4)) + '1231' as datetime)
		AND   
	((((Len(qry.TaxAuthority) = 4 and p.EmployerPaid  = 0) and right(qry.TaxAuthority, 2) = p.LocalCode) and right(th.Local, 2) = p.LocalCode)  or (Left(qry.TaxAuthority, 2) = 'NJ')
		AND p.TaxType = 2020)
		Group by qry.TaxAuthority, qry.CheckDate, p.PimId, td.TaxId, Rates.Rate
		Order By qry.TaxAuthority, qry.CheckDate

end
--
--declare @CompNum smallint
--set @CompNum  = 2
--declare @PaYEAR smallint
--set @PaYEAR = 2010
--declare @CountryCode nvarchar(20)
--set @CountryCode = 'USA'
--declare @CountryName nvarchar(20)
--Select @CountryName = 'USA'
	Select 
		'EMP' as EMP
		, r.EmpNum as [ID]
		, m.FirstName
		, m.MiddleInit
		, m.LastName
		, null NameSuffix
		, s.SSN SocialSecurityNo
        
		, m.AddressLine1
		, m.ResidentCity City
		, Null County
		, Null CountyCode
		, m.ResidentState State
        , Case when Len(m.ZipCode)> 5 then Substring(m.ZipCode, 1, 5) + '-' + Substring(m.ZipCode, 6, Len(m.ZipCode)) else m.ZipCode end ZipCode
		, @Country as Country
		, null CountryCode --e.CountryCode
        , null ForeignPostalCode
		, null
		, null
		, null
		, null
		, null
		, null
		, null
		, Case When e.Sex = 'F' Then 'X' Else ' ' End Female
		, null Disabled
		, AdjustedHireDate HireDate
		, TerminationDate FireDate
		, Null MedicalCoverageDate
		, m.BirthDate
		, Case When e.EmployeeType = 0 Then e.HourlyRate Else e.Salary End PayRate
		, sw.Exemptions
		, e.EmployeeType PayType
		, Case When e.EmployeeStatus = 0 Then 'X' Else ' ' End Fulltime
		, e.JobTitle Title
		, sw.SUIState
		, lc.[Description] WorkType
		, null
		, Null HealthBenefits
		, m.PhoneNumber
		, Case When SeasonalEmployee = 0 Then ' ' Else 'X' End Seasonal
		, Null WorkersCompClass
		, Null WorkersCompSubClass
		, sw.SUIState
		, sw.MaritalStatus
		, e.EmployeeId
		, Case When e.StatutoryEmployee = 1 Then 'X' Else ' ' End StatutoryEmployee
		, Case When e.ParticipatingIn401k = 1 Then 'X' Else ' ' End RetirementPlan
		, Null ThirdPartySickPay
		, Case When isnull(e.PayDistribution, 0) <> 0 Then 'X' Else ' ' End DirectDeposit
		, m.AddressLine2
		, null Changed
		, m.WorkEmail EmailAddress
		, ' ' ElectronicW2
        , NULL NonUSStateProvince
-- 1.93 version changes
        , NULL RehireDate
             --  'R','M''A''H''F''X'
        , 'R' EmploymentCode
        --Enter the complete occupational title or six-digit code for the position held by the employee. For AK employees only.
        , Case when m.ResidentState = 'AK' then e.LaborClass else  NULL end as FullOccupTitle
      -- Enter the two-digit geographic code of the last location the employee worked. For AK employees only.	
     	,  NULL  as GeographicCode
     	,  NULL  PensionDate
        ,  NULL as NationalIDNumber
          --Enter the internal ID for the employee. Internal use only. 2.3 version changes
        ,  NULL as InternalID
        ,  NULL CanadaPensionPlan
        ,  NULL EmploymentInsuranceExempt
        ,  NULL ProvParentalInsPlanExempt
        ,  sw.Exemptions as StateExemptions
		, Case e.EeoClass When 1 then 'A' when 2 then 'B' when 3 then 'H' when 5 then 'N' when 6 then 'P' when 7 then '0' else 'C' end as Ethnicity
		, @CompNum as [PID]	

	From dbo.tblPaEmployee e Inner Join dbo.tblSmEmployee m on m.EmployeeId = e.EmployeeId
		inner Join
		 #EmpRef r on e.EmployeeId = r.EmployeeId
        Left Join dbo.tblPaEmpWithhold sw on e.EmployeeId = sw.EmployeeId 	
		Left Join dbo.tblPaLaborClass lc on e.LaborClass = lc.Id 
		Left Join (Select Value1 EmployeeID, Value2 SSN From dbo.tblSysEncDec Where UserId = @UserId and WrkStnID = @WrkStnId 
		and RefID = 'AATRIX') s on e.EmployeeID = s.EmployeeId 
		Where sw.DefaultWH = 1 and sw.PaYear = @PaYEAR	and sw.SUIState Is Not NULL	
		And e.EmployeeId in (Select EmployeeId From dbo.tblPaCheckHist 
				Where CheckDate Between @StartDate And @EndDate and Voided = 0
				Group By EmployeeId)
		Order By e.EmployeeId
		
	
	

--GEN
	--Checks Query 
--Declare @StartDate datetime
--Declare @EndDate datetime
--Declare  @MedAmtLimit int
--SELECT @StartDate = Cast([Value] AS datetime) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'StartDate'
--SELECT @EndDate = Cast([Value] AS datetime) FROM dbo.tblPaAatrixInfo WHERE [ID] = 'EndDate'

--set @MedAmtLimit = 0
--SElect  @MedAmtLimit= Column1 From [ST].dbo.tblPaSTTaxTablesDtl Where PaYear = 2013 and Left(TableId, 3) = 'FED' and right(TableId, 3) = 'MED' and status = 'NA' and  SequenceNumber = 2 


	Select 
		'GEN' as GEN
		,'ID' as [ID]
		,CheckHist.CheckDate
		,CheckHist.GrossPay
		,null
		,CheckHist.NetPay
		,CheckHist.SSWages
		,CheckHist.SSWithheld
		,CheckHist.MedWages
		,CheckHist.MedWithheld
		,CheckHist.FedWages
		,CheckHist.FedWithheld 
		,CheckHist.TaxableFUTAWages
		,null
		,null
		,null
		,CheckHist.EIC
		,CheckHist.SSTips
		,CheckHist.FUTALiability
		,CheckHist.TotalFUTAWages
		,@StartDate PayPeriodStartDate
		,@EndDate PayPeriodEndDate
		, CheckHist.EOAWithheld as SSEmployerMatch
		, CheckHist.EMEWithheld as MedicareEmplrMatch
		--2.23 --Enter the additional Medicare tax on wages in excess of $200,000. See also Medicare Withheld (field 8)
		--, Coalesce(CheckHist.AdditionalMedicareTax,0) AdditionalMedicareTax
		, Coalesce(0,0) AdditionalMedicareTax
		--2.23--Enter the wages subject to the additional Medicare tax. See also Medicare Wages (field 7).
		, Coalesce(CheckHist.AdditionalMedicareWages, 0) AdditionalMedicareWages
		--, Coalesce(0, 0) AdditionalMedicareWages
		,r.EmpNum PID
From
(


Select  ch.EmployeeId, ch.CheckDate, ch.GrossPay, ch.NetPay, ch.Voided,
	whSum.SSEarnings - ch.FicaTips  SSWages, 
	whSum.SSWithheld, 
	whSum.MedEarnings MedWages,
	whSum.MedWithheld,
	whSum.FedEarnings FedWages,
    whSum.FedWithheld, 
	etSum.FUTAEarnings TaxableFUTAWages, (WhSum.EICWithheld * -1) EIC, ch.FicaTips SSTips, 
	etSum.FUTAWithheld FUTALiability, etSum.FUTAGrossEarnings TotalFUTAWages,
    etSum.EMEWithheld,
	etSum.EOAWithheld,
	adwh.AdditionalMedicareTax, 
	adwh.AdditionalMedicareWages
	From dbo.tblPaCheckHist ch  
	 Left JOIN 
	(
	

   Select addmed.EmployeeId, addmed.EmpNum, Max(addmed.PostRun) PostRun, Max(addmed.CheckID) CheckID
	, SUM(addmed.MEDCurrWithheld) as AdditionalMedicareTax
	, SUM(CASE WHEN addmed.MEDPRIEREarnings + addmed.MEDCurrEarnings <= @MedAmtLimit THEN 0 ELSE
		  CASE WHEN addmed.MEDPRIEREarnings >= @MedAmtLimit THEN MEDCurrEarnings
		  ELSE addmed.MEDCurrEarnings - (@MedAmtLimit - addmed.MEDPRIEREarnings) END END) AS AdditionalMedicareWages
	from
	(
	Select c.EmployeeId, r.EmpNum
			, Max(Case When w.WithholdingCode = 'MED' and c.CheckDate Between  @StartDate And  @EndDate Then w.PostRun Else '' End) PostRun
			, Max(Case When w.WithholdingCode = 'MED' and c.CheckDate Between  @StartDate And  @EndDate Then w.CheckID Else '' End) CheckID
			, sum(Case When w.WithholdingCode = 'MED' and c.CheckDate Between  Cast(Cast(@PaYEAR as nvarchar(4)) + '0101' as datetime) And  @StartDate and @PaYEAR >=2013 Then w.WithholdingAmount Else 0 End) MEDPRIERWithheld
			, sum(Case When w.WithholdingCode = 'MED' and c.CheckDate Between  Cast(Cast(@PaYEAR as nvarchar(4)) + '0101' as datetime) And  @StartDate and @PaYEAR >=2013 Then w.WithholdingEarnings Else 0 End) MEDPRIEREarnings
			, sum(Case When w.WithholdingCode = 'MED' and c.CheckDate Between  @StartDate And  @EndDate Then w.WithholdingAmount Else 0 End) MEDCurrWithheld
			, sum(Case When w.WithholdingCode = 'MED' and c.CheckDate Between  @StartDate And  @EndDate Then w.WithholdingEarnings Else 0 End) MEDCurrEarnings
			From dbo.tblPaCheckHistWithhold w inner Join  dbo.tblPaCheckHist c on  w.PostRun = c.PostRun and c.Id= w.CheckId
			INNer Join #EmpRef r on c.EmployeeId = r.EmployeeId
		Where c.Voided = 0 and w.TaxAuthorityType = 0 
	   Group by  c.EmployeeId, r.EmpNum
	   ) addmed Group by  addmed.EmployeeId, addmed.EmpNum) adwh on ch.EmployeeId = adwh.EmployeeId
	   and adwh.PostRun = ch.PostRun and adwh.CheckID = ch.Id
	Left Join
	(Select PostRun, CheckId, sum(SSWithheld) SSWithheld, sum(SSEarnings) SSEarnings, sum(MEDWithheld) MEDWithheld, sum(MEDEarnings) MEDEarnings,  
		sum(FEDWithheld) FEDWithheld, sum(FEDEarnings) FEDEarnings, sum(EICWithheld) EICWithheld,  sum(EICEarnings) EICEarnings
	from
	(Select PostRun, CheckId
			, Case When WithholdingCode = 'OAS' Then WithholdingAmount Else 0 End SSWithheld
			, Case When WithholdingCode = 'OAS' Then WithholdingEarnings Else 0 End SSEarnings
			, Case When WithholdingCode = 'MED' Then WithholdingAmount Else 0 End MEDWithheld
			, Case When WithholdingCode = 'MED' Then WithholdingEarnings Else 0 End MEDEarnings
			, Case When WithholdingCode = 'FWH' Then WithholdingAmount Else 0 End FEDWithheld
			, Case When WithholdingCode = 'FWH' Then WithholdingEarnings Else 0 End FEDEarnings
			, Case When WithholdingCode = 'EIC' Then WithholdingAmount Else 0 End EICWithheld
			, Case When WithholdingCode = 'EIC' Then WithholdingEarnings Else 0 End EICEarnings
			From dbo.tblPaCheckHistWithhold
			Where TaxAuthorityType = 0) wh 	
	Group by PostRun, CheckId) WhSum
	on ch.PostRun = WhSum.PostRun and ch.Id= WhSum.CheckId
	Left Join 
	(Select PostRun , CheckId, sum(FUTAWithheld) FUTAWithheld, sum(FUTAEarnings) FUTAEarnings, sum(FUTAGrossEarnings) FUTAGrossEarnings,
	    sum(EMEWithheld) EMEWithheld, sum(EOAWithheld) EOAWithheld    
	from
	--To Take a only first records in case of the W department
	(Select PostRun,CheckId
			, Case When WithholdingCode = 'FUT' Then max(WithholdingAmount) Else 0 End FUTAWithheld
			, Case When WithholdingCode = 'FUT' Then max(WithholdingEarnings) Else 0 End FUTAEarnings
			, Case When WithholdingCode = 'FUT' Then max(GrossEarnings) Else 0 End FUTAGrossEarnings
			, Case When WithholdingCode = 'EME' Then max(WithholdingAmount) Else 0 End EMEWithheld	
			, Case When WithholdingCode = 'EOA' Then max(WithholdingAmount) Else 0 End EOAWithheld	
			From dbo.tblPaCheckHistEmplrTax
			Where TaxAuthorityType = 0 group by PostRun, CheckId, DepartmentID, TaxAuthoritytype, WithholdingCode                                                       
			) et
	Group by PostRun, CheckId) etSum
	on ch.PostRun = etSum.PostRun and ch.Id = etSum.CheckId
	
) CheckHist
		inner Join #EmpRef r on CheckHist.EmployeeId = r.EmployeeId
		Where CheckHist.CheckDate Between @StartDate And @EndDate and CheckHist.Voided = 0 
		Order by CheckHist.EmployeeId, CheckHist.CheckDate


	--ESI query
If  @FormType <> 'W2'
begin

		Select
		'ESI' as ESI
		, 'ID' as [ID]
		, wh.TaxAuthority State
		, ch.CheckDate
		, p.PIMID
		, wh.GrossEarnings TotalWagesTips
		, wh.WithholdingEarnings TaxableWagesTips
		, Null Tips
		---Enter the amount. For most tax types, this will be the amount withheld. 
--For the W2 tax types, this will be the amount that applies to the W2 box, 
--which may be wages or tips in some cases.
		, wh.WithholdingAmount Amount
		, case when wh.TaxAuthority = 'FE' then 0 else COALESCE(wh.HoursWorked, ch.HoursWorked) end Hours
		, Null Days
		, case when wh.TaxAuthority = 'FE' then 0 else ch.WeeksWorked end Weeks
		,@StartDate PayPeriodStartDate
		,@EndDate PayPeriodEndDate
		, 0.00 AS Commissions
		, 0.00  AS Allowances
			--Enter the account identification number. Use this only if it varies by employee. Otherwise, use PIM-7. version 2.12.
		, NULL AccountNumber
		, r.EmpNum PID
	From (
	--Select w.PostRun, w.CheckId,  
	--		case w.TaxAuthorityType when (0) then 'FED' when (1) then w.[State] else w.[State]+ w.[Local] end as TaxAuthority 
	--		, w.WithholdingCode, w.GrossEarnings, w.WithholdingEarnings,w. WithholdingAmount, 0 HoursWorked
	--		From dbo.tblPaCheckHistWithhold w 
	--		Where w.TaxauthorityType <> 0 
	Select w.PostRun, w.CheckId,  
			case w.TaxAuthorityType when (0) then 'FED' when (1) then w.[State] else w.[State]+ w.[Local] end as TaxAuthority 
			, w.WithholdingCode, w.GrossEarnings, w.WithholdingEarnings,w. WithholdingAmount
			,h.HoursWorked
			From dbo.tblPaCheckHistWithhold w 
			Inner Join dbo.tblPaCheckHist h  on w.PostRun = h.PostRun and w.CheckId = h.Id 
			Where w.TaxauthorityType <> 0 
			
			Union all	
		--To Take a only first records in case of the W department
			--Select PostRun, CheckId, DepartmentId, case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end as TaxAuthority, 
			--WithholdingCode, max(GrossEarnings) GrossEarnings, max(WithholdingEarnings)WithholdingEarnings, max(WithholdingAmount) WithholdingAmount
			--From dbo.tblPaCheckHistEmplrTax 
			--Where TaxauthorityType <> 0  group by PostRun, CheckId, DepartmentId,case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end, WithholdingCode

			Select r.PostRun, r.CheckId,  case r.TaxAuthorityType when (0) then 'FED' when (1) then r.[State] else r.[State]+ r.[Local] end as TaxAuthority, 
			r.WithholdingCode, max(r.GrossEarnings) GrossEarnings, max(WithholdingEarnings)WithholdingEarnings, max(WithholdingAmount) WithholdingAmount, sum(h.HoursWorked) HoursWorked
			From dbo.tblPaCheckHistEmplrTax r Left Join dbo.tblPaCheckHistEarn h  on r.PostRun = h.PostRun and r.CheckId = h.CheckId and r.DepartmentId = h.DepartmentId
			Where TaxauthorityType <> 0  group by r.PostRun, r.CheckId, r.DepartmentId, h.DepartmentId, case r.TaxAuthorityType when (0) then 'FED' when (1) then r.[State] else r.[State]+ r.[Local] end, r.WithholdingCode

			Union all
	
			Select h.PostRun, h.CheckId, 'FE' as TaxAuthority, W2Box + W2Code AS Code, 
			0, 0, h.Amount,0
			from dbo.tblPaCheckHistDeduct h 
			Inner Join dbo.tblPaDeductCode D on
			h.DeductionCode = d.DeductionCode WHERE d.W2Box Is Not NULL and D.EmployerPaid= 0
		
			Union all

			Select h.PostRun, h.CheckId, 'FE' as TaxAuthority, W2Box + W2Code AS Code, 
			0, 0, h.EarningsAmount,0
			from dbo.tblPaCheckHistEarn h 
			Inner Join dbo.tblPaEarnCode D on
			h.EarningCode = D.Id WHERE D.W2Box Is Not NULL

		) wh
		Inner Join dbo.tblPaCheckHist ch inner Join #EmpRef r on ch.EmployeeId = r.EmployeeId
			on wh.PostRun = ch.PostRun and wh.CheckId = ch.Id
		Left Join St.dbo.tblPaAatrixPIMRef p on 
			wh.TaxAuthority = p.State and wh.WithholdingCode = p.Code
	    Where CheckDate Between @StartDate And @EndDate 
		ANd Len(wh.TaxAuthority) = 2  and  p.TaxType <> 2054 and ch.Voided = 0
		
		Order By TaxAuthority, CheckDate


end
else
Begin



	Select
		'ESI' as ESI
		, 'ID' as [ID] 
		, qry.TaxAuthority State
		, qry.CheckDate
		, p.PIMID
		, qry.GrossEarnings TotalWagesTips
		, qry.WithholdingEarnings TaxableWagesTips
		, Null Tips
---Enter the amount. For most tax types, this will be the amount withheld. 
--For the W2 tax types, this will be the amount that applies to the W2 box, 
--which may be wages or tips in some cases.
		, qry.WithholdingAmount Amount
		, qry.Hours
		, Null Days
		, qry.Weeks
		,@StartDate PayPeriodStartDate
		,@EndDate PayPeriodEndDate
		, 0.00 AS Commissions
		, 0.00  AS Allowances
			--Enter the account identification number. Use this only if it varies by employee. Otherwise, use PIM-7. version 2.12.
		, NULL AccountNumber
		, r.EmpNum PID	
   From 
	(Select SUB.EmployeeId, SUB.CheckDate, SUB.TaxAuthority, SUB.WithholdingCode
			,SUB.GrossEarnings, SUB.WithholdingEarnings, SUB.WithholdingAmount, SUB.Hours, SUB.Weeks
	 from
		(Select WHTH.EmployeeId, WHTH.CheckDate, WHTH.TaxAuthority, WHTH.WithholdingCode
			, WHTH.GrossEarnings, WHTH.WithholdingEarnings, WHTH.WithholdingAmount, 
			WHTH.Hours, WHTH.Weeks
		from
		        (
			Select ch.EmployeeId, ch.CheckDate, wh.PostRun, wh.CheckId, wh.TaxAuthority, wh.WithholdingCode
			, wh.GrossEarnings, wh.WithholdingEarnings, wh.WithholdingAmount,
			case when wh.TaxAuthority = 'FE' then 0 else ch.HoursWorked end Hours,
			case when wh.TaxAuthority = 'FE' then 0 else ch.WeeksWorked end Weeks
			from

			(Select PostRun, CheckId, case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end as TaxAuthority, 
			WithholdingCode, GrossEarnings, WithholdingEarnings, WithholdingAmount
			From dbo.tblPaCheckHistWithhold 
			Where TaxauthorityType <> 0
			Union all
	
			--To Take a only first records in case of the W department
			Select PostRun, CheckId, case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end as TaxAuthority, 
			WithholdingCode , max(GrossEarnings) GrossEarnings, max(WithholdingEarnings)WithholdingEarnings, max(WithholdingAmount) WithholdingAmount
			From dbo.tblPaCheckHistEmplrTax 
			Where TaxauthorityType <> 0  group by PostRun, CheckId,  case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end, WithholdingCode

			Union all
	
			Select h.PostRun, h.CheckId, 'FE' as TaxAuthority, 
			case W2Box when '10' then W2Box + ISNULL(W2Code, 'B') 
			When '14' then W2Box + Left(W2Code, 1) else W2Box + W2Code end AS Code,  
			0, 0, h.Amount 
			from dbo.tblPaCheckHistDeduct h 
			Inner Join dbo.tblPaDeductCode D on
			h.DeductionCode = d.DeductionCode WHERE d.W2Box Is Not NULL and D.EmployerPaid = 0
			Union all

			Select h.PostRun, h.CheckId, 'FE' as TaxAuthority, 
			case W2Box when '10' then W2Box + ISNULL(W2Code, 'B')  
			When '14' then W2Box + Left(W2Code, 1) else W2Box + W2Code end AS Code, 
			0, 0, h.Amount 
			from dbo.tblPaCheckHistEmplrCost h 
			Inner Join dbo.tblPaDeductCode D on
			h.DeductionCode = d.DeductionCode WHERE d.W2Box Is Not NULL and D.EmployerPaid = 1

			Union all

			Select h.PostRun, h.CheckId, 'FE' as TaxAuthority, 
			Case W2Box when '10' then W2Box + ISNULL(W2Code, 'B')  when '11' then W2Box + ISNULL(W2Code, 'N') 
			--When '14' then W2Box + 'B' else W2Box + W2Code end AS Code,
			When '14' then W2Box + Left(W2Code, 1) else W2Box + W2Code end AS Code,
			0, 0, h.EarningsAmount 
			from dbo.tblPaCheckHistEarn h 
			Inner Join dbo.tblPaEarnCode D on
			h.EarningCode = D.Id WHERE D.W2Box Is Not NULL
			 
			
		) wh

			Inner Join dbo.tblPaCheckHist ch 
			--inner Join #EmpRef r on ch.EmployeeId = r.EmployeeId
			on wh.PostRun = ch.PostRun and wh.CheckId = ch.Id and ch.Voided = 0
		) 	WHTH

			Union all

           SElect Msc.EmployeeID, Cast(Cast(@PaYEAR as nvarchar(4)) + '1231' as datetime) as [Date], Msc.TaxAuthority, Msc.code, 0 as WithholdingCode, 
			0 as GrossEarningsMsc, Msc.Amount, 0 as Hours,0 as Weeks   
		     from
			(SElect m.EmployeeID, m.TaxAuthority, m.code, m.Amount
			from
			(SELECT m.EmployeeID, 'FE' as TaxAuthority, 
			CASE c.Descr WHEN 'Uncollected OASDI' then m.Amount WHEN 'Uncollected MEDICARE' then  m.Amount 
			WHEN 'Allocated Tips' then m.Amount else 0 end as Amount,
			CASE c.Descr WHEN 'Uncollected OASDI' then '12A' WHEN 'Uncollected MEDICARE' then  '12B' 
			WHEN 'Allocated Tips' then  '8BX' 
			else '' end as code
			FROM dbo.tblPaEmpHistMisc m INNER JOIn dbo.tblPaMiscCode c on  m.MiscCodeId = c.Id) M
			Inner Join #EmpRef r on m.EmployeeId = r.EmployeeId
			WHERE m.code <> '' and m.Amount <> 0
			) Msc 

		) SUB 
           )qry
                 Inner Join #EmpRef r on qry.EmployeeId = r.EmployeeId
		Left Join St.dbo.tblPaAatrixPIMRef p on 
			qry.TaxAuthority = p.State and qry.WithholdingCode = p.Code
		--Where CheckDate Between @StartDate And @EndDate 
		WHERE CheckDate Between @StartDate AND  Cast(Cast(@PaYEAR as nvarchar(4)) + '1231' as datetime) 
		ANd Len(qry.TaxAuthority) = 2 and  p.TaxType <> 2054
		Order By qry.TaxAuthority,  qry.CheckDate

end



--ESI query
If  @FormType <> 'W2'
begin

	Select
		'ELI' as ESI
		, 'ID' as [ID]
		, Left(wh.TaxAuthority, 2) State
		, ch.CheckDate
		, p.PIMID
		--, wh.GrossEarnings TotalWagesTips
		, 0 TotalWagesTips
		, wh.WithholdingEarnings TaxableWagesTips
		, Null Tips
		, wh.WithholdingAmount Amount
		, 0 Hours
		, Null Days
		, 0 Weeks
		, Null PayPeriodStartDate
		, Null PayPeriodEndDate
		, null AccountNumber
		, r.EmpNum PID
		
	From (Select PostRun, CheckId, case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end as TaxAuthority,
			WithholdingCode, GrossEarnings, WithholdingEarnings, WithholdingAmount
			From dbo.tblPaCheckHistWithhold 
			Where TaxauthorityType <> 0

			Union all
							--To Take a only first records in case of the W department
			Select PostRun, CheckId, case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end as TaxAuthority, 
			WithholdingCode, max(GrossEarnings) GrossEarnings, max(WithholdingEarnings)WithholdingEarnings, max(WithholdingAmount) WithholdingAmount
			From dbo.tblPaCheckHistEmplrTax 
			Where TaxauthorityType <> 0  group by PostRun, CheckId, DepartmentID, case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end, WithholdingCode



			Union all
	
			Select h.PostRun, h.CheckId, 'FE' as TaxAuthority, W2Box + W2Code AS Code, 
			0, 0, h.Amount 
			from dbo.tblPaCheckHistDeduct h 
			Inner Join dbo.tblPaDeductCode D on
			h.DeductionCode = d.DeductionCode WHERE d.W2Box Is Not NULL  and  D.EmployerPaid = 0


			Union all

			Select h.PostRun, h.CheckId, 'FE' as TaxAuthority, W2Box + W2Code AS Code, 
			0, 0, h.EarningsAmount 
			from dbo.tblPaCheckHistEarn h 
			Inner Join dbo.tblPaEarnCode D on
			h.EarningCode = d.Id WHERE d.W2Box Is Not NULL


		) wh
		Inner Join dbo.tblPaCheckHist ch inner Join #EmpRef r on ch.EmployeeId = r.EmployeeId
			on wh.PostRun = ch.PostRun and wh.CheckId = ch.Id
		Left Join St.dbo.tblPaAatrixPIMRef p on 
			Left(wh.TaxAuthority, 2) =  p.State  and wh.WithholdingCode = p.Code
		Where CheckDate Between @StartDate And @EndDate  and ch.Voided = 0
		AND   
		((Len(wh.TaxAuthority) = 4 and right(wh.TaxAuthority, 2) = p.LocalCode)  or (Left(wh.TaxAuthority, 2) = 'NJ')
		AND p.TaxType in(2054))
		Order By TaxAuthority, CheckDate
end
else
Begin


--declare @CompNum smallint
--set @CompNum  = 2
--declare @PAYEAR smallint
--set @PAYEAR = 2010
--declare @CountryCode nvarchar(20)
--set @CountryCode = 'USA'
--declare @CountryName nvarchar(20)
--Select @CountryName = 'USA'
--declare @StartDate datetime
--set @StartDate  = '1/1/2010'
--declare @EndDate datetime
--set @EndDate =  '12/31/2010'

	Select
		'ELI' as ESI
		, 'ID' as [ID] 
		, Left(qry.TaxAuthority,2) State
		, qry.CheckDate
		, p.PIMID
		,  0 TotalWagesTips
		, qry.WithholdingEarnings TaxableWagesTips
		, Null Tips
		, qry.WithholdingAmount Amount
		, 0 Hours
		, Null Days
		, 0 Weeks
		, Null PayPeriodStartDate
		, Null PayPeriodEndDate
		, null AccountNumber
		, r.EmpNum PID 
		
   From 
	(Select SUB.EmployeeId, SUB.CheckDate, SUB.TaxAuthority, SUB.WithholdingCode
			,SUB.GrossEarnings, SUB.WithholdingEarnings, SUB.WithholdingAmount, SUB.Hours, SUB.Weeks
	 from
		(Select WHTH.EmployeeId, WHTH.CheckDate, WHTH.TaxAuthority, WHTH.WithholdingCode
			, WHTH.GrossEarnings, WHTH.WithholdingEarnings, WHTH.WithholdingAmount, 
			WHTH.Hours, WHTH.Weeks
		from
		        (
			Select ch.EmployeeId, ch.CheckDate, wh.PostRun, wh.CheckId, wh.TaxAuthority, wh.WithholdingCode
			, wh.GrossEarnings, wh.WithholdingEarnings, wh.WithholdingAmount,
			case when wh.TaxAuthority = 'FE' then 0 else ch.HoursWorked end Hours,
			case when wh.TaxAuthority = 'FE' then 0 else ch.WeeksWorked end Weeks
			from

			(Select PostRun, CheckId, case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end as TaxAuthority, 
			WithholdingCode, GrossEarnings, WithholdingEarnings, WithholdingAmount
			From dbo.tblPaCheckHistWithhold 
			Where TaxauthorityType <> 0
			Union all
            			--To Take a only first records in case of the W department
			Select PostRun, CheckId, case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end as TaxAuthority, 
			WithholdingCode , max(GrossEarnings) GrossEarnings, max(WithholdingEarnings)WithholdingEarnings, max(WithholdingAmount) WithholdingAmount
			From dbo.tblPaCheckHistEmplrTax 
			Where TaxauthorityType <> 0 group by PostRun, CheckId, DepartmentID, case TaxAuthorityType when (0) then 'FED' when (1) then [State] else [State]+ [Local] end, WithholdingCode


			Union all
	
			Select h.PostRun, h.CheckId, 'FE' as TaxAuthority, 
			case W2Box when '10' then W2Box + ISNULL(W2Code, 'B') 
			--When '14' then W2Box + 'B' else W2Box + W2Code end AS Code, 
			When '14' then W2Box + Left(W2Code, 1) else W2Box + W2Code end AS Code, 
			0, 0, h.Amount 
			from dbo.tblPaCheckHistDeduct h 
			Inner Join dbo.tblPaDeductCode D on
			h.DeductionCode = d.DeductionCode WHERE d.W2Box Is Not NULL and  D.EmployerPaid = 0

			Union all
			
			Select h.PostRun, h.CheckId, 'FE' as TaxAuthority, 
			Case W2Box when '10' then W2Box + ISNULL(W2Code, 'B')  when '11' then W2Box + ISNULL(W2Code, 'N') 
			--When '14' then W2Box + 'B' else W2Box + W2Code end AS Code,
			When '14' then W2Box + Left(W2Code, 1) else W2Box + W2Code end AS Code,
			0, 0, h.EarningsAmount 
			from dbo.tblPaCheckHistEarn h 
			Inner Join dbo.tblPaEarnCode D on
			h.EarningCode = d.Id WHERE d.W2Box Is Not NULL  

			) wh

			Inner Join dbo.tblPaCheckHist ch 
			on wh.PostRun = ch.PostRun and wh.CheckId = ch.Id and ch.Voided = 0
		) 	WHTH

			Union all
			

		   SElect Msc.EmployeeID, Cast(Cast(@PaYEAR as nvarchar(4)) + '1231' as datetime) as [Date], Msc.TaxAuthority, Msc.code, 0 as WithholdingCode, 
			0 as GrossEarningsMsc, Msc.Amount, 0 as Hours,0 as Weeks   
		     from
			(SElect m.EmployeeID, m.TaxAuthority, m.code, m.Amount
			from
			(SELECT m.EmployeeID, 'FE' as TaxAuthority, 
			CASE c.Descr WHEN 'Uncollected OASDI' then m.Amount WHEN 'Uncollected MEDICARE' then  m.Amount 
			WHEN 'Allocated Tips' then m.Amount else 0 end as Amount,
			CASE c.Descr WHEN 'Uncollected OASDI' then '12A' WHEN 'Uncollected MEDICARE' then  '12B' 
			WHEN 'Allocated Tips' then  '8BX' 
			else '' end as code
			FROM dbo.tblPaEmpHistMisc m INNER JOIn dbo.tblPaMiscCode c on  m.MiscCodeId = c.Id) M
			Inner Join #EmpRef r on m.EmployeeId = r.EmployeeId
			WHERE m.code <> '' and m.Amount <> 0
			) Msc 
 
		) SUB 
           )qry
                 Inner Join #EmpRef r on qry.EmployeeId = r.EmployeeId
		INNER Join St.dbo.tblPaAatrixPIMRef p on 
			Left(qry.TaxAuthority, 2) = p.State  and qry.WithholdingCode = p.Code
		WHERE CheckDate Between @StartDate AND  Cast(Cast(@PaYEAR as nvarchar(4)) + '1231' as datetime) 
		AND   
		(((Len(qry.TaxAuthority) = 4 and p.ERFlag = 'E')  and right(qry.TaxAuthority, 2) = p.LocalCode) or (Left(qry.TaxAuthority, 2) = 'NJ')
		AND p.TaxType in(2054))
		Order By qry.TaxAuthority,  qry.CheckDate

end



End

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaAatrixrecords_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaAatrixrecords_proc';

