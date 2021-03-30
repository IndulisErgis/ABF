
CREATE PROCEDURE [dbo].[tsmPcMigrationStep1]

AS
BEGIN TRY
SET NOCOUNT ON
	CREATE TABLE #tmpError(Severity int NOT NULL, Error nvarchar(max) NOT NULL)
	
	--AP Transactions with project line items. 
	if exists(select * from dbo.tblApTransDetail Where TransHistId IS NOT NULL)
	Begin
		INSERT INTO #tmpError(Severity,Error)
		VALUES(16,'Unable to upgrade with unposted AP Transactions with project line items (tblApTransDetail).')
	End

	--AR Transactions with project line items
	if exists(select * from dbo.tblArTransHeader Where PMTransType <> 'NEW')
	Begin
		INSERT INTO #tmpError(Severity,Error)
		VALUES(16,'Unable to upgrade with unposted AR Transactions with project line items (tblArTransHeader).')
	End
	
	--IN Material Requisitions with project line items
	if exists(select * from dbo.tblInMatReqDetail Where CustId IS NOT NULL AND ProjId IS NOT NULL)
	Begin
		INSERT INTO #tmpError(Severity,Error)
		VALUES(16,'Unable to upgrade with unposted IN Material Requisitions with project line items (tblInMatReqDetail).')
	End
	
	if exists(SELECT CustId, ProjId FROM (SELECT CustId, ProjId FROM dbo.tblJcProject UNION ALL SELECT CustId, ProjId FROM dbo.tblJcArcProject) p
		GROUP BY CustId, ProjId HAVING COUNT(*) > 1)
	Begin
		INSERT INTO #tmpError(Severity,Error)
		VALUES(16,'Unable to upgrade with duplicated Customer/Project (tblJcProject,tblJcArcProject).')
	End
		
	DECLARE @ConfigValue nvarchar(255) 
	EXEC dbo.glbSmGetSingleConfigValue_sp 'JC',null,'CreditAcct',@ConfigValue out 
	
	IF ISNULL(@ConfigValue,'') = ''
	Begin
		INSERT INTO #tmpError(Severity,Error)
		VALUES(16,'Business rule Default Credit Account is invalid.')
	End
	
	SELECT Severity, Error FROM #tmpError

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'tsmPcMigrationStep1';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'tsmPcMigrationStep1';

