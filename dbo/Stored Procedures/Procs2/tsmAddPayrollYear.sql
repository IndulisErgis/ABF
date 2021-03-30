
CREATE PROCEDURE [dbo].[tsmAddPayrollYear]
@Year smallint, @YearFrom smallint,@PayrollTaxDB nvarchar(20)='ST',@IncludeTerminatedEmp bit = 0
AS
DECLARE @TranCount smallint,@MaxId INT,@MaxIdBig BIGINT,@sql nvarchar(MAX)
SET NOCOUNT ON
SET @TranCount = @@TranCount
IF @trancount = 0
	BEGIN TRAN trnAddPayrollYear


IF @IncludeTerminatedEmp = 0--When terminated employees are not considered for copying
BEGIN
	--mark employees with a termination date prior to the most recent payroll year as Inactive
	UPDATE dbo.tblSmEmployee SET [Status] = 1
	FROM dbo.tblPaEmployee y
	WHERE dbo.tblSmEmployee.EmployeeId = y.EmployeeId
		AND dbo.tblSmEmployee.[Status] = 0
		AND y.[TerminationDate] Is Not Null
		AND YEAR(y.[TerminationDate]) < @Year
END


	
--tblPaEmpDeduct
IF NOT EXISTS (SELECT TOP 1 * FROM dbo.tblPaEmpDeduct WHERE PaYear=@Year)
BEGIN
	INSERT INTO dbo.tblPaEmpDeduct (EmployeeId,PaYear,DeductionCodeId,SeqNum,PeriodCode1,
	PeriodCode2,PeriodCode3,PeriodCode4,PeriodCode5,ScheduledAmount,Balance,UseFactorFlag,
	OverrideFactor1,OverrideFactor2,OverrideFactor3,OverrideFactor4,OverrideFactor5,OverrideFactor6,
	OverrideFactor7, OverrideFactor8, OverrideFactor9, OverrideFactor10, OverrideFactor11,
    OverrideFactor12, OverrideFactor13, OverrideFactor14,OverrideFactor15, OverrideFactor16,
    OverrideFactor17, OverrideFactor18, OverrideFactor19, OverrideFactor20,
	CalcOnGross,FormulaId,CF) 
	SELECT d.EmployeeId,@Year,DeductionCodeId,SeqNum,PeriodCode1,
	PeriodCode2,PeriodCode3,PeriodCode4,PeriodCode5,ScheduledAmount,Balance,UseFactorFlag,
	OverrideFactor1,OverrideFactor2,OverrideFactor3,OverrideFactor4,OverrideFactor5,OverrideFactor6,
	OverrideFactor7, OverrideFactor8, OverrideFactor9, OverrideFactor10, OverrideFactor11,
    OverrideFactor12, OverrideFactor13, OverrideFactor14,OverrideFactor15, OverrideFactor16,
    OverrideFactor17, OverrideFactor18, OverrideFactor19, OverrideFactor20,
	CalcOnGross,FormulaId, d.CF 
	FROM dbo.tblPaEmpDeduct d 
	INNER JOIN dbo.tblSmEmployee e on d.EmployeeId = e.EmployeeId
	WHERE PaYear = @YearFrom AND e.[Status] IN (0/*active employees*/,@IncludeTerminatedEmp)
	IF @@ERROR != 0 GOTO ErrorTrap
END


--tblPaEmpValidEarnCode
IF NOT EXISTS (SELECT TOP 1 * FROM dbo.tblPaEmpValidEarnCode WHERE PaYear=@Year)
BEGIN
	INSERT INTO dbo.tblPaEmpValidEarnCode (EmployeeId,PaYear,EarnCodeId,RateType,Rate) 
	SELECT d.EmployeeId,@Year,EarnCodeId,RateType,Rate 
	FROM dbo.tblPaEmpValidEarnCode  d 
	INNER JOIN dbo.tblSmEmployee e on d.EmployeeId = e.EmployeeId
	WHERE PaYear = @YearFrom AND e.[Status] IN (0/*active employees*/,@IncludeTerminatedEmp)
	IF @@ERROR != 0 GOTO ErrorTrap
