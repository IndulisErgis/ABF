CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_EditReport_Exceptions]
(
	@RunId INT
)
AS
BEGIN
	SELECT
		[e].*
	FROM [dbo].[ALP_rptArAlpRecBill_EditReport_View] AS [e]
	WHERE	[e].[RunId] = @RunId
		AND	[e].[HasWarnings] = CAST(1 AS BIT)
END