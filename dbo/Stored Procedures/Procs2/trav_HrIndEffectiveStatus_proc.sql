CREATE PROCEDURE dbo.trav_HrIndEffectiveStatus_proc
@EffectiveDate datetime,
@Status tinyint --Enum:0;All;1;Active;2;Inactive

AS
--Retrieves the effective status of a given subset of individuals.
--Individuals without a status within the given date range are identified as inactive

--Expects a list of individual id values to be provided via temporary table #IndividualList that supports the following
--Create Table #IndividualList ([IndID] [pEmpId], Primary Key ([IndID]))

--Standard Code ID Enum:24;AFT;25;APT;26;DEC;27;NEM;28;RET

SET NOCOUNT ON
BEGIN TRY

	SELECT g.[IndId], ist.[ID] AS [IndStatusID], ISNULL(ist.[IndStatus], 0) AS [IndStatus]
	FROM [dbo].[tblHRIndGenInfo] g 
	INNER JOIN #IndividualList i ON g.[IndId] = i.[IndID]
	LEFT JOIN 
	(
		SELECT s1.[IndId], s1.[ID]
			, CASE WHEN tc.[StandardID] in (24, 25) THEN 1 ELSE 0 END AS [IndStatus] --24/25 = Active
			FROM [dbo].[tblHrIndStatus] s1 
			INNER JOIN [dbo].[tblHRTypeCode] tc ON tc.ID = s1.[IndStatusTypeCodeID]
			WHERE s1.[ID] IN (SELECT TOP 1 [ID]
				FROM [dbo].[tblHrIndStatus] s2
				WHERE s2.[StartDate] <= @EffectiveDate AND s2.[IndId] = s1.[IndId]
				ORDER BY s2.[StartDate] DESC, s2.[ID] DESC)
	) ist ON g.[IndId] = ist.[IndId]
	WHERE (@Status = 0
		OR (@Status = 1 AND ist.[IndStatus] = 1) --active
		OR (@Status = 2 AND ISNULL(ist.[IndStatus], 0) = 0)) --inactive

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndEffectiveStatus_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndEffectiveStatus_proc';