END

--tblPaInfoUnempRep
IF NOT EXISTS (SELECT TOP 1 * FROM dbo.tblPaInfoUnempRep WHERE PaYear=@Year)
BEGIN
	INSERT INTO dbo.tblPaInfoUnempRep (PaYear,[State],FieldNumberOfSsn,FieldNumberOfName,
	FieldNumberOfTotalWages,FieldNumberOfExcessWage,FieldNumberOfTaxWages,FieldNumberOfWksWorked,
	FieldNumberOfHrsWorked,SuiMonth,PrinZeroEarnFlag,SortByFlag,CF) SELECT @Year,[State],FieldNumberOfSsn,
	FieldNumberOfName,FieldNumberOfTotalWages,FieldNumberOfExcessWage,FieldNumberOfTaxWages,
	FieldNumberOfWksWorked,FieldNumberOfHrsWorked,SuiMonth,PrinZeroEarnFlag,SortByFlag,CF 
	FROM dbo.tblPaInfoUnempRep WHERE PaYear = @YearFrom
	IF @@ERROR != 0 GOTO ErrorTrap
END


--tblPaFormulaTableYear and tblPaFormulaTableDetail
IF NOT EXISTS (SELECT TOP 1 * FROM dbo.tblPaFormulaTableYear WHERE PaYear=@Year)
BEGIN

	--Create a temp table to store new FormulaTableYearId and source FormulaTableYearId
		create table #tempPaFormulaTableYear
			(
				[SourceFormulaTableYearId] [int],
				[NewFormulaTableYearId] [int],
			)
		
	--Set Max Id + Row Number as primary key
	select @MaxId =MAX(Id) from dbo.tblPaFormulaTableYear
	
	 --Generate new FormulaTableYearId  for the new PaYear 
	 INSERT INTO #tempPaFormulaTableYear (SourceFormulaTableYearId,NewFormulaTableYearId) SELECT Id,
	 ROW_NUMBER() OVER (ORDER BY Id)+ @MaxId	 FROM dbo.tblPaFormulaTableYear
	 WHERE PaYear = @YearFrom
	
    --Copy tblPaFormulaTableYear
	INSERT INTO dbo.tblPaFormulaTableYear (Id,FormulaTableId,PaYear,ColumnHdr,ColumnHdr1,ColumnHdr2,ColumnHdr3,
	ColumnHdr4,ColumnHdr5,ColumnHdr6,ColumnHdr7,CF) SELECT  NewFormulaTableYearId,FormulaTableId,@Year,ColumnHdr,ColumnHdr1,
	ColumnHdr2,ColumnHdr3,ColumnHdr4,ColumnHdr5,ColumnHdr6,ColumnHdr7,CF FROM dbo.tblPaFormulaTableYear F  INNER JOIN
	#tempPaFormulaTableYear T on F.Id = T.SourceFormulaTableYearId
	IF @@ERROR != 0 GOTO ErrorTrap
	
	--Copy tblPaFormulaTableDetail
	INSERT INTO dbo.tblPaFormulaTableDetail (FormulaTableYearId,SequenceNumber,Column1,Column2,Column3,Column4,Column5,Column6,
	Column7,Column8,Column9,Column10,GradientYn,CF) SELECT  NewFormulaTableYearId,SequenceNumber,Column1,Column2,Column3,
	Column4,Column5,Column6,Column7,Column8,Column9,Column10,GradientYn,CF FROM dbo.tblPaFormulaTableDetail D INNER JOIN
	#tempPaFormulaTableYear T on D.FormulaTableYearId = T.SourceFormulaTableYearId
	IF @@ERROR != 0 GOTO ErrorTrap
END


