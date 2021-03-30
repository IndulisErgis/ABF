
CREATE PROCEDURE [dbo].[trav_HrProcessStaffingStatus_proc]
@EffectiveDate DATETIME,
@PositionId BIGINT,
@MaxDate DATETIME

AS
	BEGIN TRY

	SELECT p.ID FROM dbo.tblHrPosition p 
	LEFT JOIN dbo.tblHrIndPosition ip ON p.ID = ip.PositionID
	WHERE ((@EffectiveDate BETWEEN ip.StartDate AND ISNULL(ip.EndDate, @MaxDate)) AND (@PositionId = p.ID))

	END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrProcessStaffingStatus_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrProcessStaffingStatus_proc';

