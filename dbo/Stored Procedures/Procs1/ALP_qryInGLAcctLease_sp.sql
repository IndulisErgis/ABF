Create procedure [dbo].[ALP_qryInGLAcctLease_sp]
(
	@AlpGLAcctCode varchar(2)
)
As

Select AlpGLAcctSalesLease,AlpGLAcctCogsLease 
from ALP_tblInGLAcct  
where AlpGLAcctCode=@AlpGLAcctCode