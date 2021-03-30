
CREATE PROCEDURE dbo.trav_PsRewardActivityPrepare_BuildList_proc 
AS
SET NOCOUNT ON
BEGIN TRY
	--located most recent processed history grouping
	DECLARE @LastProcessed pPostRun
	SELECT @LastProcessed = max([ActivityGroup]) FROM dbo.tblPsRewardActivity

	--uses an existing temporary table that supports the following
	--CREATE TABLE #HistoryList
	--(
	--	[ID] [bigint], 
	--	PRIMARY KEY CLUSTERED ([ID])
	--)

	--build list of history to include in processing
	INSERT INTO #HistoryList ([ID])
	SELECT h.[ID]
		FROM dbo.tblPsHistHeader h 
		INNER JOIN dbo.tblPsRewardAccount a ON h.[RewardNumber] = a.[RewardNumber]
		WHERE (h.[PostRun] > @LastProcessed OR @LastProcessed IS NULL)
			AND (h.TransType = 1 OR h.TransType = -1) --accrual only applies to Invoices (1) and Returns (-1)
			AND h.VoidDate IS NULL --that were not voided
			AND a.[Status] = 0 AND a.[Type] = 0 --limit to Active, Regular accounts


	--return the rowcount to identify if there is data to process
	SELECT @@ROWCOUNT AS [RecordCount]


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPrepare_BuildList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPrepare_BuildList_proc';

