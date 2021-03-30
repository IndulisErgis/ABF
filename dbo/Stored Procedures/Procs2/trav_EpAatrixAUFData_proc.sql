
CREATE PROCEDURE [dbo].[trav_EpAatrixAUFData_proc]
AS
SET NOCOUNT ON
BEGIN TRY
	Declare @FrmId nvarchar(32), @Mode nvarchar(8), @VendorCode as nvarchar(10)
	Declare @FormType nvarchar(15), @DataBreakout int
	Declare @SrcVendor nvarchar(30), @SrcProgram nvarchar(30), @VersNum decimal(10,2)
	Declare @PaYEAR smallint, @Month smallint, @Qtr smallint, @StartDate datetime, @EndDate datetime
		, @CompName nvarchar(50), @Country nvarchar(6), @CompEIN as nvarchar(10), @NumOfEmp int
		, @DCBLimit as decimal(28, 10)
	Declare @City nvarchar(30), @Region nvarchar(10), @PostalCode nvarchar(10), @Email nvarchar(255)
		, @AddressLine1 nvarchar(30), @AddressLine2 nvarchar(30), @PhoneNumber nvarchar(20), @FaxNumber nvarchar(20), @CountryName nvarchar(50)
	Declare @CompNum int
	Declare @MedAmtLimit decimal(28, 10)

	SELECT @DCBLimit = 0, @CompNum = 1
	
	--Config Info.
	Select @FrmId = Cast([Value] AS nvarchar(32)) from #GlobalValues WHERE [Key] = 'FormName' 
	Select @Mode = Cast([Value]  AS nvarchar(8)) from #GlobalValues WHERE [Key] = 'Mode' 
	Select @VendorCode = Cast([Value] AS nvarchar(10)) from #GlobalValues WHERE [Key] = 'VendorCode'

	Select @FormType = Cast([Value] AS nvarchar(15)) from #GlobalValues WHERE [Key] = 'FormType' 
	--Select @FilterType =  Cast([Value] AS smallint) from #GlobalValues WHERE [Key] = 'FilterType' --FilterType: 0;Year to date;1;Quarter to date;2;Month to date;3;Daily;4;Date Range
	Select @DataBreakout =  Cast([Value] AS smallint) from #GlobalValues WHERE [Key] = 'DataBreakout' 
 
	--Header Records:
	--VER
	Select @SrcVendor = Cast([Value] AS nvarchar(30)) from #GlobalValues WHERE [Key] = 'SourceVendor' 
	Select @SrcProgram = Cast([Value] AS nvarchar(30)) from #GlobalValues WHERE [Key] = 'SourceProgram' 

	Select @VersNum = ROUND(convert(decimal(10,2), Value), 2) from #GlobalValues WHERE [Key] = 'VersNum' 

	--DAT
	--default value
	Select @PaYEAR = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'
	SELECT @Month = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Month'
	SELECT @Qtr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Qtr' 

	SELECT @StartDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'StartDate'
	SELECT @EndDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'EndDate'

	Select @CompName = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'CompName' 
	Select @Country  = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'Country' 

	Select @CompEIN = Left(Cast([Value] AS nvarchar(15)) , 10) from #GlobalValues WHERE [Key] = 'FEIN' 
	Select @DCBLimit = Cast([Value] AS decimal(28,10)) FROM #GlobalValues WHERE [Key] = 'DCBLimit' 

	Select @City = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'City' 
	Select @Region  = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'Region' 
	Select @PostalCode  = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'PostalCode' 
	Select @Email  = Cast([Value] AS nvarchar(255)) FROM #GlobalValues WHERE [Key] = 'Email' 
	Select @AddressLine1  = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'AddressLine1' 
	Select @AddressLine2  = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'AddressLine2' 
	Select @PhoneNumber  = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'PhoneNumber' 
	Select @FaxNumber = Cast([Value] AS nvarchar(20)) FROM #GlobalValues WHERE [Key] = 'FaxNumber' 
	Select @CountryName = Cast([Value] AS nvarchar(50)) FROM #GlobalValues WHERE [Key] = 'CountryName' 

	Select @NumOfEmp = COUNT(*) From dbo.tblPaEmployee (nolock)

	Select  @MedAmtLimit = [Column1] From [ST].[dbo].[tblPaSTTaxTablesDtl] 
		Where [PaYear] = @PaYEAR and Left([TableId], 3) = N'FED' and right([TableId], 3) = N'MED' and [status] = N'NA' and [SequenceNumber] = 2 


	--validate required parameter values
	IF @FrmId IS NULL  OR @VendorCode IS NULL OR @FormType IS NULL OR @Month IS NULL OR @CompEIN IS NULL Or
		@PaYEAR IS NULL OR @StartDate IS NULL OR @EndDate IS NULL OR @MedAmtLimit IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--build PIM taxtype cross references (enable cross type mapping of state/local data)
	Create Table #PIMTaxInfo
	(
		[PIMID] [int] NOT NULL , --TRAVERSE ID
		[State] [nvarchar](2) NOT NULL ,
		[LocalCode] [nchar](2) NULL ,
		[Code] [nvarchar](11) NOT NULL ,
		[EmployerPaid] [bit] NOT NULL ,
		[TaxType] [int] NOT NULL , --Aatrix tax type
		[AufType] [tinyint] NOT NULL , --AUF Authority Type ENUM:0;Fed;1;State;2;Local
		[Descr] [nvarchar](255) NULL
	)

	Insert Into #PIMTaxInfo ([PIMID], [State], [LocalCode], [Code], [TaxType], [Descr], [EmployerPaid], [AufType])
	Select Distinct [PIMID], [State], [LocalCode], [Code], [TaxType], [Descr]
		, Case When [ERFlag] = 'E' Then 0 Else 1 End
		, Case 
			When [TaxType] < 2000 Then 1 --State
			When [TaxType] >= 2000 And [TaxType] <= 3000 Then 2 --Local
			When [TaxType] > 3000 And [TaxType] < 5000 Then 0 --Federal
			When [TaxType] >= 5000 Then 2 --Local
			End
	From [ST].dbo.tblPaAatrixPIMRef
   
	--Config Info.
	Select 'ConfInfo' as [AUFTag], @FrmId as FormName
		, @Mode as Mode, @FormType as FormType, @DataBreakout as DataBreakout, @VendorCode as VendorCode, @CompEIN as Company

	--VER
	Select 'VER' as [AUFTag], @VersNum as VersionNumber, @SrcVendor as SourceVendor, @SrcProgram as SourceProgram 
	
	--DAT
	Select 'DAT' as [AUFTag], @PaYEAR as [YEAR], @Qtr as [Quarter], @Month as [Month], @StartDate as [FirstDate], @EndDate as [LastDate]

	--CMP	
	Select 
		'CMP' as [AUFTag]
		, @CompNum as [ID]
		, @CompName as CompanyName
		, @CompName as TradeName
		, @AddressLine1 as AddressLine1
		, @AddressLine2 as AddressLine2
		, @City as City
		, CASE WHEN @Country = 'USA' THEN @Region ELSE NULL END as [State]
		, NULL as County
		, NULL as CountyCode
		, CASE WHEN @Country = 'USA' THEN @PostalCode ELSE NULL END as ZipCode
		, @Country as Country
		, CASE WHEN @Country = 'USA' THEN NULL ELSE @CountryName END as CountryCode --Name
		, CASE WHEN @Country = 'USA' THEN NULL ELSE @PostalCode END CountryZipCode
		, NULL as DBA
		, NULL as Branch
		, NULL as TaxArea
		, @PhoneNumber as PhoneNumber
		, NULL as PhoneExt
		, @FaxNumber as FaxNumber
		, NULL IndustryCode
		, @CompEIN EIN
		, NULL as ContactTitle
		, NULL as ContactName
		, NULL as ContactPhone
		, NULL as ContactPhoneExt
		, NULL as ContactAddress
		, coalesce(@NumOfEmp,0) NumberOfEmployees
		, case When cast(CHARINDEX('#', @Email) as int) > 0 then LEFT(cast(@Email as nvarchar(40)), Cast(CHARINDEX('#', @Email) as int) -1) end EMailAddress
      	, NULL as TerminationDate
		, CASE WHEN @Country = 'USA' THEN NULL ELSE @Region END NonUSStateProvince
		, 'R' as EmploymentCode  --  'R','M''A''H''F''X' 
		, NULL as NationalIDNumber
		, NULL as KindOfEmployer


	--exit when processing history - nothing more needed
	IF @Mode = 'History'
	Begin
		Return
	End

	--process regular (non-history) datasets

	--build a period to date reference table
	CREATE TABLE #PdDate 
	(
		[PaYear] [smallint] NOT NULL, 
		[PaMonth] [tinyint] NOT NULL, 
		[StartDate] [Datetime] NOT NULL,
		[EndDate] [Datetime] NOT NULL,
		PRIMARY KEY ([PaYear], [PaMonth])
	)

	--List of employees with generated reference number
	Create table #EmpRef
	(
		[EmpNum] [int] Identity(1, 1) NOT NULL,
		[EmployeeId] [pEmpId],
		PRIMARY KEY ([EmployeeId])
	)

	--Table for tracking misc employee values
	Create Table #EmpMisc
	(
		[Id] [bigint] Identity(1, 1),
		[EmployeeId] [pEmpId],
		[PaYear] [smallint],
		[PaMonth] [tinyint],
		[PaDate] [datetime],
		[HoursWorked] [pDecimal],
		[WeeksWorked] [pDecimal],
		UNIQUE NONCLUSTERED ([EmployeeId], [PaYear], [PaMonth], [PaDate], [Id])
	)

	--table for tracking federal employee amounts
	CREATE TABLE #EmpFederal
	(
		[Id] [bigint] Identity(1, 1),
		[EmployeeId] [pEmpId],
		[PaYear] [smallint],
		[PaMonth] [tinyint],
		[PaDate] [datetime],
		[FicaTips] [pDecimal] DEFAULT(0),
		[GrossPayAmount] [pDecimal] DEFAULT(0),
		[NetPayAmount] [pDecimal] DEFAULT(0),
		[FUTAWithheld] [pDecimal] DEFAULT(0),
		[FUTAEarnings] [pDecimal] DEFAULT(0),
		[FUTAGrossEarnings] [pDecimal] DEFAULT(0),
		[EMEWithheld] [pDecimal] DEFAULT(0),
		[EMEEarnings] [pDecimal] DEFAULT(0),
		[EMEGrossEarnings] [pDecimal] DEFAULT(0),
		[EOAWithheld] [pDecimal] DEFAULT(0),
		[EOAEarnings] [pDecimal] DEFAULT(0),
		[EOAGrossEarnings] [pDecimal] DEFAULT(0),
		[SSWithheld] [pDecimal] DEFAULT(0),
		[SSEarnings] [pDecimal] DEFAULT(0),
		[MEDWithheld] [pDecimal] DEFAULT(0),
		[MEDEarnings] [pDecimal] DEFAULT(0),
		[FEDWithheld] [pDecimal] DEFAULT(0),
		[FEDEarnings] [pDecimal] DEFAULT(0),
		[EICWithheld] [pDecimal] DEFAULT(0),
		[EICEarnings] [pDecimal] DEFAULT(0),
		[AdditionalMedicareWages] [pDecimal] DEFAULT(0),
		UNIQUE NONCLUSTERED ([EmployeeId], [PaYear], [PaMonth], [PaDate], [Id])
	)

	--table for tracking state/local employee amounts
	Create Table #EmpStateLocal 
	(
		[Id] [bigint] Identity(1, 1),
		[EmployeeId] [pEmpId],
		[PaYear] [smallint],
		[PaMonth] [tinyint],
		[PaDate] [datetime],
		[State] [nvarchar](2),
		[Local] [nvarchar](2),
		[Code] [nvarchar](11),
		[EmployerPaid] [bit],
		[GrossEarnings] [pDecimal],
		[WithholdEarnings] [pDecimal],
		[WithholdAmount] [pDecimal],
		UNIQUE NONCLUSTERED ([EmployeeId], [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid], [Id])
	)


	--Employee history is not tracked on a per day/date basis
	--	therefore we use the last day of each month as a reference/check date
	--use the list of years from tblPaYear_Common to build a complete period/year to date translation map
	DECLARE @loop tinyint
	SET @loop = 1
	WHILE @loop <= 12
	BEGIN
		INSERT INTO #PdDate([PaYear], [PaMonth], [StartDate], [EndDate])
		SELECT [PaYear], @loop
			, CAST(str([PaYear], 4, 0) + replace(str(@loop, 2, 0), ' ', '0') + '01' AS DATETIME)
			, DATEADD(d, -1, DATEADD(m, 1, CAST(str([PaYear], 4, 0) + replace(str(@loop, 2, 0), ' ', '0') + '01' AS DATETIME)))
			FROM [dbo].[tblPaYear_Common]

		SET @loop = @loop + 1
	END

	--build a list of employee id numbers for use as a PID (Payroll Id for Aatrix)
	--	limit to employees with check history within the given date range
	Insert Into #EmpRef (EmployeeId)
	Select e.[EmployeeId] 
		From dbo.tblPaEmployee e
		Where e.[EmployeeId] in 
			(
				Select [EmployeeId] 
				From dbo.tblPaCheckHist h
				WHERE [Voided] = 0 And h.[CheckDate] Between @StartDate and @EndDate
				Group By [EmployeeId]
			)

	--#EmpMisc
	--capture employee hours/weeks worked per period 
	Insert into #EmpMisc ([EmployeeId], [PaYear], [PaMonth], [PaDate], [HoursWorked], [WeeksWorked])
	Select m.[EmployeeId], m.[PaYear], m.[PaMonth], m.[EntryDate]
		, SUM(Case When m.MiscCodeId = 1 Then m.[Amount] Else 0 End) -- HoursWorked
		, SUM(Case When m.MiscCodeId = 2 Then m.[Amount] Else 0 End) -- WeeksWorked
	FROM dbo.tblPaEmpHistMisc m
	Inner join #EmpRef r on m.EmployeeId = r.EmployeeId
	Where m.MiscCodeId in (1, 2) --1;Hours;2;Weeks
		And m.[EntryDate] Between @StartDate and @EndDate
	Group By m.[EmployeeId], m.[PaYear], m.[PaMonth], m.[EntryDate]


	--#EmpFederal
	--capture employee FICA Tips
	Insert into #EmpFederal ([EmployeeId], [PaYear], [PaMonth], [PaDate], [FicaTips])
	Select m.[EmployeeId], m.[PaYear], m.[PaMonth], m.[EntryDate]
		, SUM(m.[Amount]) -- FicaTips
	FROM dbo.tblPaEmpHistMisc m
	Inner join #EmpRef r on m.[EmployeeId] = r.[EmployeeId]
	Where m.[MiscCodeId] = 11 --11;FicaTips
		And m.[EntryDate] Between @StartDate and @EndDate
	Group By m.[EmployeeId], m.[PaYear], m.[PaMonth], m.[EntryDate]
	Having Sum(m.[Amount]) <> 0

	--capture employee gross/net pay
	Insert Into #EmpFederal ([EmployeeId], [PaYear], [PaMonth], [PaDate], [GrossPayAmount], [NetPayAmount])  
	Select n.[EmployeeId], n.[PaYear], n.[PaMonth], n.[EntryDate] 
		, SUM(n.[GrossPayAmount]), SUM(n.[NetPayAmount])
	From dbo.tblPaEmpHistGrossNet n
	Inner join #EmpRef r on n.[EmployeeId] = r.[EmployeeId]
	Where n.[EntryDate] Between @StartDate and @EndDate
	Group By n.[EmployeeId], n.[PaYear], n.[PaMonth], n.[EntryDate]
	Having SUM(n.[GrossPayAmount]) <> 0 and SUM(n.[NetPayAmount]) <> 0

	--capture employee federal values
	Insert Into #EmpFederal ([EmployeeId], [PaYear], [PaMonth], [PaDate]
		, [FUTAWithheld], [FUTAEarnings], [FUTAGrossEarnings]
		, [EMEWithheld], [EMEEarnings], [EMEGrossEarnings]
		, [EOAWithheld], [EOAEarnings], [EOAGrossEarnings]
		, [SSWithheld],	[SSEarnings], [MEDWithheld], [MEDEarnings]
		, [FEDWithheld], [FEDEarnings], [EICWithheld], [EICEarnings]
		, [AdditionalMedicareWages])
	Select wh.[EmployeeId], wh.[PaYear], wh.[PaMonth], wh.[EntryDate]
		, SUM(Case When [WithholdingCode] = N'FUT' Then [WithholdAmount] Else 0 End) [FUTAWithheld]
		, SUM(Case When [WithholdingCode] = N'FUT' Then [TaxableAmount] Else 0 End) [FUTAEarnings]
		, SUM(Case When [WithholdingCode] = N'FUT' Then [EarningAmount] Else 0 End) [FUTAGrossEarnings]
		, SUM(Case When [WithholdingCode] = N'EME' Then [WithholdAmount] Else 0 End) [EMEWithheld]
		, SUM(Case When [WithholdingCode] = N'EME' Then [TaxableAmount] Else 0 End) [EMEEarnings]
		, SUM(Case When [WithholdingCode] = N'EME' Then [EarningAmount]Else 0 End) [EMEGrossEarnings]
		, SUM(Case When [WithholdingCode] = N'EOA' Then [WithholdAmount] Else 0 End) [EOAWithheld]
		, SUM(Case When [WithholdingCode] = N'EOA' Then [TaxableAmount] Else 0 End) [EOAEarnings]
		, SUM(Case When [WithholdingCode] = N'EOA' Then [EarningAmount]Else 0 End) [EOAGrossEarnings]
		, SUM(Case When [WithholdingCode] = N'OAS' Then [WithholdAmount] Else 0 End) [SSWithheld]
		, SUM(Case When [WithholdingCode] = N'OAS' Then [TaxableAmount] Else 0 End) [SSEarnings]
		, SUM(Case When [WithholdingCode] = N'MED' Then [WithholdAmount] Else 0 End) [MEDWithheld]
		, SUM(Case When [WithholdingCode] = N'MED' Then [TaxableAmount] Else 0 End) [MEDEarnings]
		, SUM(Case When [WithholdingCode] = N'FWH' Then [WithholdAmount] Else 0 End) [FEDWithheld]
		, SUM(Case When [WithholdingCode] = N'FWH' Then [TaxableAmount] Else 0 End) [FEDEarnings]
		, SUM(Case When [WithholdingCode] = N'EIC' Then [WithholdAmount] Else 0 End) [EICWithheld]
		, SUM(Case When [WithholdingCode] = N'EIC' Then [TaxableAmount] Else 0 End) [EICEarnings]
		, 0 --AdditionalMedicareWages calculated separately
	From dbo.tblPaEmpHistWithhold wh
	Inner join #EmpRef r on wh.[EmployeeId] = r.[EmployeeId]
	Where wh.[TaxAuthorityType] = 0 --federal only
		And wh.[EntryDate] Between @StartDate and @EndDate
	Group by wh.[EmployeeId], wh.[PaYear], wh.[PaMonth], wh.[TaxAuthorityType], wh.[WithholdingCode], wh.[EntryDate]

	--capture Employee AdditionalMedicareWages - cumulative value with a table based cutoff for the year, assigned to the latest date within date criteria
	Insert Into #EmpFederal ([EmployeeId], [PaYear], [PaMonth], [PaDate]
		, [FUTAWithheld], [FUTAEarnings], [FUTAGrossEarnings]
		, [EMEWithheld], [EMEEarnings], [EMEGrossEarnings]
		, [EOAWithheld], [EOAEarnings], [EOAGrossEarnings]
		, [SSWithheld],	[SSEarnings], [MEDWithheld], [MEDEarnings]
		, [FEDWithheld], [FEDEarnings], [EICWithheld], [EICEarnings]
		, [AdditionalMedicareWages])
	Select wh.[EmployeeId], MAX(wh.[PaYear]), MAX(wh.[PaMonth]), MAX(wh.[EntryDate])
		, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		, CASE WHEN SUM([TaxableAmount]) <= @MedAmtLimit 
			THEN 0 
			ELSE
				CASE WHEN SUM(CASE WHEN wh.[EntryDate] < @StartDate THEN [TaxableAmount] ELSE 0 END) >= @MedAmtLimit 
					THEN SUM(CASE WHEN wh.[EntryDate] >= @StartDate THEN [TaxableAmount] ELSE 0 END)
					ELSE SUM([TaxableAmount]) - @MedAmtLimit END 
			END 
	From dbo.tblPaEmpHistWithhold wh
	Inner join #EmpRef r on wh.[EmployeeId] = r.[EmployeeId]
	Where wh.[TaxAuthorityType] = 0 --federal only
		And wh.[WithholdingCode] = N'MED'
		And wh.[EntryDate] <= @EndDate
		And wh.[PaYear] = @PaYEAR
	Group by wh.[EmployeeId], wh.[PaYear]


	--#EmpStateLocal
	--capture state/local withholdings 
	Insert into #EmpStateLocal ([EmployeeId], [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid]
		, [GrossEarnings], [WithholdEarnings], [WithholdAmount])
	Select h.[EmployeeId], h.[PaYear], h.[PaMonth], h.[EntryDate]
		, h.[State], h.[Local]
		, h.[WithholdingCode], h.[EmployerPaid]
		, SUM(h.[EarningAmount])
		, SUM(h.[TaxableAmount])
		, SUM(h.[WithholdAmount])
	From dbo.tblPaEmpHistWithhold h
	Inner join #EmpRef r on h.EmployeeId = r.EmployeeId
	Where h.[TaxauthorityType] in (1, 2) --state, local
		And (h.[EarningAmount] <> 0 Or h.[TaxableAmount] <> 0 Or h.[WithholdAmount] <> 0)
		And h.[EntryDate] Between @StartDate and @EndDate
	Group By h.[EmployeeId], h.[PaYear], h.[PaMonth], h.[EntryDate]
		, h.[State], h.[Local], h.[WithholdingCode], h.[EmployerPaid]


	--capture W2 enabled deductions
	Insert into #EmpStateLocal ([EmployeeId], [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid]
		, [GrossEarnings], [WithholdEarnings], [WithholdAmount])
	Select h.[EmployeeId], h.[PaYear], h.[PaMonth], h.[EntryDate]
		, 'FE' AS [State], NULL AS [Local]
		, CASE d.[W2Box] 
			When N'10' Then d.[W2Box] + ISNULL(d.[W2Code], 'B') 
			When N'14' Then d.[W2Box] + Left(d.[W2Code], 1) 
			Else d.[W2Box] + d.[W2Code] 
			End AS [Code]
		, h.[EmployerPaid]
		, 0
		, 0
		, SUM(h.[Amount])
	From dbo.tblPaEmpHistDeduct h 
	Inner join #EmpRef r on h.EmployeeId = r.EmployeeId
	Inner Join dbo.tblPaDeductCode d on	h.[DeductionCode] = d.[DeductionCode] and h.[EmployerPaid] = d.[EmployerPaid]
	WHERE d.[W2Box] Is Not NULL
		And h.[Amount] <> 0
		And h.[EntryDate] Between @StartDate and @EndDate
	Group By h.[EmployeeId], h.[PaYear], h.[PaMonth], h.[EntryDate], d.[W2Box], d.[W2Code], h.[EmployerPaid]


	--capture W2 enabled earnings
	Insert into #EmpStateLocal ([EmployeeId], [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid]
		, [GrossEarnings], [WithholdEarnings], [WithholdAmount])
	Select h.[EmployeeId], h.[PaYear], h.[PaMonth], h.[EntryDate]
		, 'FE' AS [State], NULL AS [Local]
		, CASE d.[W2Box] 
			When N'10' Then d.[W2Box] + ISNULL(d.[W2Code], 'B') 
			When N'11' Then d.[W2Box] + ISNULL(d.[W2Code], 'N') 
			When N'14' Then d.[W2Box] + Left(d.[W2Code], 1) 
			Else d.[W2Box] + d.[W2Code] 
			End 
		, 0 --Employee Paid
		, 0
		, 0
		, SUM(h.[Amount])
	From dbo.tblPaEmpHistEarn h 
	Inner join #EmpRef r on h.EmployeeId = r.EmployeeId
	Inner Join dbo.tblPaEarnCode d on h.[EarningCode] = d.[Id]
	WHERE d.[W2Box] Is Not NULL
		And h.[Amount] <> 0
		And h.[EntryDate] Between @StartDate and @EndDate
	Group By h.[EmployeeId], h.[PaYear], h.[PaMonth], h.[EntryDate], d.[W2Box], d.[W2Code]


	--capture additional misc values
	Insert into #EmpStateLocal ([EmployeeId], [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid]
		, [GrossEarnings], [WithholdEarnings], [WithholdAmount])
	Select h.[EmployeeId], h.[PaYear], h.[PaMonth], h.[EntryDate]
		, 'FE' AS [State], NULL AS [Local]
		, Case d.[Descr] 
			When 'Uncollected OASDI' Then '12A' 
			When 'Uncollected MEDICARE' Then '12B'
			When 'Allocated Tips' Then '8BX' 
			Else '' 
			End
		, 0 --Employee Paid
		, 0
		, 0
		, SUM(Case d.[Descr] 
			When 'Uncollected OASDI' Then h.[Amount] 
			When 'Uncollected MEDICARE' Then h.[Amount]
			When 'Allocated Tips' Then h.[Amount] 
			Else 0 
			End)
	From dbo.[tblPaEmpHistMisc] h
	Inner join #EmpRef r on h.EmployeeId = r.EmployeeId
	Inner Join dbo.[tblPaMiscCode] d on h.[MiscCodeId] = d.[Id]
		And Case d.[Descr] 
			When 'Uncollected OASDI' Then h.[Amount] 
			When 'Uncollected MEDICARE' Then h.[Amount]
			When 'Allocated Tips' Then h.[Amount] 
			Else 0 
			End <> 0
		And h.[EntryDate] Between @StartDate and @EndDate
	Group By h.[EmployeeId], h.[PaYear], h.[PaMonth], h.[EntryDate], d.[Descr]


	--==========================
	--Return the datasets
	--==========================

	--PIM - Payroll Information Members
	Select Distinct 'PIM' as [AUFTag]
		, Case When (h.[State] = 'FE' and IsNULL(h.[Code], '') <> '') 
			Then h.[Code]
			Else 
				Case When ISnULL(p.[LocalCode], '') <> '' 
					Then p.[State] + ISnULL(p.[LocalCode], '') + p.[Code]
					Else p.[State] + p.[Code]
				End 
			End AS [Title]
		, p.[PIMID], p.[Descr], p.[TaxType], p.[State]
		, Case When p.[State] = 'FE' 
			Then 'W2Code' 
			Else Null 
			End AS [W2LocalityTaxTypeCode]
		, ISNULL(ta.[TaxId], '') AS [AcctNumber]
	From #PIMTaxInfo p
	Left Join (
		Select th.[State], th.[Local], td.[Code], td.[EmployerPaid], td.[TaxId]
		From dbo.tblPaTaxAuthorityHeader th 
		Inner Join dbo.tblPaTaxAuthorityDetail td on th.Id = td.TaxAuthorityId 
		Where td.[PaYear] = @PaYEAR
	) ta 
		on p.[State] = ta.[State] and ISNULL(p.[LocalCode], '') = ISNULL(ta.[Local], '') 
			and p.[Code] = ta.[Code] and p.[EmployerPaid] = ta.[EmployerPaid]
	Inner Join #EmpStateLocal h 
		on p.[State] = h.[State] and ISNULL(p.[LocalCode], '') = ISNULL(h.[Local], '') 
			and p.[Code] = h.[Code] and p.[EmployerPaid] = h.[EmployerPaid] --filter for active id values

	--GTO - general totals 
	Select 'GTO' as [AUFTag]
		, fed.[PaDate] AS [EntryDate]
		, SUM(fed.[GrossPayAmount]) AS [GrossPay]
		, SUM(fed.[NetPayAmount]) AS [NetPay]
		, SUM(isnull(fed.[SSEarnings], 0) - isnull(fed.[FicaTips], 0)) AS [SSWages]
		, SUM(fed.[SSWithheld]) AS [SSLiability]
		, SUM(fed.[MEDEarnings]) AS [MedWages]
		, SUM(fed.[MEDWithheld]) AS [MedLiability]
		, SUM(fed.[FEDEarnings]) AS [FedEarnings]
		, SUM(fed.[FEDWithheld]) AS [FedLiability]
		, SUM(fed.[FUTAEarnings]) AS [TaxableFUTAWages]
		, SUM(fed.[FUTAWithheld]) AS [FUTALiability]
		, SUM(-fed.[EICWithheld]) AS [EIC]
		, SUM(fed.[FicaTips]) AS [SSTips]
		, SUM(fed.[FUTAGrossEarnings]) AS [TotalFUTAWages]
		, null AS [PayPeriodStartDate]
		, null AS [PayPeriodEndDate]
		, null AS [940Deposit]
		, null AS [941Deposit]
		, null AS [943Deposit]
		, null AS [945Deposit]
		, SUM(fed.[EOAWithheld]) AS [SSEmployerMatch]
		, SUM(fed.[EMEWithheld]) AS [MedicareEmployerMatch]
		, 0 AS [AdditionalMedicareTax]
		, SUM(fed.[AdditionalMedicareWages]) AS AdditionalMedicareWages
		, @CompNum AS [PID]
	From #EmpFederal fed
	Group By fed.[PaDate]

	--CSI - Company State Items
	Select 'CSI' AS [AUFTag]
		, amt.[State]
		, amt.[PaDate] AS [EntryDate]
		, p.PIMID
		, ISNULL(ta.TaxId, '') AS [AcctNumber]
		, amt.[GrossEarnings] AS [TotalWagesTips]
		, amt.[WithholdEarnings] AS [TaxableWagesTips]
		, NULL AS [Tips]
		, amt.[WithholdAmount] AS [Amount]
		, ISNULL(Rates.Rate, 0) AS [Rate]
		, ms.[HoursWorked] AS [Hours]
		, Null Days
		, ms.[WeeksWorked] AS [Weeks]
		, Null PayPeriodStartDate
		, Null PayPeriodEndDate
		, @CompNum as [PID]
	From 
	(
		Select [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid]
			, SUM([GrossEarnings]) AS [GrossEarnings]
			, SUM([WithholdEarnings]) AS [WithholdEarnings]
			, SUM([WithholdAmount]) AS [WithholdAmount]
		From #EmpStateLocal
		Group By [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid]
	) amt
	Left Join 
	(
		Select [PaYear], [PaMonth], [PaDate]
			, Sum([HoursWorked]) AS [HoursWorked] 
			, SUM([WeeksWorked]) AS [WeeksWorked]
		From #EmpMisc
		Group By [PaYear], [PaMonth], [PaDate]
	) ms on ms.[PaYear] = amt.[PaYear] And ms.[PaMonth] = amt.[PaMonth] And ms.[PaDate] = amt.[PaDate]
	Inner Join (Select [PIMID], [State], [Code], [EmployerPaid], [TaxType], [LocalCode] FROM #PIMTaxInfo Where [AufType] = 1) p  --state auf types only
		on p.[State] = amt.[State] And p.[Code] = amt.[Code] And p.[EmployerPaid] = amt.[EmployerPaid] And ISNULL(p.[LocalCode], '') = ISNULL(amt.[Local], '')
	Left Join (
		Select th.[State], th.[Local], td.[Code], td.[EmployerPaid], td.[TaxId]
			From dbo.tblPaTaxAuthorityHeader th
			Inner Join dbo.tblPaTaxAuthorityDetail td on th.Id = td.TaxAuthorityId
			Where td.[PaYear] = @PaYear
			) ta
		on amt.[State] = ta.[State] and amt.[Code] = ta.[Code] and amt.[EmployerPaid] = ta.[EmployerPaid] and ISNULL(amt.[Local], '') = ISNULL(ta.[Local], '')
	Left Join 
	(
		Select Replace(Substring([TableId], 2, 4), '_', '') AS [State]
			, Substring([TableId], 6, 3) AS [Code]
			, [Column1] AS [Rate]
		From [ST].dbo.tblPaSTTaxTablesDtl
		Where [PaYear] = @PaYEAR  
			and Left([TableId], 3) <> 'FED' and (Substring([TableId], 6, 3) = 'SUI' or Substring([TableId], 6, 2) = 'SO') 
			and [Status] = 'NA' and [SequenceNumber] = 1
	) Rates
		on Rates.[State] = amt.[State] and Rates.[Code] = amt.[Code]

	--CLI - Company Local Items
	Select 'CLI' AS [AUFTag]
		, amt.[State]
		, amt.[PaDate] AS [EntryDate]
		, p.PIMID
		, NULL AS [AcctNumber]
		, 0 AS [TotalWagesTips]
		, amt.[WithholdEarnings] AS [TaxableWagesTips]
		, Null AS [Tips]
		, amt.[WithholdAmount] AS [Amount]
		, ISNULL(Rates.Rate, 0) AS [Rate]
		, 0 AS [Hours]
		, Null AS [Days]
		, 0 AS [Weeks]
		, Null AS [PayPeriodStartDate]
		, Null AS [PayPeriodEndDate]
		, @CompNum AS [PID]
	From 
	(
		Select [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid]
			, SUM([GrossEarnings]) AS [GrossEarnings]
			, SUM([WithholdEarnings]) AS [WithholdEarnings]
			, SUM([WithholdAmount]) AS [WithholdAmount]
		From #EmpStateLocal
		Group By [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid]
	) amt
	Inner Join (Select [PIMID], [State], [Code], [EmployerPaid], [TaxType], [LocalCode] FROM #PIMTaxInfo Where [AufType] = 2) p  --local auf types only
		on p.[State] = amt.[State] And p.[Code] = amt.[Code] And p.[EmployerPaid] = amt.[EmployerPaid] And ISNULL(p.[LocalCode], '') = ISNULL(amt.[Local], '')
	Left Join 
	(
		Select Replace(Substring([TableId], 2, 4), '_', '') AS [State]
			, Substring([TableId], 6, 3) AS [Code]
			, [Column1] AS [Rate]
		From [ST].dbo.tblPaSTTaxTablesDtl
		Where [PaYear] = @PaYEAR  
			and Left([TableId], 3) <> 'FED' and (Substring([TableId], 6, 3) = 'SUI' or Substring([TableId], 6, 2) = 'SO') 
			and [Status] = 'NA' and [SequenceNumber] = 1
	) Rates
		on Rates.[State] = amt.[State] and Rates.[Code] = amt.[Code]
	--Where p.[EmployerPaid] = 0
	--Note:Employee paid filtering removed to enable all data to be submitted to Aatrix, PIM Id mapping can be removed to exclude data if needed


	--ALE - ALE Member Information
	SELECT 'ALE' AS  [AUFTag]
		, h.[GovEntity], h.[ALEGroup], h.[SelfInsured], 'N' as [QualifyingOfferMethod], h.[QOMTransitionRelief]
		, h.[4980HTransitionRelief], h.[98PctOfferMethod]
		, mth.[MinCoverage01], mth.[FullTimeEmployees01], mth.[TotalEmployees01], mth.[GroupIndicator01], mth.[TransitionIndicator01]
		, mth.[MinCoverage02], mth.[FullTimeEmployees02], mth.[TotalEmployees02], mth.[GroupIndicator02], mth.[TransitionIndicator02]
		, mth.[MinCoverage03], mth.[FullTimeEmployees03], mth.[TotalEmployees03], mth.[GroupIndicator03], mth.[TransitionIndicator03]
		, mth.[MinCoverage04], mth.[FullTimeEmployees04], mth.[TotalEmployees04], mth.[GroupIndicator04], mth.[TransitionIndicator04]
		, mth.[MinCoverage05], mth.[FullTimeEmployees05], mth.[TotalEmployees05], mth.[GroupIndicator05], mth.[TransitionIndicator05]
		, mth.[MinCoverage06], mth.[FullTimeEmployees06], mth.[TotalEmployees06], mth.[GroupIndicator06], mth.[TransitionIndicator06]
		, mth.[MinCoverage07], mth.[FullTimeEmployees07], mth.[TotalEmployees07], mth.[GroupIndicator07], mth.[TransitionIndicator07]
		, mth.[MinCoverage08], mth.[FullTimeEmployees08], mth.[TotalEmployees08], mth.[GroupIndicator08], mth.[TransitionIndicator08]
		, mth.[MinCoverage09], mth.[FullTimeEmployees09], mth.[TotalEmployees09], mth.[GroupIndicator09], mth.[TransitionIndicator09]
		, mth.[MinCoverage10], mth.[FullTimeEmployees10], mth.[TotalEmployees10], mth.[GroupIndicator10], mth.[TransitionIndicator10]
		, mth.[MinCoverage11], mth.[FullTimeEmployees11], mth.[TotalEmployees11], mth.[GroupIndicator11], mth.[TransitionIndicator11]
		, mth.[MinCoverage12], mth.[FullTimeEmployees12], mth.[TotalEmployees12], mth.[GroupIndicator12], mth.[TransitionIndicator12]
		FROM [dbo].[tblEpHCEmployer] h
		LEFT JOIN
		(
			SELECT m.HeaderId		
			, MAX(CASE WHEN [PaMonth] = 1 THEN [MinCoverage] ELSE NULL END) AS [MinCoverage01]
			, MAX(CASE WHEN [PaMonth] = 1 THEN [FullTimeEmployees] ELSE NULL END) AS [FullTimeEmployees01]
			, MAX(CASE WHEN [PaMonth] = 1 THEN [TotalEmployees] ELSE NULL END) AS [TotalEmployees01]
			, MAX(CASE WHEN [PaMonth] = 1 THEN [GroupIndicator] ELSE NULL END) AS [GroupIndicator01]
			, MAX(CASE WHEN [PaMonth] = 1 THEN [TransitionIndicator] ELSE NULL END) AS [TransitionIndicator01]

			, MAX(CASE WHEN [PaMonth] = 2 THEN [MinCoverage] ELSE NULL END) AS [MinCoverage02]
			, MAX(CASE WHEN [PaMonth] = 2 THEN [FullTimeEmployees] ELSE NULL END) AS [FullTimeEmployees02]
			, MAX(CASE WHEN [PaMonth] = 2 THEN [TotalEmployees] ELSE NULL END) AS [TotalEmployees02]
			, MAX(CASE WHEN [PaMonth] = 2 THEN [GroupIndicator] ELSE NULL END) AS [GroupIndicator02]
			, MAX(CASE WHEN [PaMonth] = 2 THEN [TransitionIndicator] ELSE NULL END) AS [TransitionIndicator02]

			, MAX(CASE WHEN [PaMonth] = 3 THEN [MinCoverage] ELSE NULL END) AS [MinCoverage03]
			, MAX(CASE WHEN [PaMonth] = 3 THEN [FullTimeEmployees] ELSE NULL END) AS [FullTimeEmployees03]
			, MAX(CASE WHEN [PaMonth] = 3 THEN [TotalEmployees] ELSE NULL END) AS [TotalEmployees03]
			, MAX(CASE WHEN [PaMonth] = 3 THEN [GroupIndicator] ELSE NULL END) AS [GroupIndicator03]
			, MAX(CASE WHEN [PaMonth] = 3 THEN [TransitionIndicator] ELSE NULL END) AS [TransitionIndicator03]

			, MAX(CASE WHEN [PaMonth] = 4 THEN [MinCoverage] ELSE NULL END) AS [MinCoverage04]
			, MAX(CASE WHEN [PaMonth] = 4 THEN [FullTimeEmployees] ELSE NULL END) AS [FullTimeEmployees04]
			, MAX(CASE WHEN [PaMonth] = 4 THEN [TotalEmployees] ELSE NULL END) AS [TotalEmployees04]
			, MAX(CASE WHEN [PaMonth] = 4 THEN [GroupIndicator] ELSE NULL END) AS [GroupIndicator04]
			, MAX(CASE WHEN [PaMonth] = 4 THEN [TransitionIndicator] ELSE NULL END) AS [TransitionIndicator04]

			, MAX(CASE WHEN [PaMonth] = 5 THEN [MinCoverage] ELSE NULL END) AS [MinCoverage05]
			, MAX(CASE WHEN [PaMonth] = 5 THEN [FullTimeEmployees] ELSE NULL END) AS [FullTimeEmployees05]
			, MAX(CASE WHEN [PaMonth] = 5 THEN [TotalEmployees] ELSE NULL END) AS [TotalEmployees05]
			, MAX(CASE WHEN [PaMonth] = 5 THEN [GroupIndicator] ELSE NULL END) AS [GroupIndicator05]
			, MAX(CASE WHEN [PaMonth] = 5 THEN [TransitionIndicator] ELSE NULL END) AS [TransitionIndicator05]

			, MAX(CASE WHEN [PaMonth] = 6 THEN [MinCoverage] ELSE NULL END) AS [MinCoverage06]
			, MAX(CASE WHEN [PaMonth] = 6 THEN [FullTimeEmployees] ELSE NULL END) AS [FullTimeEmployees06]
			, MAX(CASE WHEN [PaMonth] = 6 THEN [TotalEmployees] ELSE NULL END) AS [TotalEmployees06]
			, MAX(CASE WHEN [PaMonth] = 6 THEN [GroupIndicator] ELSE NULL END) AS [GroupIndicator06]
			, MAX(CASE WHEN [PaMonth] = 6 THEN [TransitionIndicator] ELSE NULL END) AS [TransitionIndicator06]

			, MAX(CASE WHEN [PaMonth] = 7 THEN [MinCoverage] ELSE NULL END) AS [MinCoverage07]
			, MAX(CASE WHEN [PaMonth] = 7 THEN [FullTimeEmployees] ELSE NULL END) AS [FullTimeEmployees07]
			, MAX(CASE WHEN [PaMonth] = 7 THEN [TotalEmployees] ELSE NULL END) AS [TotalEmployees07]
			, MAX(CASE WHEN [PaMonth] = 7 THEN [GroupIndicator] ELSE NULL END) AS [GroupIndicator07]
			, MAX(CASE WHEN [PaMonth] = 7 THEN [TransitionIndicator] ELSE NULL END) AS [TransitionIndicator07]

			, MAX(CASE WHEN [PaMonth] = 8 THEN [MinCoverage] ELSE NULL END) AS [MinCoverage08]
			, MAX(CASE WHEN [PaMonth] = 8 THEN [FullTimeEmployees] ELSE NULL END) AS [FullTimeEmployees08]
			, MAX(CASE WHEN [PaMonth] = 8 THEN [TotalEmployees] ELSE NULL END) AS [TotalEmployees08]
			, MAX(CASE WHEN [PaMonth] = 8 THEN [GroupIndicator] ELSE NULL END) AS [GroupIndicator08]
			, MAX(CASE WHEN [PaMonth] = 8 THEN [TransitionIndicator] ELSE NULL END) AS [TransitionIndicator08]

			, MAX(CASE WHEN [PaMonth] = 9 THEN [MinCoverage] ELSE NULL END) AS [MinCoverage09]
			, MAX(CASE WHEN [PaMonth] = 9 THEN [FullTimeEmployees] ELSE NULL END) AS [FullTimeEmployees09]
			, MAX(CASE WHEN [PaMonth] = 9 THEN [TotalEmployees] ELSE NULL END) AS [TotalEmployees09]
			, MAX(CASE WHEN [PaMonth] = 9 THEN [GroupIndicator] ELSE NULL END) AS [GroupIndicator09]
			, MAX(CASE WHEN [PaMonth] = 9 THEN [TransitionIndicator] ELSE NULL END) AS [TransitionIndicator09]

			, MAX(CASE WHEN [PaMonth] = 10 THEN [MinCoverage] ELSE NULL END) AS [MinCoverage10]
			, MAX(CASE WHEN [PaMonth] = 10 THEN [FullTimeEmployees] ELSE NULL END) AS [FullTimeEmployees10]
			, MAX(CASE WHEN [PaMonth] = 10 THEN [TotalEmployees] ELSE NULL END) AS [TotalEmployees10]
			, MAX(CASE WHEN [PaMonth] = 10 THEN [GroupIndicator] ELSE NULL END) AS [GroupIndicator10]
			, MAX(CASE WHEN [PaMonth] = 10 THEN [TransitionIndicator] ELSE NULL END) AS [TransitionIndicator10]

			, MAX(CASE WHEN [PaMonth] = 11 THEN [MinCoverage] ELSE NULL END) AS [MinCoverage11]
			, MAX(CASE WHEN [PaMonth] = 11 THEN [FullTimeEmployees] ELSE NULL END) AS [FullTimeEmployees11]
			, MAX(CASE WHEN [PaMonth] = 11 THEN [TotalEmployees] ELSE NULL END) AS [TotalEmployees11]
			, MAX(CASE WHEN [PaMonth] = 11 THEN [GroupIndicator] ELSE NULL END) AS [GroupIndicator11]
			, MAX(CASE WHEN [PaMonth] = 11 THEN [TransitionIndicator] ELSE NULL END) AS [TransitionIndicator11]

			, MAX(CASE WHEN [PaMonth] = 12 THEN [MinCoverage] ELSE NULL END) AS [MinCoverage12]
			, MAX(CASE WHEN [PaMonth] = 12 THEN [FullTimeEmployees] ELSE NULL END) AS [FullTimeEmployees12]
			, MAX(CASE WHEN [PaMonth] = 12 THEN [TotalEmployees] ELSE NULL END) AS [TotalEmployees12]
			, MAX(CASE WHEN [PaMonth] = 12 THEN [GroupIndicator] ELSE NULL END) AS [GroupIndicator12]
			, MAX(CASE WHEN [PaMonth] = 12 THEN [TransitionIndicator] ELSE NULL END) AS [TransitionIndicator12]

			FROM [dbo].[tblEpHCEmployerMonth] m
			GROUP BY m.[HeaderId]
		) mth ON h.[ID] = mth.[HeaderId]
	WHERE h.[Status] = 0 AND h.[PaYear] = @PaYEAR --active entries for the payroll year

	--AGG - Other ALE Member of Aggregated ALE Group
	SELECT 'AGG' AS  [AUFTag]
		, m.[Name]
		, m.[EIN] --conditional decrypt in DataGenerator
		, m.[FullTimeEmployees]
	FROM [dbo].[tblEpHCEmployer] h
	INNER JOIN [dbo].[tblEpHCEmployerMember] m ON h.[ID] = m.[HeaderId]
	WHERE h.[Status] = 0 AND h.[PaYear] = @PaYear

	--DGE - Designated Government Entity
	SELECT 'DGE' AS  [AUFTag]
		, h.[Name1], h.[Name2]
		, h.[EIN] --Conditional decrypt in DataGenerator
		, h.[Address1], h.[Address2], h.[City]
		, CASE WHEN h.[Country] = 'USA' THEN h.[Region] ELSE NULL END AS [Region]
		, CASE WHEN h.[Country] = 'USA' THEN h.[PostalCode] ELSE NULL END AS [PostalCode]
		, h.[Country]
		, CASE WHEN h.[Country] = 'USA' THEN NULL ELSE h.[Region] END AS [NonUSRegion]
		, CASE WHEN h.[Country] = 'USA' THEN NULL ELSE h.[PostalCode] END AS [NonUSPostalCode]
		, CASE WHEN h.[Country] = 'USA' THEN NULL ELSE h.[Country] END AS [NonUSCountry]
		, h.[ContactFirstName], NULL AS [ContactMiddleName], h.[ContactLastName], NULL AS [ContactSuffix]
		, h.[Phone], h.[PhoneExt]
		FROM [dbo].[tblEpHCGovEntity] h
	WHERE h.[Status] = 0 AND h.[PaYear] = @PaYear

	--EMP - Employee
	Select 'EMP' as [AUFTag]
		, r.EmpNum as [ID]
		, m.FirstName
		, m.MiddleInit
		, m.LastName
		, null NameSuffix
		, m.SocialSecurityNo AS SocialSecurityNo --conditional decrypt in DataGenerator
		, m.AddressLine1
		, m.ResidentCity City
		, Null County
		, Null CountyCode
		, m.ResidentState as [State]
		, Case when Len(m.ZipCode)> 5 then Substring(m.ZipCode, 1, 5) + '-' + Substring(m.ZipCode, 6, Len(m.ZipCode)) else m.ZipCode end ZipCode
		, @Country as Country
		, null CountryCode 
		, null ForeignPostalCode
		, Case When e.Sex = 'F' Then 'X' Else '' End Female
		, null [Disabled]
		, ISNULL([AdjustedHireDate], [StartDate]) as [HireDate] --PET:270071
		, TerminationDate as [FireDate]
		, Null MedicalCoverageDate
		, m.BirthDate
		, Case When e.EmployeeType = 0 Then e.HourlyRate Else e.Salary End PayRate
		, sw.Exemptions
		, Case When e.EmployeeType = 1 Then 'S' Else 'H' End AS PayType
		, Case When e.EmployeeStatus = 0 Then 'X' Else null End Fulltime
		, e.JobTitle Title
		, sw.SUIState
		, lc.[Description] AS [WorkType]
		, Null HealthBenefits
		, m.PhoneNumber
		, Case When SeasonalEmployee = 1 Then 'X' Else null End Seasonal
		, Null WorkersCompClass
		, Null WorkersCompSubClass
		, sw.SUIState
		, sw.MaritalStatus
		, e.EmployeeId
		, Case When e.StatutoryEmployee = 1 Then 'X' Else null End StatutoryEmployee
		, Case When e.ParticipatingIn401k = 1 Then 'X' Else null End RetirementPlan
		, Null ThirdPartySickPay
		, Case When isnull(e.PayDistribution, 0) <> 0 Then 'X' Else null End DirectDeposit
		, m.AddressLine2
		, null as [Changed]
		, m.WorkEmail EmailAddress
		, null ElectronicW2
		, NULL NonUSStateProvince
		, NULL RehireDate
		, 'R' as [EmploymentCode] --'R','M''A''H''F''X'
		--Enter the complete occupational title or six-digit code for the position held by the employee. For AK employees only.
		, Case when m.ResidentState = 'AK' then e.LaborClass else  NULL end as FullOccupTitle
		-- Enter the two-digit geographic code of the last location the employee worked. For AK employees only.	
     	,  NULL as GeographicCode
     	,  NULL as PensionDate
		,  NULL as NationalIDNumber
			--Enter the internal ID for the employee. Internal use only. 2.3 version changes
		,  NULL as InternalID
		,  NULL CanadaPensionPlan
		,  NULL EmploymentInsuranceExempt
		,  NULL ProvParentalInsPlanExempt
		,  sw.Exemptions as StateExemptions
		, Case e.EeoClass When 1 then 'A' when 2 then 'B' when 3 then 'H' when 5 then 'N' when 6 then 'P' when 7 then '0' else 'C' end as Ethnicity
		, @CompNum as [PID]	
		, e.EmployeeId AS [SortText]
	From dbo.tblPaEmployee e Inner Join dbo.tblSmEmployee m on m.EmployeeId = e.EmployeeId
		inner Join #EmpRef r on e.EmployeeId = r.EmployeeId
		Left Join dbo.tblPaLaborClass lc on e.LaborClass = lc.Id 
		Left Join 
		(
			Select w.EmployeeId, w.SuiState, w.Exemptions, w.MaritalStatus 
				From dbo.tblPaEmpWithhold w
				Inner Join
				(
					Select EmployeeId, min(Id) Id From dbo.tblPaEmpWithhold Where DefaultWH = 1 and SUIState Is Not NULL and PaYear = @PaYEAR Group By EmployeeId
				) wid On w.EmployeeId = wid.EmployeeId and w.Id = wid.Id
		) sw on e.EmployeeId = sw.EmployeeId 	
	Order By e.EmployeeId

	--GEN - Employee General information
	Select 'GEN' as [AUFTag]
		, fed.[PaDate] AS [EntryDate]
		, SUM(fed.[GrossPayAmount]) AS [GrossPay]
		, SUM(fed.[NetPayAmount]) AS [NetPay]
		, SUM(ISNULL(fed.[SSEarnings], 0) - ISNULL(fed.[FicaTips], 0)) AS [SSWages]
		, SUM(fed.[SSWithheld]) AS [SSWithheld]
		, SUM(fed.[MEDEarnings]) AS [MedWages]
		, SUM(fed.[MEDWithheld]) AS [MedWithheld]
		, SUM(fed.[FEDEarnings]) AS [FedWages]
		, SUM(fed.[FEDWithheld]) AS [FedWithheld]
		, SUM(fed.[FUTAEarnings]) AS [TaxableFUTAWages]
		, SUM(-fed.[EICWithheld]) AS [EIC]
		, SUM(fed.[FicaTips]) AS [SSTips]
		, SUM(fed.[FUTAWithheld]) AS [FUTALiability]
		, SUM(fed.[FUTAGrossEarnings]) AS [TotalFUTAWages]
		, pd.[StartDate] AS [PayPeriodStartDate]
		, pd.[EndDate] AS [PayPeriodEndDate]
		, SUM(fed.[EOAWithheld]) AS [SSEmployerMatch]
		, SUM(fed.[EMEWithheld]) AS [MedicareEmplrMatch]
		, 0 AS [AdditionalMedicareTax]
		, SUM(fed.[AdditionalMedicareWages]) AS AdditionalMedicareWages
		, r.[EmpNum] AS [PID]
	From #EmpFederal fed
	Inner Join #PdDate pd on pd.[PaYear] = fed.[PaYear] And pd.[PaMonth] = fed.[PaMonth]
	Inner Join #EmpRef r on fed.EmployeeId = r.EmployeeId
	Group By r.[EmpNum], pd.[StartDate], pd.[EndDate], fed.[PaDate]

	--ESI - Employee State Items
	Select 'ESI' AS [AUFTag]
		, amt.[State]
		, amt.[PaDate] AS [EntryDate]
		, p.PIMID
		, amt.[GrossEarnings] AS [TotalWagesTips]
		, amt.[WithholdEarnings] AS [TaxableWagesTips]
		, NULL AS [Tips]
		, amt.[WithholdAmount] AS [Amount]
		, ms.[HoursWorked] AS [Hours]
		, 0 AS [Days]
		, ms.[WeeksWorked] AS [Weeks]
		, pd.[StartDate] AS [PayPeriodStartDate]
		, pd.[EndDate] AS [PayPeriodEndDate]
		, 0.00 AS [Commissions]
		, 0.00 AS [Allowances]
		, NULL AS [AccountNumber] --Enter the account identification number. Use this only if it varies by employee. Otherwise, use PIM-7. version 2.12.
		, r.[EmpNum] AS [PID]
	From 
	(
		Select [EmployeeId], [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid]
			, SUM([GrossEarnings]) AS [GrossEarnings]
			, SUM([WithholdEarnings]) AS [WithholdEarnings]
			, SUM([WithholdAmount]) AS [WithholdAmount]
		From #EmpStateLocal
		Group By [EmployeeId], [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid]
	) amt
	Inner Join #EmpRef r on amt.[EmployeeId] = r.[EmployeeId]
	Inner Join #PdDate pd on pd.[PaYear] = amt.[PaYear] and pd.[PaMonth] = amt.[PaMonth]
	Left Join 
	(
		Select [EmployeeId], [PaYear], [PaMonth], [PaDate]
			, Sum([HoursWorked]) AS [HoursWorked] 
			, SUM([WeeksWorked]) AS [WeeksWorked]
		From #EmpMisc
		Group By [EmployeeId], [PaYear], [PaMonth], [PaDate]
	) ms on ms.[EmployeeId] = amt.[EmployeeId] and ms.[PaYear] = amt.[PaYear] And ms.[PaMonth] = amt.[PaMonth] And ms.[PaDate] = amt.[PaDate]
	Inner Join (Select [PIMID], [State], [Code], [EmployerPaid], [TaxType], [LocalCode] FROM #PIMTaxInfo Where [AufType] <> 2) p  --state and fed auf types only
		on amt.[State] = p.[State] And amt.[Code] = p.[Code] And p.[EmployerPaid] = amt.[EmployerPaid] And ISNULL(p.[LocalCode], '') = ISNULL(amt.[Local], '')

	--ELI - Employee Local Items
	Select 'ELI' AS [AUFTag]
		, amt.[State]
		, amt.[PaDate] AS [EntryDate]
		, p.PIMID
		, 0 AS [TotalWagesTips]
		, amt.[WithholdEarnings] AS [TaxableWagesTips]
		, NULL AS [Tips]
		, amt.[WithholdAmount] AS [Amount]
		, 0 AS [Hours]
		, NULL AS [Days]
		, 0 AS [Weeks]
		, NULL AS [PayPeriodStartDate]
		, NULL AS [PayPeriodEndDate]
		, NULL AS [AccountNumber] --Enter the account identification number. Use this only if it varies by employee. Otherwise, use PIM-7. version 2.12.
		, r.[EmpNum] AS [PID]
	From 
	(
		Select [EmployeeId], [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid]
			, SUM([GrossEarnings]) AS [GrossEarnings]
			, SUM([WithholdEarnings]) AS [WithholdEarnings]
			, SUM([WithholdAmount]) AS [WithholdAmount]
		From #EmpStateLocal
		Group By [EmployeeId], [PaYear], [PaMonth], [PaDate], [State], [Local], [Code], [EmployerPaid]
	) amt
	Inner Join #EmpRef r on amt.[EmployeeId] = r.[EmployeeId]
	Inner Join (Select [PIMID], [State], [Code], [EmployerPaid], [TaxType], [LocalCode] FROM #PIMTaxInfo Where [AufType] = 2) p  --local auf types only
		on amt.[State] = p.[State] And amt.[Code] = p.[Code] And amt.[EmployerPaid] = p.[EmployerPaid] And ISNULL(p.[LocalCode], '') = ISNULL(amt.[Local], '')
	--Where p.[EmployerPaid] = 0
	--Note:Employee paid filtering removed to enable all data to be submitted to Aatrix, PIM Id mapping can be removed to exclude data if needed

	--ECV - Employee Coverage Information
	SELECT 'ECV' AS  [AUFTag]
		, r.EmpNum AS [PID]
		, h.[ElectronicOnly]
		, h.[PolicyOrigin]
		, h.[SelfInsured]
		, NULL as [PlanStartMonth]
		, mth.[CoverageCode01], mth.[CoveragePremium01], mth.[SafeHarborCode01]
		, mth.[CoverageCode02], mth.[CoveragePremium02], mth.[SafeHarborCode02]
		, mth.[CoverageCode03], mth.[CoveragePremium03], mth.[SafeHarborCode03]
		, mth.[CoverageCode04], mth.[CoveragePremium04], mth.[SafeHarborCode04]
		, mth.[CoverageCode05], mth.[CoveragePremium05], mth.[SafeHarborCode05]
		, mth.[CoverageCode06], mth.[CoveragePremium06], mth.[SafeHarborCode06]
		, mth.[CoverageCode07], mth.[CoveragePremium07], mth.[SafeHarborCode07]
		, mth.[CoverageCode08], mth.[CoveragePremium08], mth.[SafeHarborCode08]
		, mth.[CoverageCode09], mth.[CoveragePremium09], mth.[SafeHarborCode09]
		, mth.[CoverageCode10], mth.[CoveragePremium10], mth.[SafeHarborCode10]
		, mth.[CoverageCode11], mth.[CoveragePremium11], mth.[SafeHarborCode11]
		, mth.[CoverageCode12], mth.[CoveragePremium12], mth.[SafeHarborCode12]
		FROM [dbo].[tblEpHCEmployee] h
		INNER JOIN #EmpRef r ON h.[EmployeeId] = r.[EmployeeId]
		LEFT JOIN 
		(
			--return null instad of $0.00 for codes 1A, 1F, 1G, 1H and 1I per 2015 IRS requirements
			SELECT m.[HeaderId]
				, MAX(CASE WHEN m.[PaMonth] = 1 AND m.[CodeType] = 0 THEN [Code] ELSE NULL END) AS [CoverageCode01]
				, SUM(CASE WHEN m.[PaMonth] = 1 AND m.[CodeType] = 0 AND NOT([Premium] = 0 AND [Code] in ('1A', '1F', '1G', '1H', '1J', '1K')) THEN [Premium] ELSE NULL END) AS [CoveragePremium01]
				, MAX(CASE WHEN m.[PaMonth] = 1 AND m.[CodeType] = 1 THEN [Code] ELSE NULL END) AS [SafeHarborCode01]

				, MAX(CASE WHEN m.[PaMonth] = 2 AND m.[CodeType] = 0 THEN [Code] ELSE NULL END) AS [CoverageCode02]
				, SUM(CASE WHEN m.[PaMonth] = 2 AND m.[CodeType] = 0 AND NOT([Premium] = 0 AND [Code] in ('1A', '1F', '1G', '1H', '1J', '1K')) THEN [Premium] ELSE NULL END) AS [CoveragePremium02]
				, MAX(CASE WHEN m.[PaMonth] = 2 AND m.[CodeType] = 1 THEN [Code] ELSE NULL END) AS [SafeHarborCode02]

				, MAX(CASE WHEN m.[PaMonth] = 3 AND m.[CodeType] = 0 THEN [Code] ELSE NULL END) AS [CoverageCode03]
				, SUM(CASE WHEN m.[PaMonth] = 3 AND m.[CodeType] = 0 AND NOT([Premium] = 0 AND [Code] in ('1A', '1F', '1G', '1H', '1J', '1K')) THEN [Premium] ELSE NULL END) AS [CoveragePremium03]
				, MAX(CASE WHEN m.[PaMonth] = 3 AND m.[CodeType] = 1 THEN [Code] ELSE NULL END) AS [SafeHarborCode03]

				, MAX(CASE WHEN m.[PaMonth] = 4 AND m.[CodeType] = 0 THEN [Code] ELSE NULL END) AS [CoverageCode04]
				, SUM(CASE WHEN m.[PaMonth] = 4 AND m.[CodeType] = 0 AND NOT([Premium] = 0 AND [Code] in ('1A', '1F', '1G', '1H', '1J', '1K')) THEN [Premium] ELSE NULL END) AS [CoveragePremium04]
				, MAX(CASE WHEN m.[PaMonth] = 4 AND m.[CodeType] = 1 THEN [Code] ELSE NULL END) AS [SafeHarborCode04]

				, MAX(CASE WHEN m.[PaMonth] = 5 AND m.[CodeType] = 0 THEN [Code] ELSE NULL END) AS [CoverageCode05]
				, SUM(CASE WHEN m.[PaMonth] = 5 AND m.[CodeType] = 0 AND NOT([Premium] = 0 AND [Code] in ('1A', '1F', '1G', '1H', '1J', '1K')) THEN [Premium] ELSE NULL END) AS [CoveragePremium05]
				, MAX(CASE WHEN m.[PaMonth] = 5 AND m.[CodeType] = 1 THEN [Code] ELSE NULL END) AS [SafeHarborCode05]

				, MAX(CASE WHEN m.[PaMonth] = 6 AND m.[CodeType] = 0 THEN [Code] ELSE NULL END) AS [CoverageCode06]
				, SUM(CASE WHEN m.[PaMonth] = 6 AND m.[CodeType] = 0 AND NOT([Premium] = 0 AND [Code] in ('1A', '1F', '1G', '1H', '1J', '1K')) THEN [Premium] ELSE NULL END) AS [CoveragePremium06]
				, MAX(CASE WHEN m.[PaMonth] = 6 AND m.[CodeType] = 1 THEN [Code] ELSE NULL END) AS [SafeHarborCode06]

				, MAX(CASE WHEN m.[PaMonth] = 7 AND m.[CodeType] = 0 THEN [Code] ELSE NULL END) AS [CoverageCode07]
				, SUM(CASE WHEN m.[PaMonth] = 7 AND m.[CodeType] = 0 AND NOT([Premium] = 0 AND [Code] in ('1A', '1F', '1G', '1H', '1J', '1K')) THEN [Premium] ELSE NULL END) AS [CoveragePremium07]
				, MAX(CASE WHEN m.[PaMonth] = 7 AND m.[CodeType] = 1 THEN [Code] ELSE NULL END) AS [SafeHarborCode07]

				, MAX(CASE WHEN m.[PaMonth] = 8 AND m.[CodeType] = 0 THEN [Code] ELSE NULL END) AS [CoverageCode08]
				, SUM(CASE WHEN m.[PaMonth] = 8 AND m.[CodeType] = 0 AND NOT([Premium] = 0 AND [Code] in ('1A', '1F', '1G', '1H', '1J', '1K')) THEN [Premium] ELSE NULL END) AS [CoveragePremium08]
				, MAX(CASE WHEN m.[PaMonth] = 8 AND m.[CodeType] = 1 THEN [Code] ELSE NULL END) AS [SafeHarborCode08]

				, MAX(CASE WHEN m.[PaMonth] = 9 AND m.[CodeType] = 0 THEN [Code] ELSE NULL END) AS [CoverageCode09]
				, SUM(CASE WHEN m.[PaMonth] = 9 AND m.[CodeType] = 0 AND NOT([Premium] = 0 AND [Code] in ('1A', '1F', '1G', '1H', '1J', '1K')) THEN [Premium] ELSE NULL END) AS [CoveragePremium09]
				, MAX(CASE WHEN m.[PaMonth] = 9 AND m.[CodeType] = 1 THEN [Code] ELSE NULL END) AS [SafeHarborCode09]

				, MAX(CASE WHEN m.[PaMonth] = 10 AND m.[CodeType] = 0 THEN [Code] ELSE NULL END) AS [CoverageCode10]
				, SUM(CASE WHEN m.[PaMonth] = 10 AND m.[CodeType] = 0 AND NOT([Premium] = 0 AND [Code] in ('1A', '1F', '1G', '1H', '1J', '1K')) THEN [Premium] ELSE NULL END) AS [CoveragePremium10]
				, MAX(CASE WHEN m.[PaMonth] = 10 AND m.[CodeType] = 1 THEN [Code] ELSE NULL END) AS [SafeHarborCode10]

				, MAX(CASE WHEN m.[PaMonth] = 11 AND m.[CodeType] = 0 THEN [Code] ELSE NULL END) AS [CoverageCode11]
				, SUM(CASE WHEN m.[PaMonth] = 11 AND m.[CodeType] = 0 AND NOT([Premium] = 0 AND [Code] in ('1A', '1F', '1G', '1H', '1J', '1K')) THEN [Premium] ELSE NULL END) AS [CoveragePremium11]
				, MAX(CASE WHEN m.[PaMonth] = 11 AND m.[CodeType] = 1 THEN [Code] ELSE NULL END) AS [SafeHarborCode11]

				, MAX(CASE WHEN m.[PaMonth] = 12 AND m.[CodeType] = 0 THEN [Code] ELSE NULL END) AS [CoverageCode12]
				, SUM(CASE WHEN m.[PaMonth] = 12 AND m.[CodeType] = 0 AND NOT([Premium] = 0 AND [Code] in ('1A', '1F', '1G', '1H', '1J', '1K')) THEN [Premium] ELSE NULL END) AS [CoveragePremium12]
				, MAX(CASE WHEN m.[PaMonth] = 12 AND m.[CodeType] = 1 THEN [Code] ELSE NULL END) AS [SafeHarborCode12]

				FROM [dbo].[tblEpHCEmployeeMonth] m
				GROUP BY m.[HeaderId]
		) mth ON h.[Id] = mth.[HeaderId]
	WHERE h.[PaYear] = @PaYear

	--ECI - Employee Covered Individual
	SELECT 'ECI' AS  [AUFTag]
		, CASE WHEN c.[SSN] = e.[SocialSecurityNo] THEN 0 ELSE 1 END [SortOrder] --Employee should be listed first
		, r.[EmpNum] AS [PID]
		, c.[SSN] --Conditional decrypt in DataGenerator
		, c.[BirthDate]
		, c.[FirstName]
		, c.[MiddleInit]
		, c.[LastName]
		, NULL AS [Suffix]
		, c.[MonthFlag] --12 character positional flag of Y/N values for each month
		FROM [dbo].[tblEpHCEmployee] h
		INNER JOIN #EmpRef r ON h.[EmployeeId] = r.[EmployeeId]
		INNER JOIN [dbo].[tblEpHCEmployeeCoverage] c ON h.[ID] = c.[HeaderId]
		INNER JOIN [dbo].[tblSmEmployee] e ON h.[EmployeeId] = e.[EmployeeId]
	WHERE h.[PaYear] = @PaYear
		AND h.[SelfInsured] = 1 --only include self-insured employees

	--OCP - Other Coverage Provider
	SELECT 'OCP' AS  [AUFTag]
		, r.[EmpNum] AS [PID]
		, p.[Name1]
		, p.[Name2]
		, p.[EIN] --Conditional decrypt in DataGenerator
		, p.[Address1]
		, p.[Address2]
		, p.[City]
		, CASE WHEN p.[Country] = 'USA' THEN p.[Region] ELSE NULL END AS [Region]
		, CASE WHEN p.[Country] = 'USA' THEN p.[PostalCode] ELSE NULL END AS [PostalCode]
		, CASE WHEN p.[Country] = 'USA' THEN NULL ELSE p.[Region] END AS [NonUSRegion]
		, CASE WHEN p.[Country] = 'USA' THEN NULL ELSE p.[PostalCode] END AS [NonUSPostalCode]
		, p.[Country]
		, CASE WHEN p.[Country] = 'USA' THEN NULL ELSE p.[Country] END AS [NonUSCountry]
		, p.[Phone]
		, p.[PhoneExt]
		FROM [dbo].[tblEpHCEmployee] h
		INNER JOIN #EmpRef r ON h.[EmployeeId] = r.[EmployeeId]
		INNER JOIN [dbo].[tblEpHCEmployeeProviderInfo] p ON h.[ID] = p.[HeaderId]
	WHERE h.[PaYear] = @PaYear AND (NULLIF(p.[Name1], '') IS NOT NULL OR NULLIF(p.[EIN], '') IS NOT NULL) --ignore 'blank' child records


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_EpAatrixAUFData_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_EpAatrixAUFData_proc';

