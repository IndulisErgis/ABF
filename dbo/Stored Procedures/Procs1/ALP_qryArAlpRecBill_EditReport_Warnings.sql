CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_EditReport_Warnings]
(
	@RunId INT
)
AS
BEGIN
	SELECT
		[e].*
	FROM [dbo].[ALP_rptArAlpRecBill_EditReport_View] AS [e]
	WHERE	[e].[RunId] = @RunId
		AND	([e].[HasWarnings] = CAST(1 AS BIT) 
		--Comments condition added by NSK on 12 Nov 2015 to display the billing and service related warnings report
		Or Comments like 'NO %')
END