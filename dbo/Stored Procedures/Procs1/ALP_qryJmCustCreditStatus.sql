

CREATE  PROCEDURE dbo.ALP_qryJmCustCreditStatus @ID pCustId
--MAH 11/11/08 - corrected error in original procedure. 
AS
SET NOCOUNT ON
SELECT c.CustId,
CASE 
	WHEN CreditHold = 1  THEN 'ON HOLD'
--	WHEN coalesce(c.CurAmtDue,0)+coalesce(c.BalAge1,0)+coalesce(c.BalAge2,0)+coalesce(c.BalAge3,0)+coalesce(c.BalAge4,0)+(coalesce(c.UnapplCredit,0)*-1)-coalesce(c.UnpaidFinch,0) >0 
	WHEN coalesce(c.CurAmtDue,0)+coalesce(c.BalAge1,0)+coalesce(c.BalAge2,0)+coalesce(c.BalAge3,0)+coalesce(c.BalAge4,0)+(coalesce(c.UnapplCredit,0)*-1)+ coalesce(c.UnpaidFinch,0) >0 
		AND (c.BalAge1 > 0 Or c.BalAge2 > 0 Or c.BalAge3 > 0 Or c.BalAge4 > 0) THEN 'Past Due'
	ELSE 'Current'
END AS CreditStatus
FROM tblArCust c
WHERE (((c.CustId)=@ID))