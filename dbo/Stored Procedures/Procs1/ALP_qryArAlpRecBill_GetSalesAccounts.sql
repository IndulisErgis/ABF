
CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_GetSalesAccounts]
(
	@RunId INT
)
AS
BEGIN
	DECLARE @AcctCodes GlAcctCodeListType;
	INSERT INTO @AcctCodes
	([AcctCode])
	SELECT
		[srb].[AcctCode]
	FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]
	INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill] AS [srb]
		ON	[srb].[RecBillId] = [rr].[RecBillId]
	WHERE	[rr].[RunId] = @RunId
	UNION 
	SELECT
		[srbs].[AcctCode]
	FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]
	INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [srbs]
		ON	[srbs].[RecBillServId] = [rr].[RecBillServId]
	WHERE	[rr].[RunId] = @RunId
	
	EXEC [dbo].[ALP_qryArSalesAccount_GetAccounts] @AcctCodes = @AcctCodes
END