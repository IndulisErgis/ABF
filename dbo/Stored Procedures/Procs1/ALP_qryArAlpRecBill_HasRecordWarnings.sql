
CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_HasRecordWarnings]
(
	@RunId INT
)
AS
BEGIN
	DECLARE @HasWarnings BIT = 0
	IF EXISTS(
		SELECT TOP 1 1
		FROM [dbo].[ALP_rptArAlpRecBill_EditReport_View] AS [er]
		WHERE	[er].[RunId] = @RunId
			AND	[er].[HasWarnings] = CAST(1 AS bit)
	)
	BEGIN
		SET @HasWarnings = 1
	END
	SELECT @HasWarnings AS [HasRecordWarnings]
END