
CREATE PROCEDURE dbo.trav_DbCmOpportunityProjections_proc
@UserId pUserID = '', 
@WksDate datetime = NULL

--PET:http://webfront:801/view.php?id=239725

AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #Opportunity
	(
		TargetDate datetime, 
		Value pDecimal, 
		WeightedValue pDecimal
	)

	CREATE TABLE #OpportunityTot
	(
		ValueMonth1 pDecimal DEFAULT(0),
		ValueMonth2 pDecimal DEFAULT(0),
		ValueMonth3 pDecimal DEFAULT(0),
		ValueMonth4 pDecimal DEFAULT(0),
		ValueMonth5 pDecimal DEFAULT(0),
		ValueMonth6 pDecimal DEFAULT(0),
		ValueMonth7 pDecimal DEFAULT(0),
		ValueMonth8 pDecimal DEFAULT(0),
		ValueMonth9 pDecimal DEFAULT(0),
		ValueMonth10 pDecimal DEFAULT(0),
		ValueMonth11 pDecimal DEFAULT(0),
		ValueMonth12 pDecimal DEFAULT(0),
		ValueMonthUnknown pDecimal DEFAULT(0), 
		WeightedValueMonth1 pDecimal DEFAULT(0),
		WeightedValueMonth2 pDecimal DEFAULT(0),
		WeightedValueMonth3 pDecimal DEFAULT(0),
		WeightedValueMonth4 pDecimal DEFAULT(0),
		WeightedValueMonth5 pDecimal DEFAULT(0),
		WeightedValueMonth6 pDecimal DEFAULT(0),
		WeightedValueMonth7 pDecimal DEFAULT(0),
		WeightedValueMonth8 pDecimal DEFAULT(0),
		WeightedValueMonth9 pDecimal DEFAULT(0),
		WeightedValueMonth10 pDecimal DEFAULT(0),
		WeightedValueMonth11 pDecimal DEFAULT(0),
		WeightedValueMonth12 pDecimal DEFAULT(0),
		WeightedValueMonthUnknown pDecimal DEFAULT(0)
	)

	DECLARE @FiscalYear smallint, @Period smallint
	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	DECLARE @BeginMonth1 datetime, @EndMonth1 datetime, @BeginMonth2 datetime, @EndMonth2 datetime, 
		@BeginMonth3 datetime, @EndMonth3 datetime, @BeginMonth4 datetime, @EndMonth4 datetime, 
		@BeginMonth5 datetime, @EndMonth5 datetime, @BeginMonth6 datetime, @EndMonth6 datetime, 
		@BeginMonth7 datetime, @EndMonth7 datetime, @BeginMonth8 datetime, @EndMonth8 datetime, 
		@BeginMonth9 datetime, @EndMonth9 datetime, @BeginMonth10 datetime, @EndMonth10 datetime, 
		@BeginMonth11 datetime, @EndMonth11 datetime, @BeginMonth12 datetime, @EndMonth12 datetime, 
		@MonthUnknown datetime

	SELECT @BeginMonth1 = BegDate FROM dbo.tblSmPeriodConversion 
		WHERE @WksDate BETWEEN BegDate AND EndDate
	SELECT @EndMonth1 = DATEADD(mm, 1, @BeginMonth1) - 1
	SELECT @BeginMonth2 = DATEADD(DAY, 1, @EndMonth1)
	SELECT @EndMonth2 = DATEADD(mm, 1, @BeginMonth2) - 1
	SELECT @BeginMonth3 = DATEADD(dd, 1, @EndMonth2)
	SELECT @EndMonth3 = DATEADD(mm, 1, @BeginMonth3) - 1
	SELECT @BeginMonth4 = DATEADD(dd, 1, @EndMonth3)
	SELECT @EndMonth4 = DATEADD(mm, 1, @BeginMonth4) - 1
	SELECT @BeginMonth5 = DATEADD(dd, 1, @EndMonth4)
	SELECT @EndMonth5 = DATEADD(mm, 1, @BeginMonth5) - 1
	SELECT @BeginMonth6 = DATEADD(dd, 1, @EndMonth5)
	SELECT @EndMonth6 = DATEADD(mm, 1, @BeginMonth6) - 1
	SELECT @BeginMonth7 = DATEADD(dd, 1, @EndMonth6)
	SELECT @EndMonth7 = DATEADD(mm, 1, @BeginMonth7) - 1
	SELECT @BeginMonth8 = DATEADD(dd, 1, @EndMonth7)
	SELECT @EndMonth8 = DATEADD(mm, 1, @BeginMonth8) - 1
	SELECT @BeginMonth9 = DATEADD(dd, 1, @EndMonth8)
	SELECT @EndMonth9 = DATEADD(mm, 1, @BeginMonth9) - 1
	SELECT @BeginMonth10 = DATEADD(dd, 1, @EndMonth9)
	SELECT @EndMonth10 = DATEADD(mm, 1, @BeginMonth10) - 1
	SELECT @BeginMonth11 = DATEADD(dd, 1, @EndMonth10)
	SELECT @EndMonth11 = DATEADD(mm, 1, @BeginMonth11) - 1
	SELECT @BeginMonth12 = DATEADD(dd, 1, @EndMonth11)
	SELECT @EndMonth12 = DATEADD(mm, 1, @BeginMonth12) - 1

	INSERT INTO #Opportunity (Value, WeightedValue, TargetDate)
		SELECT CAST(SUM(Value) AS float) AS Value
			, CAST(SUM((Value * ISNULL(ProbPct, 0)) / 100.0) AS float) AS WeightedValue
			, TargetDate 
		FROM dbo.tblCmOpportunity o LEFT JOIN dbo.tblCmOppProbCode p ON o.ProbCodeID = p.ID 
		WHERE [Status] <> 1 AND CloseDate IS NULL AND ((UserID = @UserId) OR (@UserId = '')) GROUP BY TargetDate

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO #Opportunity (Value, WeightedValue, TargetDate)
			VALUES (0, 0, '')
	END

	INSERT INTO #OpportunityTot (ValueMonth1, ValueMonth2, ValueMonth3, ValueMonth4, ValueMonth5, ValueMonth6
					, ValueMonth7, ValueMonth8, ValueMonth9, ValueMonth10, ValueMonth11, ValueMonth12
					, ValueMonthUnknown, WeightedValueMonth1, WeightedValueMonth2, WeightedValueMonth3
					, WeightedValueMonth4, WeightedValueMonth5, WeightedValueMonth6, WeightedValueMonth7
					, WeightedValueMonth8, WeightedValueMonth9, WeightedValueMonth10, WeightedValueMonth11
					, WeightedValueMonth12, WeightedValueMonthUnknown)
		SELECT SUM(CASE WHEN TargetDate <= @EndMonth1 THEN Value ELSE 0 END) AS ValueMonth1
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth2 AND @EndMonth2 THEN Value ELSE 0 END) AS ValueMonth2
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth3 AND @EndMonth3 THEN Value ELSE 0 END) AS ValueMonth3
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth4 AND @EndMonth4 THEN Value ELSE 0 END) AS ValueMonth4
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth5 AND @EndMonth5 THEN Value ELSE 0 END) AS ValueMonth5
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth6 AND @EndMonth6 THEN Value ELSE 0 END) AS ValueMonth6
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth7 AND @EndMonth7 THEN Value ELSE 0 END) AS ValueMonth7
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth8 AND @EndMonth8 THEN Value ELSE 0 END) AS ValueMonth8
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth9 AND @EndMonth9 THEN Value ELSE 0 END) AS ValueMonth9
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth10 AND @EndMonth10 THEN Value ELSE 0 END) AS ValueMonth10
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth11 AND @EndMonth11 THEN Value ELSE 0 END) AS ValueMonth11
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth12 AND @EndMonth12 THEN Value ELSE 0 END) AS ValueMonth12
			, SUM(CASE WHEN TargetDate > @EndMonth12 THEN Value ELSE 0 END) AS ValueMonthUnknown
			, SUM(CASE WHEN TargetDate <= @EndMonth1 THEN WeightedValue ELSE 0 END) AS WeightedValueMonth1
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth2 AND @EndMonth2 THEN WeightedValue ELSE 0 END) AS WeightedValueMonth2
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth3 AND @EndMonth3 THEN WeightedValue ELSE 0 END) AS WeightedValueMonth3
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth4 AND @EndMonth4 THEN WeightedValue ELSE 0 END) AS WeightedValueMonth4
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth5 AND @EndMonth5 THEN WeightedValue ELSE 0 END) AS WeightedValueMonth5
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth6 AND @EndMonth6 THEN WeightedValue ELSE 0 END) AS WeightedValueMonth6
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth7 AND @EndMonth7 THEN WeightedValue ELSE 0 END) AS WeightedValueMonth7
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth8 AND @EndMonth8 THEN WeightedValue ELSE 0 END) AS WeightedValueMonth8
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth9 AND @EndMonth9 THEN WeightedValue ELSE 0 END) AS WeightedValueMonth9
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth10 AND @EndMonth10 THEN WeightedValue ELSE 0 END) AS WeightedValueMonth10
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth11 AND @EndMonth11 THEN WeightedValue ELSE 0 END) AS WeightedValueMonth11
			, SUM(CASE WHEN TargetDate BETWEEN @BeginMonth12 AND @EndMonth12 THEN WeightedValue ELSE 0 END) AS WeightedValueMonth12
			, SUM(CASE WHEN TargetDate > @EndMonth12 THEN WeightedValue ELSE 0 END) AS WeightedValueMonthUnknown
		FROM #Opportunity

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO #OpportunityTot (ValueMonth1, ValueMonth2, ValueMonth3, ValueMonth4, ValueMonth5, ValueMonth6
						, ValueMonth7, ValueMonth8, ValueMonth9, ValueMonth10, ValueMonth11, ValueMonth12
						, ValueMonthUnknown, WeightedValueMonth1, WeightedValueMonth2, WeightedValueMonth3
						, WeightedValueMonth4, WeightedValueMonth5, WeightedValueMonth6, WeightedValueMonth7
						, WeightedValueMonth8, WeightedValueMonth9, WeightedValueMonth10, WeightedValueMonth11
						, WeightedValueMonth12, WeightedValueMonthUnknown) 
			VALUES (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	END

	SELECT DATENAME(mm, @BeginMonth1) AS Month0, DATENAME(yyyy, @BeginMonth1) AS Year0, DATENAME(mm, @BeginMonth1) + ' ' + DATENAME(yyyy, @BeginMonth1) AS Expected0, @BeginMonth1 AS Date0, ValueMonth1 AS ValueMonth0, WeightedValueMonth1 AS WeightedValueMonth0
		, DATENAME(mm, @BeginMonth2) AS Month1, DATENAME(yyyy, @BeginMonth2) AS Year1, DATENAME(mm, @BeginMonth2) + ' ' + DATENAME(yyyy, @BeginMonth2) AS Expected1, @BeginMonth2 AS Date1, ValueMonth2 AS ValueMonth1, WeightedValueMonth2 AS WeightedValueMonth1
		, DATENAME(mm, @BeginMonth3) AS Month2, DATENAME(yyyy, @BeginMonth3) AS Year2, DATENAME(mm, @BeginMonth3) + ' ' + DATENAME(yyyy, @BeginMonth3) AS Expected2, @BeginMonth3 AS Date2, ValueMonth3 AS ValueMonth2, WeightedValueMonth3 AS WeightedValueMonth2
		, DATENAME(mm, @BeginMonth4) AS Month3, DATENAME(yyyy, @BeginMonth4) AS Year3, DATENAME(mm, @BeginMonth4) + ' ' + DATENAME(yyyy, @BeginMonth4) AS Expected3, @BeginMonth4 AS Date3, ValueMonth4 AS ValueMonth3, WeightedValueMonth4 AS WeightedValueMonth3
		, DATENAME(mm, @BeginMonth5) AS Month4, DATENAME(yyyy, @BeginMonth5) AS Year4, DATENAME(mm, @BeginMonth5) + ' ' + DATENAME(yyyy, @BeginMonth5) AS Expected4, @BeginMonth5 AS Date4, ValueMonth5 AS ValueMonth4, WeightedValueMonth5 AS WeightedValueMonth4
		, DATENAME(mm, @BeginMonth6) AS Month5, DATENAME(yyyy, @BeginMonth6) AS Year5, DATENAME(mm, @BeginMonth6) + ' ' + DATENAME(yyyy, @BeginMonth6) AS Expected5, @BeginMonth6 AS Date5, ValueMonth6 AS ValueMonth5, WeightedValueMonth6 AS WeightedValueMonth5
		, DATENAME(mm, @BeginMonth7) AS Month6, DATENAME(yyyy, @BeginMonth7) AS Year6, DATENAME(mm, @BeginMonth7) + ' ' + DATENAME(yyyy, @BeginMonth7) AS Expected6, @BeginMonth7 AS Date6, ValueMonth7 AS ValueMonth6, WeightedValueMonth7 AS WeightedValueMonth6
		, DATENAME(mm, @BeginMonth8) AS Month7, DATENAME(yyyy, @BeginMonth8) AS Year7, DATENAME(mm, @BeginMonth8) + ' ' + DATENAME(yyyy, @BeginMonth8) AS Expected7, @BeginMonth8 AS Date7, ValueMonth8 AS ValueMonth7, WeightedValueMonth8 AS WeightedValueMonth7
		, DATENAME(mm, @BeginMonth9) AS Month8, DATENAME(yyyy, @BeginMonth9) AS Year8, DATENAME(mm, @BeginMonth9) + ' ' + DATENAME(yyyy, @BeginMonth9) AS Expected8, @BeginMonth9 AS Date8, ValueMonth9 AS ValueMonth8, WeightedValueMonth9 AS WeightedValueMonth8
		, DATENAME(mm, @BeginMonth10) AS Month9, DATENAME(yyyy, @BeginMonth10) AS Year9, DATENAME(mm, @BeginMonth10) + ' ' + DATENAME(yyyy, @BeginMonth10) AS Expected9, @BeginMonth10 AS Date9, ValueMonth10 AS ValueMonth9, WeightedValueMonth10 AS WeightedValueMonth9
		, DATENAME(mm, @BeginMonth11) AS Month10, DATENAME(yyyy, @BeginMonth11) AS Year10, DATENAME(mm, @BeginMonth11) + ' ' + DATENAME(yyyy, @BeginMonth11) AS Expected10, @BeginMonth11 AS Date10, ValueMonth11 AS ValueMonth10, WeightedValueMonth11 AS WeightedValueMonth10
		, DATENAME(mm, @BeginMonth12) AS Month11, DATENAME(yyyy, @BeginMonth12) AS Year11, DATENAME(mm, @BeginMonth12) + ' ' + DATENAME(yyyy, @BeginMonth12) AS Expected11, @BeginMonth12 AS Date11, ValueMonth12 AS ValueMonth11, WeightedValueMonth12 AS WeightedValueMonth11
		, 'Unknown', '', '', NULL, ValueMonthUnknown, WeightedValueMonthUnknown 
	FROM #OpportunityTot

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbCmOpportunityProjections_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbCmOpportunityProjections_proc';

