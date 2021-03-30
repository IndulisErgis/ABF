

CREATE FUNCTION [dbo].[ALP_ufxJMGetGLAcctDescr]
(
	@GLAcct varchar(40)
)
RETURNS varchar(30)
AS
BEGIN
DECLARE @Desc varchar(30)
SET @Desc = '<GL Acct not found>'
SELECT @Desc = [Desc]
FROM	[dbo].[tblGlAcctHdr] WHERE AcctId = @GLAcct
RETURN @Desc
END


--select [dbo].[ALP_ufxJMGetGLAcctDescr]('10200000')