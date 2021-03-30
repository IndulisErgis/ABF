CREATE PROCEDURE [dbo].[trav_HRDOLRpt_proc]
@DateFrom DATETIME,
@DateThru DATETIME,
@SpecStat BIT

AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @ActiveAsOfDate DATETIME = GETDATE()

	CREATE TABLE #IndividualList (IndId [dbo].[pEmpID] NOT NULL)
	INSERT INTO #IndividualList SELECT DISTINCT ind.IndId FROM tblHrIndGenInfo ind

	CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @ActiveAsOfDate

	CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID BIGINT NULL,[IndStatus] TINYINT NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @ActiveAsOfDate, 0 -- 0:All individuals (Active and Inactive)

	--
	CREATE TABLE #TempIndividual(IndId [dbo].[pEmpID])
	IF (@SpecStat = 0)
	BEGIN
		INSERT INTO #TempIndividual
		SELECT DISTINCT ind.IndId FROM #IndividualList ind
		INNER JOIN tblHrIndGenInfo g ON ind.IndId = g.IndId
		INNER JOIN tblHrIndStatus s ON ind.IndId = s.IndId
		INNER JOIN tblHrIndPosition ip ON ind.IndId = ip.IndId
		INNER JOIN tblHrPosition p ON p.ID = ip.PositionID
		INNER JOIN #IndStatus ins ON ins.IndId = s.IndId AND ins.StatusID = s.ID
		INNER JOIN #IndPositionID tip ON tip.IndId = ip.IndId AND tip.PositionID = ip.ID
		WHERE ((@DateFrom IS NULL OR g.StartDate >= @DateFrom) AND (@DateThru IS NULL OR g.StartDate <= @DateThru))
		AND p.SpecialStatus = 0
	END
	ELSE
	BEGIN
		INSERT INTO #TempIndividual
		SELECT DISTINCT ind.IndId FROM #IndividualList ind
		INNER JOIN tblHrIndGenInfo g ON g.IndId = ind.IndId
		INNER JOIN tblHrIndStatus s ON ind.IndId = s.IndId
		INNER JOIN tblHrIndPosition ip ON ind.IndId = ip.IndId
		INNER JOIN tblHrPosition p ON p.ID = ip.PositionID
		INNER JOIN #IndStatus ins ON ins.IndId = s.IndId AND ins.StatusID = s.ID
		INNER JOIN #IndPositionID tip ON tip.IndId = ip.IndId AND tip.PositionID = ip.ID
		WHERE ((@DateFrom IS NULL OR g.StartDate >= @DateFrom) AND (@DateThru IS NULL OR g.StartDate <= @DateThru))
	END

	CREATE TABLE #tmpEEO 
		(GroupId NVARCHAR(40),
		EEOJobCatDescr NVARCHAR(40),
		Gender NVARCHAR(40),
		Ethnicity NVARCHAR(40),
		Total pDec)
	
	CREATE TABLE #tmpStatus (IndStatus BIGINT)
	CREATE TABLE #tmpIndId (IndId pEmpId)
	DECLARE @GroupId NVARCHAR(40)
	DECLARE @Cnt TINYINT

	SET @Cnt = 0

	WHILE @Cnt < 5
	BEGIN
	
		DELETE FROM #tmpStatus
		DELETE FROM #tmpIndId
	
		IF @Cnt = 0 
			BEGIN
			SET @GroupId = N'Hires'
			INSERT INTO #tmpStatus (IndStatus) SELECT 24
			INSERT INTO #tmpStatus (IndStatus) SELECT 25
			END

		IF @Cnt = 1 
			BEGIN
			SET @GroupId = N'Terminations'
			INSERT INTO #tmpStatus (IndStatus) SELECT 29
			INSERT INTO #tmpStatus (IndStatus) SELECT 26
			END	

		IF @Cnt = 2 
			BEGIN
			SET @GroupId = N'Hires Part Time'
			INSERT INTO #tmpStatus (IndStatus) SELECT 25
			END	

		IF @Cnt = 3 
			BEGIN
			SET @GroupId = N'Hires Full Time'
			INSERT INTO #tmpStatus (IndStatus) SELECT 24
			END	

		IF @Cnt = 4
			BEGIN
			SET @GroupId = N'Promotions'
			END	

		IF @Cnt <=3 
			BEGIN
			INSERT INTO #tmpIndId (IndId)
			SELECT IndId 
			FROM dbo.tblHRIndStatus s
			INNER JOIN dbo.tblHRTypeCode t ON s.IndStatusTypeCodeID = t.ID AND t.TableID = 18
			INNER JOIN #tmpStatus x ON t.StandardID = x.IndStatus
			GROUP BY s.IndId
			END

		IF @Cnt = 4
			BEGIN
			INSERT INTO #tmpIndId (IndId)
			SELECT IndId 
			FROM dbo.tblHRIndPosition p 
			INNER JOIN tblHrTypeCode t ON t.ID = p.ChangeReasonTypeCodeID
			WHERE t.StandardID = 61 -- PositionChangeReason Promotions
			GROUP BY IndId
			END

		INSERT INTO #tmpEEO (GroupId, EEOJobCatDescr, Gender, Ethnicity, Total)
		SELECT @GroupId GroupId,
		tps3.[Description] EEOJobCatDescr,
		tps2.[Description] Gender,
		tps1.[Description] Ethnicity,
		Sum(1) Total
		FROM #TempIndividual x
		INNER JOIN #tmpIndId z ON x.IndId = z.IndId
		INNER JOIN #IndPositionID tip ON tip.IndId = z.IndId
		INNER JOIN dbo.tblHRIndGenInfo g ON x.IndId = g.IndId
		INNER JOIN tblHrIndPosition ip ON ip.ID = tip.PositionID
		INNER JOIN tblHrPosition p ON p.ID = ip.PositionID
		INNER JOIN tblHrJobTitle t ON p.JobTypeCodeID = t.ID
		LEFT JOIN dbo.tblHRTypeCode ethnic ON g.EthnicityTypeCodeID = ethnic.ID AND ethnic.TableID = 8 --TableType.Ethnicity
		LEFT JOIN dbo.tblHRTypeCode sex ON g.GenderTypeCodeID = sex.ID AND sex.TableID = 16 --TableType.Gender
		LEFT JOIN dbo.tblHrTypeCode cat ON t.JobCatTypeCodeID = cat.ID AND cat.TableID = 19 --TableType.JobCategory
		LEFT JOIN #TableTypeCodeStandard tps1 ON tps1.Id = ethnic.StandardID AND ethnic.TableID = 8
		LEFT JOIN #TableTypeCodeStandard tps2 ON tps2.Id = sex.StandardID AND sex.TableID = 16
		LEFT JOIN #TableTypeCodeStandard tps3 ON tps3.Id = cat.StandardID AND cat.TableID = 19
		WHERE CASE WHEN @Cnt = 1 OR @Cnt = 4 THEN 1 ELSE CASE WHEN ((@DateFrom IS NULL OR @DateFrom <= g.StartDate) AND (@DateThru IS NULL OR @DateThru >= g.StartDate)) THEN 1 ELSE 0 END END = 1
		GROUP BY 
		tps3.[Description] ,
		tps2.[Description] ,
		tps1.[Description]

		SET @Cnt = @Cnt + 1
	
	END

	SELECT GroupId, EEOJobCatDescr, Gender, Ethnicity, Total FROM #tmpEEO

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRDOLRpt_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRDOLRpt_proc';