--tblPaEmpWithhold 
    IF NOT EXISTS (SELECT TOP 1 * FROM dbo.tblPaEmpWithhold WHERE PaYear=@Year)
    BEGIN
        	--Create a temp table to store new Emp WH id and source EMP WH id 
        	--This temp table is used for tblPaEmpOverrideFactors,tblPaEmpExclude
			create table #tempEmpWithhold
			(
				[SourceEmpWHId] [int],
				[NewEmpWHId] [int],
			)
		
			--Set Max Id + Row Number as primary key
			select @MaxId =MAX(Id) from dbo.tblPaEmpWithhold
	
			 --Generate new Emp WH id  for the new PaYear 
			INSERT INTO #tempEmpWithhold (SourceEmpWHId,NewEmpWHId)
			SELECT Id ,ROW_NUMBER() OVER (ORDER BY Id)+ @MaxId 
			FROM dbo.tblPaEmpWithhold d 
			INNER JOIN dbo.tblSmEmployee e on d.EmployeeId = e.EmployeeId
			WHERE PaYear = @YearFrom AND e.[Status] IN (0/*active employees*/,@IncludeTerminatedEmp)
			
		--Copy tblPaEmpWithhold
		INSERT INTO dbo.tblPaEmpWithhold (Id,EmployeeId,PaYear,TaxAuthorityId,MaritalStatus,Exemptions,
		ExtraWithholding,FixedWithholding,HomeState,DefaultWH,SUIState,EICCode,CF) 
		SELECT NewEmpWHId,EmployeeId, @Year ,TaxAuthorityId,MaritalStatus,Exemptions,ExtraWithholding,
		FixedWithholding,HomeState,DefaultWH,SUIState,case when EICCode is null then null else 'N' end,CF FROM dbo.tblPaEmpWithhold W INNER JOIN
		#tempEmpWithhold T on W.Id = T.SourceEmpWHId
		IF @@ERROR != 0 GOTO ErrorTrap  
	END
	
--tblPaTaxAuthorityDetail 
IF NOT EXISTS (SELECT TOP 1 * FROM dbo.tblPaTaxAuthorityDetail WHERE PaYear=@Year)
BEGIN	    
	--Create a temp table to store new tax detail id and source tax detail id 
	--This temp table is used for copying
	--tblPaEmpOverrideFactors,tblPaEmpExclude,tblPaTaxAuthorityExclusionDeduction
	--and tblPaTaxAuthorityExclusionEarning
	create table #tempTaxAuthorityDetail
	(
		[SourceTaxDetailId] [int],
		[NewTaxDetailId] [int],
	)
		
    --Set Max Id + Row Number as primary key
	select @MaxId =MAX(Id) from dbo.tblPaTaxAuthorityDetail
	
    --Generate new tax detail id for the new PaYear 
	INSERT INTO #tempTaxAuthorityDetail (SourceTaxDetailId,NewTaxDetailId)
	SELECT Id ,ROW_NUMBER() OVER (ORDER BY Id)+ @MaxId from dbo.tblPaTaxAuthorityDetail
	WHERE PaYear = @YearFrom	

   --Copy tblPaTaxAuthorityDetail 
	INSERT INTO dbo.tblPaTaxAuthorityDetail (Id,TaxAuthorityId,PaYear,Code,EmployerPaid,Description,FormulaId,
	CodeType,GlLiabilityAccount,TaxId,FixedPercent,EmplrExpenseAcct,WeeksWorkedLimit,TaxType,CF) 
	SELECT NewTaxDetailId,TaxAuthorityId,@Year,Code,EmployerPaid,Description,FormulaId,CodeType,GlLiabilityAccount,
	TaxId,FixedPercent,EmplrExpenseAcct,WeeksWorkedLimit,TaxType,CF FROM dbo.tblPaTaxAuthorityDetail D INNER JOIN 
	#tempTaxAuthorityDetail T on D.Id = T.SourceTaxDetailId	
    IF @@ERROR != 0 GOTO ErrorTrap	
END

