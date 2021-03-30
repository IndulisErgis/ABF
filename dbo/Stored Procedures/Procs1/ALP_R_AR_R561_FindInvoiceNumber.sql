CREATE PROCEDURE [dbo].[ALP_R_AR_R561_FindInvoiceNumber] 
(
	@InvcNum varchar(15)
)
as

SET NOCOUNT ON;

SELECT 
	HH.CustId, 
	AC.CustName,
	CASE HH.TransType WHEN '1' THEN 'Invoice' ELSE 'Credit Memo' END as [Type],
	HH.InvcNum,
	HH.InvcDate, 
	HH.taxsubtotal+HH.nontaxsubtotal+
	HH.salestax+HH.freight+HH.misc AS Amount,
	HH.AlpSiteID
	
FROM ALP_tblArCust_view AS AC 
	INNER JOIN ALP_tblArHistHeader_view AS HH
		ON AC.CustId = HH.CustId

WHERE HH.InvcNum=@InvcNum