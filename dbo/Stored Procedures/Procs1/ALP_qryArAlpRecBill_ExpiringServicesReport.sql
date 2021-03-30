CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_ExpiringServicesReport]
(
	@RunId INT
)
AS
BEGIN
	SELECT
		*
	FROM [dbo].[ALP_rptArAlpRecBill_ExpiringServicesReport_View] WHERE [RunId] = @RunId
END