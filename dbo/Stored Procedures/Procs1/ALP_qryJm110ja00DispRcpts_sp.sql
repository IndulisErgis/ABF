
CREATE Procedure [dbo].[ALP_qryJm110ja00DispRcpts_sp]
/* used in CustomerReceipts subform of the Control Center  */
	(
		@CustId pCustID = null,
		@CheckNum pCheckNum = null
	)
As
set nocount on
SELECT tblArHistPmt.CustId,
	SiteId = '0', 
	[Date] = tblArHistPmt.PmtDate,
	InvcNum = tblArHistPmt.InvcNum, 
	Type = 'Pmt',
	Amount = tblArHistPmt.PmtAmt*-1,
	tblArHistPmt.CheckNum
FROM tblArHistPmt
WHERE  (tblArHistPmt.CustId=@CustId) AND (tblArHistPmt.CheckNum = @CheckNum)
	OR
	((tblArHistPmt.CustId=@CustId) AND( @CheckNum is NULL))
ORDER BY [Date] DESC, InvcNum
return