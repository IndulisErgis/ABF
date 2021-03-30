Create procedure [dbo].[ALP_qryGlAcctHdr_sp]
(
	@AcctId varchar(40)
)
As

Select Status from tblGlAcctHdr where AcctId=@AcctId