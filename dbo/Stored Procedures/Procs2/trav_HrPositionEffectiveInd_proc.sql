CREATE PROCEDURE [dbo].[trav_HrPositionEffectiveInd_proc]
@EffectiveDate datetime,
@ShowAllIndId bit = 0
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #PositionList 
	(
		[Counter] [bigint] NOT NULL IDENTITY (1, 1),
		[ID] [bigint] NOT NULL,
		[IndId] [pEmpId] NULL
		PRIMARY KEY ([ID], [Counter])
	)
	INSERT INTO #PositionList ([ID], [IndId])
	SELECT p.ID, ip.IndId FROM dbo.tblHrPosition p
		LEFT JOIN [dbo].[tblHrIndPosition] ip ON p.[ID] = ip.PositionID
		WHERE @EffectiveDate BETWEEN ISNULL(ip.[StartDate], @EffectiveDate) AND ISNULL(ip.[EndDate], @EffectiveDate)
		ORDER BY p.ID, ip.[PrimaryPosition] DESC, ip.[StartDate] DESC

BEGIN 
	IF @ShowAllIndId = 1
		SELECT p.ID, p.[IndId]
		FROM #PositionList p

	ELSE
	SELECT p.ID, p.[IndId]
	FROM #PositionList p
	INNER JOIN (SELECT [ID], MIN([Counter]) AS [Counter]
			    FROM #PositionList 
			    GROUP BY [ID]
	) pid ON p.ID = pid.ID AND p.[Counter] = pid.[Counter]
END
END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrPositionEffectiveInd_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrPositionEffectiveInd_proc';

