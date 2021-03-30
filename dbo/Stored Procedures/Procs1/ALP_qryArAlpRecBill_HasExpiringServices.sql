CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_HasExpiringServices]
(
	@RunId INT
)
AS
BEGIN
	DECLARE @HasExpiring BIT = 0
	IF EXISTS(
		SELECT TOP 1 1
		FROM [dbo].[ALP_rptArAlpRecBill_ExpiringServicesReport_View] AS [es]
		WHERE	[es].[RunId] = @RunId
	)
	BEGIN
		SET @HasExpiring = 1
	END
	SELECT @HasExpiring AS [HasExpiringServices]
END