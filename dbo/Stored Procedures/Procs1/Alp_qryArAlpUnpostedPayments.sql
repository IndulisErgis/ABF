CREATE PROCEDURE dbo.Alp_qryArAlpUnpostedPayments @Cust varchar(10)  
As  
SET NOCOUNT ON  
SELECT Sum(tblArCashRcptDetail.PmtAmt) AS Paymnt  
FROM tblArCashRcptHeader INNER JOIN tblArCashRcptDetail ON tblArCashRcptHeader.RcptHeaderID = tblArCashRcptDetail.RcptHeaderID  
WHERE (((tblArCashRcptHeader.CustId)=@Cust));