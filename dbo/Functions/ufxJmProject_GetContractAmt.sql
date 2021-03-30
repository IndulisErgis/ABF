
CREATE function [dbo].[ufxJmProject_GetContractAmt]
(
	@ProjectID varchar(10)
)
--MAH 07/02/07 - accommodate null contract values
--MAH 03/06/10 - allow for mispellings of 'cancelled'  (!)
returns pDec
AS
BEGIN
DECLARE @ReturnSum pdec
DECLARE @sum pdec
--SET @sum = 0
--RETURN
SET @sum = 
	(SELECT SUM(case when ContractValue is null then 0 
			 else ContractValue end ) as ContractTotal
		FROM tblArAlpCustContract C
		WHERE C.ContractId IN (SELECT DISTINCT ST.ContractId
					FROM tblJmSvcTkt ST 
					WHERE (ST.ProjectId = @ProjectID) 
						AND ((ST.Status <> 'cancelled')AND(ST.Status <> 'canceled'))
					)
)
IF @sum is null 
	BEGIN 
		SET @ReturnSum = 0
	END
ELSE
	BEGIN
		SET @ReturnSum = @sum
	END

RETURN @ReturnSum
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxJmProject_GetContractAmt] TO PUBLIC
    AS [dbo];

