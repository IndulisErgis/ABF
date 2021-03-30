
CREATE PROCEDURE [dbo].[ALP_qryArSalesAccount_GetAccounts]
(
	@AcctCodes GlAcctCodeListType READONLY
)
AS
BEGIN
	SELECT
		[s].[AcctCode],
		[s].[Desc],
		[s].[GlAcctSales],
		[s].[GlAcctCOGS],
		[s].[CF],
		[s].[ts]
	FROM [dbo].[tblArSalesAcct] AS [s]
	INNER JOIN @AcctCodes AS [input]
		ON	[input].[AcctCode] = [s].[AcctCode]
END