--tblPaEmpOverrideFactors 
IF (OBJECT_ID('tempdb..#tempEmpWithhold','u') IS NOT NULL) 
AND  (OBJECT_ID('tempdb..#tempTaxAuthorityDetail','u') IS NOT NULL)
BEGIN		
		INSERT INTO dbo.tblPaEmpOverrideFactors(WithholdId,TaxAuthorityDtlId,OverrideFactor1,OverrideFactor2,
		OverrideFactor3,OverrideFactor4,OverrideFactor5,OverrideFactor6,
	    OverrideFactor7, OverrideFactor8, OverrideFactor9, OverrideFactor10, OverrideFactor11,
        OverrideFactor12, OverrideFactor13, OverrideFactor14,OverrideFactor15, OverrideFactor16,
        OverrideFactor17, OverrideFactor18, OverrideFactor19, OverrideFactor20)
		SELECT E.NewEmpWHId,T.NewTaxDetailId,O.OverrideFactor1,O.OverrideFactor2,O.OverrideFactor3,
		O.OverrideFactor4,O.OverrideFactor5,O.OverrideFactor6,
		O.OverrideFactor7, O.OverrideFactor8, O.OverrideFactor9, O.OverrideFactor10, O.OverrideFactor11,
		O.OverrideFactor12, O.OverrideFactor13, O.OverrideFactor14,O.OverrideFactor15, O.OverrideFactor16,
		O.OverrideFactor17, O.OverrideFactor18, O.OverrideFactor19, O.OverrideFactor20 
		FROM dbo.tblPaEmpOverrideFactors O INNER JOIN
		#tempTaxAuthorityDetail T ON O.TaxAuthorityDtlId = T.SourceTaxDetailId INNER JOIN
		#tempEmpWithhold  E ON O.WithholdId = E.SourceEmpWHId	
		IF @@ERROR != 0 GOTO ErrorTrap	
END

--tblPaEmpExclude
IF (OBJECT_ID('tempdb..#tempEmpWithhold','u') IS NOT NULL) 
AND  (OBJECT_ID('tempdb..#tempTaxAuthorityDetail','u') IS NOT NULL)
BEGIN		
		INSERT INTO dbo.tblPaEmpExclude(WithholdId,TaxAuthorityDtlId)
		SELECT W.NewEmpWHId,D.NewTaxDetailId FROM dbo.tblPaEmpExclude X INNER JOIN
		#tempTaxAuthorityDetail D ON X.TaxAuthorityDtlId = D.SourceTaxDetailId INNER JOIN
		#tempEmpWithhold  W ON X.WithholdId = W.SourceEmpWHId	
		IF @@ERROR != 0 GOTO ErrorTrap	
END

--tblPaTaxAuthorityExclusionDeduction
IF (OBJECT_ID('tempdb..#tempTaxAuthorityDetail','u') IS NOT NULL)
BEGIN		
		INSERT INTO dbo.tblPaTaxAuthorityExclusionDeduction(TaxAuthorityDtlId,DeductionCodeId)
		SELECT D.NewTaxDetailId,X.DeductionCodeId FROM dbo.tblPaTaxAuthorityExclusionDeduction X 
		INNER JOIN #tempTaxAuthorityDetail D ON X.TaxAuthorityDtlId = D.SourceTaxDetailId
		IF @@ERROR != 0 GOTO ErrorTrap	
END

--tblPaTaxAuthorityExclusionEarning
IF (OBJECT_ID('tempdb..#tempTaxAuthorityDetail','u') IS NOT NULL)
BEGIN		
		INSERT INTO tblPaTaxAuthorityExclusionEarning(TaxAuthorityDtlId,EarningCodeId)
		SELECT D.NewTaxDetailId,X.EarningCodeId FROM dbo.tblPaTaxAuthorityExclusionEarning X 
		INNER JOIN #tempTaxAuthorityDetail D ON X.TaxAuthorityDtlId = D.SourceTaxDetailId
		IF @@ERROR != 0 GOTO ErrorTrap	
END

--tblPaEmpHistLeave
IF NOT EXISTS (SELECT TOP 1 * FROM tblPaEmpHistLeave WHERE PaYear=@Year)
BEGIN
	INSERT INTO dbo.tblPaEmpHistLeave(EntryDate, PaYear, PaMonth, EmployeeId, LeaveCodeId, PrintedFlag, [From],
	EarningCode, [Description], CheckNumber, AdjustmentDate, 
	AdjustmentAmount, CF)
	SELECT EntryDate, @Year, PaMonth, d.EmployeeId, LeaveCodeId, PrintedFlag, [From],
	EarningCode, [Description], CheckNumber, AdjustmentDate, 
	AdjustmentAmount, d.CF 
	FROM dbo.tblPaEmpHistLeave  d 
	INNER JOIN dbo.tblSmEmployee e on d.EmployeeId = e.EmployeeId
	WHERE PaYear = @YearFrom AND e.[Status] IN (0/*active employees*/,@IncludeTerminatedEmp)
	IF @@ERROR != 0 GOTO ErrorTrap
