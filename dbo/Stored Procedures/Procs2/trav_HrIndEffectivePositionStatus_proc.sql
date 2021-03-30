CREATE PROCEDURE dbo.trav_HrIndEffectivePositionStatus_proc
@PositionId BIGINT,
@EffectiveDate DATETIME,
@Status TINYINT = 1 --Enum:0;All;1;Active;2;Inactive   Use 1 by default

AS
SET NOCOUNT ON
BEGIN TRY
	
	--Create #IndividualList temp table (to identify possible individuals)
	CREATE TABLE #IndividualList
	( 
		[IndId] [dbo].[pEmpId] NOT NULL 
		PRIMARY KEY CLUSTERED ([IndID])
	)

	--Create #CurrentPosition (to capture the results of trav_HrIndEffectivePosition_proc)
	CREATE TABLE #CurrentPosition 
	(
		[IndId] [pEmpId],
		[IndPositionID] [bigint]
	)

	--Create #ActiveIndividual (to capture the results of trav_HRIndEffectiveStatus_proc)
	CREATE TABLE #ActiveIndividual 
	(
		[IndId] [pEmpId],
		[IndStatusID] [bigint],
		[IndStatus] [bigint]
	)

	--Populate #IndividualList from tblHrIndPosition for the identified position id where the StartDate is null or <= effectiveDate
	INSERT INTO #IndividualList (IndId) 
	(SELECT DISTINCT ig.IndId
		FROM tblHrPosition p 
		INNER JOIN tblHrIndPosition ip ON p.ID = ip.PositionID
		INNER JOIN tblHrIndGenInfo ig ON ig.IndId = ip.IndId
		WHERE PositionID = @PositionID 
		AND ISNULL(ip.StartDate,@EffectiveDate) <= @EffectiveDate)

	INSERT INTO #CurrentPosition ([IndId], [IndPositionID])
	Exec dbo.trav_HrIndEffectivePosition_proc @EffectiveDate

	INSERT INTO #ActiveIndividual ([IndId], [IndStatusID], [IndStatus])
	Exec dbo.trav_HrIndEffectiveStatus_proc @EffectiveDate, @Status

	SELECT TOP 1 p.IndId, p.IndPositionID, s.IndStatusID, s.IndStatus FROM #CurrentPosition p
	INNER JOIN #ActiveIndividual s ON p.IndId = s.IndId
	INNER JOIN tblHrIndPosition ip ON ip.ID = p.IndPositionID
	INNER JOIN tblHrPosition ps ON ps.ID = ip.PositionID
	WHERE ps.ID = @PositionId

	DROP TABLE #IndividualList
	DROP TABLE #CurrentPosition
	DROP TABLE #ActiveIndividual

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndEffectivePositionStatus_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndEffectivePositionStatus_proc';

