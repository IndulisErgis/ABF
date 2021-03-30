CREATE FUNCTION [dbo].[ufxCustCreditStatus]
/* returns the customer's credit status as a string */
(
@CustID varchar(10)
)  
RETURNS varchar (12)
AS 
 
BEGIN 
declare @cs as varchar(12)
SELECT 
@cs=
	CASE 
		WHEN CreditHold = -1 
			 THEN 'ON HOLD'
		WHEN coalesce(c.CurAmtDue,0)+
			coalesce(c.BalAge1,0)+
			coalesce(c.BalAge2,0)+
			coalesce(c.BalAge3,0)+
			coalesce(c.BalAge4,0)+
			(coalesce(c.UnapplCredit,0)*-1)-
			coalesce(c.UnpaidFinch,0) >0 
			AND (c.BalAge1 > 0 
			Or c.BalAge2 > 0
			 Or c.BalAge3 > 0 
			Or c.BalAge4 > 0) 
			THEN 'Past Due'
		ELSE 'Current'
	END
FROM tblArCust c
WHERE c.CustId=@CustID
return @cs
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCustCreditStatus] TO PUBLIC
    AS [dbo];

