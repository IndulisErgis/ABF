
CREATE PROCEDURE dbo.trav_PsBuildHostList_proc
@LocID pLocID = NULL,
@IncludePayment bit = 0
AS
SET NOCOUNT ON
BEGIN TRY

	--Populate all hosts that have config record with matching location
	INSERT INTO #PsHostList (HostID)
	SELECT DISTINCT HostID 
	FROM dbo.tblPsTransHeader 
	WHERE HostID NOT IN (SELECT HostID FROM #PsHostList) 
		AND ConfigID IN (SELECT ID FROM dbo.tblPsConfig WHERE ISNULL(LocID,'') = ISNULL(@LocID,'')) 

	IF (@IncludePayment = 1)
	BEGIN
		--Populate all hosts that have config record with matching location
		INSERT INTO #PsHostList (HostID)
		SELECT DISTINCT HostID 
		FROM dbo.tblPsPayment 
		WHERE HostID NOT IN (SELECT HostID FROM #PsHostList) 
			AND ConfigID IN (SELECT ID FROM dbo.tblPsConfig WHERE ISNULL(LocID,'') = ISNULL(@LocID,'')) 
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsBuildHostList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsBuildHostList_proc';

