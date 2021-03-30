Create procedure [dbo].[ALP_qryInGLAcct_sp]
(
	@GLAcctCode varchar(2)
)
As

Select GLAcctSales,GLAcctCogs  from tblInGLAcct where GLAcctCode=@GLAcctCode