END

--tblPaFormulaYear
IF NOT EXISTS (SELECT TOP 1 * FROM dbo.tblPaFormulaYear WHERE PaYear=@Year)
BEGIN
	INSERT INTO dbo.tblPaFormulaYear (FormulaId,PaYear,TableId,OverrideFactor1,OverrideFactor2,
	OverrideFactor3,OverrideFactor4,OverrideFactor5,OverrideFactor6,OverrideFactor7,OverrideFactor8, 
    OverrideFactor9,OverrideFactor10,OverrideFactor11,OverrideFactor12,OverrideFactor13,
    OverrideFactor14,OverrideFactor15,OverrideFactor16,OverrideFactor17,OverrideFactor18,
    OverrideFactor19, OverrideFactor20,FormulaText,CF) 
    SELECT FormulaId,@Year,TableId,OverrideFactor1,OverrideFactor2,
    OverrideFactor3,OverrideFactor4,OverrideFactor5,OverrideFactor6,OverrideFactor7,OverrideFactor8, 
    OverrideFactor9,OverrideFactor10,OverrideFactor11,OverrideFactor12,OverrideFactor13,
    OverrideFactor14,OverrideFactor15,OverrideFactor16,OverrideFactor17,OverrideFactor18,
    OverrideFactor19, OverrideFactor20,FormulaText,CF 
	FROM dbo.tblPaFormulaYear WHERE PaYear = @YearFrom
	IF @@ERROR != 0 GOTO ErrorTrap
END

--tblEpHCGovEntity
IF NOT EXISTS (SELECT TOP 1 * FROM dbo.tblEpHCGovEntity WHERE PaYear=@Year)
BEGIN
	 --Get Max Id 
	SELECT @MaxIdBig  =MAX(ID) FROM  dbo.tblEpHCGovEntity

	 --Set Max Id + Row Number as primary key
	INSERT INTO dbo.tblEpHCGovEntity ( ID, PaYear, [Status], EIN,
    Name1, Name2, Address1, Address2, City, Region, 
	Country, PostalCode, ContactFirstName, ContactLastName, Phone, PhoneExt, CF) 
	SELECT  ROW_NUMBER() OVER (ORDER BY ID)+ @MaxIdBig, @Year, [Status], EIN,
    Name1, Name2, Address1, Address2, City, Region, 
	Country, PostalCode, ContactFirstName, ContactLastName, Phone, PhoneExt, CF
	FROM  dbo.tblEpHCGovEntity WHERE PaYear = @YearFrom
	IF @@ERROR != 0 GOTO ErrorTrap
END

--tblEpHCEmployer
IF NOT EXISTS (SELECT TOP 1 * FROM dbo.tblEpHCEmployer WHERE PaYear=@Year)
BEGIN
	--Create a temp table to store new id and source id 
	--This temp table is used for copying
	--tblEpHCEmployerMonth,tblEpHCEmployerMember

	CREATE TABLE #tempEpHCEmployer
	(
		[SourceId] BIGINT,
		[NewId] BIGINT,
	)
		
    --Set Max Id + Row Number as primary key
	SELECT @MaxIdBig  =MAX(Id) FROM dbo.tblEpHCEmployer
	
    --Generate new id for the new PaYear 
	INSERT INTO #tempEpHCEmployer (SourceId,[NewId])
	SELECT Id ,ROW_NUMBER() OVER (ORDER BY Id)+ @MaxIdBig from dbo.tblEpHCEmployer
	WHERE PaYear = @YearFrom	

   --Copy tblEpHCEmployer 
	INSERT INTO dbo.tblEpHCEmployer (ID, PaYear, [Status], GovEntity, ALEGroup, SelfInsured, QualifyingOfferMethod,
    QOMTransitionRelief, [4980HTransitionRelief], [98PctOfferMethod], CF) 
	SELECT T.[NewId], @Year, [Status], GovEntity, ALEGroup, SelfInsured, QualifyingOfferMethod,
    QOMTransitionRelief, [4980HTransitionRelief], [98PctOfferMethod], CF
     FROM dbo.tblEpHCEmployer e 
	 INNER JOIN  #tempEpHCEmployer t on e.ID = t.SourceId	

	IF @@ERROR != 0 GOTO ErrorTrap
