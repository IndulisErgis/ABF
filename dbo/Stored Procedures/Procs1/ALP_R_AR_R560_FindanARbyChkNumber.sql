


CREATE PROCEDURE [dbo].[ALP_R_AR_R560_FindanARbyChkNumber] 
(
	@CheckNum varchar(10) = null
)
AS
SELECT DISTINCT 
HP.CustId, 
AC.CustName, 
HP.CheckNum, 
HP.PmtDate, 
HP.PmtAmt, 
HP.InvcNum,
H.AlpSiteID as SiteID

FROM tblArHistPmt AS HP
	INNER JOIN ALP_tblArCust_view AS AC 
		ON HP.CustId = AC.CustId
	left outer join ALP_tblArHistHeader_view AS H  
		on HP.Invcnum = H.InvcNum 

--Added NULL allowance on TransType filter to allow ON ACCT checks to show in report - 012015 - ER
WHERE
(H.TransType = 1  OR H.TransType IS NULL)
--(H.TransType = 1  OR TransType = -1 OR H.TransType IS NULL)
AND
HP.CheckNum=@CheckNum