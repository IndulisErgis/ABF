CREATE VIEW [dbo].[ALP_rptArAlpRecBill_ServRevDistReport_View]
AS
	SELECT
		[srd].[Id], 
		[srd].[ForYear], 
		[srd].[ForPeriod], 
		[srd].[GLAccount], 
		[srd].[Amount], 
		[srd].[FromYear], 
		[srd].[FromPeriod], 
		[srd].[InvoiceDate], 
		[srd].[RunId], 
		[srd].[ts],
		[gl].[Desc]
	FROM [dbo].[ALP_tblArAlpServRevDist] AS [srd]
	INNER JOIN [dbo].[tblGlAcctHdr] AS [gl]
		ON	[gl].[AcctId] = [srd].[GLAccount]
	INNER JOIN [dbo].[tblSmPeriodConversion] AS [for]
		ON	[for].[GlYear] = [srd].[ForYear]
		AND	[for].[GlPeriod] = [srd].[ForPeriod]
	INNER JOIN [dbo].[tblSmPeriodConversion] AS [from]
		ON	[from].[GlYear] = [srd].[FromYear]
		AND	[from].[GlPeriod] = [srd].[FromPeriod]