CREATE PROCEDURE dbo.trav_HrIndEffectivePosition_proc
@EffectiveDate DATETIME,
@IsRangeDateView BIT = 0

AS
--Retrieves the most recent, effective positions held by a given subset of individuals.
--Individuals without an effective position that is inclusive of the Effective date are not included in the returned result set

--Expects a list of individual id values to be provided via temporary table #IndividualList that supports the following
--Create Table #IndividualList ([IndID] [pEmpId], Primary Key ([IndID]))

SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #IndPosition 
	(
		[Counter] [bigint] NOT NULL IDENTITY (1, 1),
		[IndId] [pEmpId],
		[IndPositionID] [bigint]
		PRIMARY KEY ([IndId], [Counter])
	)

	BEGIN 
	IF @IsRangeDateView = 0
	--capture effective positions 
	--ordered by PrimaryPosition and StartDate so that most recent primary position has the lowest counter value
	INSERT INTO #IndPosition ([IndId], [IndPositionID])
	SELECT g.[IndId], ip.[ID]
		FROM [dbo].[tblHRIndGenInfo] g 
		INNER JOIN #IndividualList i ON g.[IndId] = i.[IndID]
		INNER JOIN [dbo].[tblHrIndPosition] ip ON g.[IndId] = ip.[IndId]
		WHERE @EffectiveDate BETWEEN ISNULL(ip.[StartDate], @EffectiveDate) AND ISNULL(ip.[EndDate], @EffectiveDate)
		ORDER BY ip.[PrimaryPosition] DESC, ip.[StartDate] DESC
	ELSE
	INSERT INTO #IndPosition ([IndId], [IndPositionID])
	SELECT g.[IndId], ip.[ID]
		FROM [dbo].[tblHRIndGenInfo] g 
		INNER JOIN #IndividualList i ON g.[IndId] = i.[IndID]
		INNER JOIN [dbo].[tblHrIndPosition] ip ON g.[IndId] = ip.[IndId]
		ORDER BY ip.[PrimaryPosition] DESC, ip.[StartDate] DESC
	END
	--Return the position for each individual with the lowest counter
	--	as it represents the most recent position (primary when available) inclusive of the effective date
	--	use the largest Primary position when one exists
	SELECT ip.[IndId], ip.[IndPositionID]
		FROM #IndPosition ip
		INNER JOIN (SELECT [IndId], MIN([Counter]) AS [Counter]
			FROM #IndPosition 
			GROUP BY [IndId]
		) pid ON ip.[IndId] = pid.[IndId] AND ip.[Counter] = pid.[Counter]

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndEffectivePosition_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndEffectivePosition_proc';