END

--tblEpHCEmployerMonth
IF (OBJECT_ID('tempdb..#tempEpHCEmployer','u') IS NOT NULL)
BEGIN		
		 --Get Max Id 
	    SELECT @MaxIdBig = MAX(ID) FROM  dbo.tblEpHCEmployerMonth

		INSERT INTO dbo.tblEpHCEmployerMonth( ID, HeaderId, PaMonth, MinCoverage, FullTimeEmployees, 
		TotalEmployees, GroupIndicator, TransitionIndicator, CF)
		SELECT  ROW_NUMBER() OVER (ORDER BY ID)+ @MaxIdBig, t.[NewId], PaMonth, MinCoverage, FullTimeEmployees, 
		TotalEmployees, GroupIndicator, TransitionIndicator, CF 
		FROM dbo.tblEpHCEmployerMonth m 
		INNER JOIN #tempEpHCEmployer t ON m.HeaderId = t.SourceId
		IF @@ERROR != 0 GOTO ErrorTrap	
END

--tblEpHCEmployerMember
IF (OBJECT_ID('tempdb..#tempEpHCEmployer','u') IS NOT NULL)
BEGIN		
		 --Get Max Id 
	    SELECT @MaxIdBig = MAX(ID) FROM  dbo.tblEpHCEmployerMember

		INSERT INTO dbo.tblEpHCEmployerMember( ID, HeaderId, Name, EIN, FullTimeEmployees, CF)
		SELECT  ROW_NUMBER() OVER (ORDER BY ID)+ @MaxIdBig, t.[NewId],Name, EIN, FullTimeEmployees, CF
		FROM dbo.tblEpHCEmployerMember m 
		INNER JOIN #tempEpHCEmployer t ON m.HeaderId = t.SourceId
		IF @@ERROR != 0 GOTO ErrorTrap	
END

--tblEpHCEmployee
IF NOT EXISTS (SELECT TOP 1 * FROM dbo.tblEpHCEmployee WHERE PaYear=@Year)
BEGIN
	--Create a temp table to store new id and source id 
	--This temp table is used for copying
	--tblEpHCEmployeeMonth,tblEpHCEmployeeCoverage,tblEpHCEmployeeProviderInfo

	CREATE TABLE #tempEpHCEmployee
	(
		[SourceId] BIGINT,
		[NewId] BIGINT,
	)
		
    --Set Max Id + Row Number as primary key
	SELECT @MaxIdBig  =MAX(Id) FROM dbo.tblEpHCEmployee
	
    --Generate new id for the new PaYear 
	INSERT INTO #tempEpHCEmployee (SourceId,[NewId])
	SELECT Id ,ROW_NUMBER() OVER (ORDER BY Id)+ @MaxIdBig
	FROM dbo.tblEpHCEmployee h 
    INNER JOIN dbo.tblSmEmployee e on h.EmployeeId = e.EmployeeId
    WHERE PaYear = @YearFrom AND e.[Status] IN (0/*active employees*/,@IncludeTerminatedEmp)

   --Copy tblEpHCEmployee 
	INSERT INTO dbo.tblEpHCEmployee (ID, PaYear, EmployeeId, ElectronicOnly, PolicyOrigin, SelfInsured, CF) 
	SELECT T.[NewId], @Year, EmployeeId, ElectronicOnly, PolicyOrigin, SelfInsured, CF
	 FROM dbo.tblEpHCEmployee e 
	 INNER JOIN 
	#tempEpHCEmployee t on e.ID = t.SourceId	

	IF @@ERROR != 0 GOTO ErrorTrap
