

CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_ResetRun]
(
	@RunGuid UNIQUEIDENTIFIER
)
AS
BEGIN

	IF NOT EXISTS(SELECT 1 FROM [dbo].[ALP_tblArAlpRecBillRun] AS [r] WHERE [r].[RunGuid] = @RunGuid)
	BEGIN
		-- Run wasn't found, nothing to reset. 
		RETURN 0
	END

	DECLARE @RunId INT

	SELECT @RunId = [r].[RunId]
	FROM [dbo].[ALP_tblArAlpRecBillRun] AS [r]
	WHERE	[r].[RunGuid] = @RunGuid
		AND	[r].[StatusCode] IN ('I', 'R', 'X', 'V')

	IF(@RunId IS NULL)
	BEGIN
		-- Run has an invalid status for reseting.
		RAISERROR('Record was not found or is invalid for reset.', 16, 1)
		RETURN -1;
	END


	UPDATE [r]
	SET	[StatusCode] = 'I'	
	FROM [dbo].[ALP_tblArAlpRecBillRun] AS [r]
	WHERE	[r].[RunId] = @RunId

	DELETE FROM [rr]
	FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]
	WHERE [rr].[RunId] = @RunId

	DELETE FROM [srd]
	FROM [dbo].[ALP_tblArAlpServRevDist] AS [srd]
	WHERE	[srd].[RunId] = @RunId

	RETURN 0
END