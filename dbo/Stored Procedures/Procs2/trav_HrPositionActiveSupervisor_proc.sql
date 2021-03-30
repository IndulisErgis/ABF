
CREATE PROC [dbo].[trav_HrPositionActiveSupervisor_proc]
@EffectiveDate DATETIME,
@PositionId BIGINT = NULL 

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT ds.PositionId, ds.IndId FROM (SELECT ROW_NUMBER() OVER (PARTITION BY ip.PositionId ORDER BY ip.StartDate DESC) AS r, 
	ip.PositionId, ip.IndId FROM tblHrIndPosition ip
	INNER JOIN tblHrPosition p ON p.SupervisorPositionID = ip.PositionID
	INNER JOIN #IndPositionID tpos ON ip.IndId = tpos.IndId AND ip.ID = tpos.PositionID
	INNER JOIN #IndStatus ts ON ip.IndId = ts.IndId
	WHERE ((ip.EndDate IS NULL AND @EffectiveDate >= ip.StartDate) OR (@EffectiveDate BETWEEN ip.StartDate AND ip.EndDate)) 
	AND (@PositionId IS NULL OR ip.PositionId = @PositionId) AND ts.IndStatus = 1) ds WHERE ds.r = 1

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrPositionActiveSupervisor_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrPositionActiveSupervisor_proc';