END

--tblEpHCEmployeeMonth
IF (OBJECT_ID('tempdb..#tempEpHCEmployee','u') IS NOT NULL)
BEGIN		
		 --Get Max Id 
	    SELECT @MaxIdBig = MAX(ID) FROM  dbo.tblEpHCEmployeeMonth

		INSERT INTO dbo.tblEpHCEmployeeMonth( ID, HeaderId, PaMonth, CodeType, Code, Premium, CF)
		SELECT  ROW_NUMBER() OVER (ORDER BY ID)+ @MaxIdBig, t.[NewId],PaMonth, CodeType, Code, Premium, CF
		FROM dbo.tblEpHCEmployeeMonth m 
		INNER JOIN #tempEpHCEmployee t ON m.HeaderId = t.SourceId
		IF @@ERROR != 0 GOTO ErrorTrap	
END

--tblEpHCEmployeeProviderInfo
IF (OBJECT_ID('tempdb..#tempEpHCEmployee','u') IS NOT NULL)
BEGIN		
		 --Get Max Id 
	    SELECT @MaxIdBig = MAX(ID) FROM  dbo.tblEpHCEmployeeProviderInfo

		INSERT INTO dbo.tblEpHCEmployeeProviderInfo( ID, HeaderId, EIN, Name1, Name2, Address1, Address2,
		 City, Region, Country, PostalCode, Phone, PhoneExt,CF)
		SELECT  ROW_NUMBER() OVER (ORDER BY ID)+ @MaxIdBig, t.[NewId],EIN, Name1, Name2, Address1, Address2,
		 City, Region, Country, PostalCode, Phone, PhoneExt,CF
		FROM dbo.tblEpHCEmployeeProviderInfo p 
		INNER JOIN #tempEpHCEmployee t ON p.HeaderId = t.SourceId
		IF @@ERROR != 0 GOTO ErrorTrap	
END

--tblEpHCEmployeeCoverage
IF (OBJECT_ID('tempdb..#tempEpHCEmployee','u') IS NOT NULL)
BEGIN		
		 --Get Max Id 
	    SELECT @MaxIdBig = MAX(ID) FROM  dbo.tblEpHCEmployeeCoverage

		INSERT INTO dbo.tblEpHCEmployeeCoverage( ID, HeaderId, LastName, FirstName,
		 MiddleInit, BirthDate, SSN, MonthFlag,CF)
		SELECT  ROW_NUMBER() OVER (ORDER BY ID)+ @MaxIdBig, t.[NewId],LastName, FirstName,
		 MiddleInit, BirthDate, SSN, MonthFlag,CF
		FROM dbo.tblEpHCEmployeeCoverage p 
		INNER JOIN #tempEpHCEmployee t ON p.HeaderId = t.SourceId
		IF @@ERROR != 0 GOTO ErrorTrap	
END

--tblPaSTLocalStatusCode in Payroll Tax DB
SET @sql = 'IF NOT EXISTS (SELECT TOP 1 * FROM  ['+@PayrollTaxDB+'].dbo.tblPaSTLocalStatusCode WHERE PaYear= @Year)
BEGIN
	INSERT INTO ['+@PayrollTaxDB+'].dbo.tblPaSTLocalStatusCode(PaYear, StateCode, LocalCode, StatusCode, Descr)
	SELECT @Year, StateCode, LocalCode, StatusCode, Descr 
	FROM  ['+@PayrollTaxDB+'].dbo.tblPaSTLocalStatusCode
	WHERE PaYear = @YearFrom
END'

Exec sp_executesql @sql, N'@Year smallint, @YearFrom smallint',  @Year, @YearFrom
IF @@ERROR != 0 GOTO ErrorTrap

IF @trancount = 0
	COMMIT TRAN trnAddPayrollYear

RETURN 0
ERRORTrap:
	IF @trancount = 0 ROLLBACK TRAN trnAddPayrollYear
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'tsmAddPayrollYear';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'tsmAddPayrollYear';

