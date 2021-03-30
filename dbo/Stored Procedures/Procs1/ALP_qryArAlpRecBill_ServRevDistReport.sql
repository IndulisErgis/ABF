CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_ServRevDistReport]
(
	@RunId INT
)
AS
BEGIN
	SELECT
		*
	FROM [dbo].[ALP_rptArAlpRecBill_ServRevDistReport_View]
	WHERE	[RunId] = @RunId	
END