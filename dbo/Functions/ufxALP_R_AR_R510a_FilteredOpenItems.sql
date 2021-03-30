
CREATE FUNCTION [dbo].[ufxALP_R_AR_R510a_FilteredOpenItems]
(	
	@Custid VARCHAR(10),
	@ComboBal_1234 decimal(20,10),
	@ComboBal_234 decimal(20,10),
	@ComboBal_34 decimal(20,10),
	@ComboBal_4 decimal(20,10)
)
RETURNS TABLE 
AS
RETURN 
(
SELECT  
	OI.InvcNum,
	OI.CustId,
	OI.AlpSiteID, 
	HH.Rep1Id, 
	OI.TransDate, 
 --Added sum. Was filtering out duplicate ON ACCT entries - 05/18/2016 - ER
	SUM(CASE WHEN RecType>0 THEN Amt ELSE Amt*-1 END) AS Amount, 
	HH.CustId AS HistCustid,
	AC.BalAge1,
	AC.BalAge2,
	AC.BalAge3,
	AC.BalAge4
	
	FROM 
	ALP_tblArCust_view AS AC
	INNER JOIN ALP_tblArOpenInvoice_view AS OI  
	ON AC.CustId = OI.CustId 
	LEFT JOIN ALP_tblArHistHeader_view AS HH
	ON OI.InvcNum = HH.InvcNum AND OI.CustId = HH.CustId
	
		
		
WHERE (OI.CustId=@Custid OR @Custid='<ALL>')
	AND 
	(
	BalAge1+BalAge2+BalAge3+BalAge4>@ComboBal_1234 
	OR 
	BalAge2+BalAge3+BalAge4>@ComboBal_234 
	OR 
	BalAge3+BalAge4>@ComboBal_34 
	OR 
	BalAge4>@ComboBal_4	
	)
	
GROUP BY 
	OI.InvcNum,
	OI.CustId,
	OI.AlpSiteID, 
	HH.Rep1Id, 
	OI.TransDate, 
	CASE WHEN RecType>0 THEN Amt ELSE Amt*-1 END , 
	HH.CustId,
	AC.BalAge1,
	AC.BalAge2,
	AC.BalAge3,
	AC.BalAge4	
)