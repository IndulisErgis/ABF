
CREATE Procedure [dbo].[ALP_qryJm110g00CustBalances_sp]
/* RecordSource for Customer Balances subform of Control Center */
	(
	@CustID pCustID = null
	)
As
	set nocount on
	SELECT CustId, LastPayDate, CurAmtDue,
		 BalAge1, BalAge2, BalAge3, BalAge4,
		 UnapplCredit, UnpaidFinch,
		Totdue = [CurAmtDue]+[BalAge1]+[BalAge2]+[BalAge3]+[BalAge4]+[UnpaidFinch]-[UnApplCredit]
	FROM ALP_tblArCust_view (NOLOCK)
	WHERE CustId = @CustID
	ORDER BY CustID
	return