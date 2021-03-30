
Create Procedure [dbo].[ALP_lkpJm110j20DispRcptsComboByDate_sp]
/* used in Customer Receipts subform of Control Center  */
	(
		@CustId  pCustId = null
	)
As
set nocount on
	SELECT tblArHistPmt.CheckNum, 
		[Dep Date] = tblArHistPmt.PmtDate, 
		Amount = Sum(tblArHistPmt.PmtAmt), 
		Method = tblArHistPmt.PmtMethodId, 
		Type = tblArHistPmt.PmtType
	FROM tblArHistPmt
	WHERE (tblArHistPmt.CustId = @CustId)
	GROUP BY tblArHistPmt.CheckNum, 
		tblArHistPmt.PmtDate, 
		tblArHistPmt.PmtMethodId, 
		tblArHistPmt.PmtType, 
		tblArHistPmt.CustId
	ORDER BY  tblArHistPmt.PmtDate DESC
return