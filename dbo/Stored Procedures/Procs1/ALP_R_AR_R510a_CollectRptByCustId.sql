

CREATE PROCEDURE [dbo].[ALP_R_AR_R510a_CollectRptByCustId] 
	(
		@CustID varchar(10),
		@ComboBal_1234 decimal(20,10),
		@ComboBal_234 decimal(20,10),
		@ComboBal_34 decimal(20,10),
		@ComboBal_4 decimal(20,10)
	)
AS
SELECT 
AC.CustId,
ufx_B.AlpSiteID,
ufx_B.[MinTransDate] AS Date2,
ufx_B.Rep1Id, 
AC.CustName,
ufx_B.InvcNum,
ufx_C.Balance, 
AC.Contact, 
AC.Phone, 
AC.CurAmtDue AS [Current], 
AC.BalAge1 AS [30to59], 
AC.BalAge2 AS [60to89], 
AC.BalAge3 AS [90to119], 
AC.BalAge4 AS [Over120Days], 
AC.UnapplCredit*-1 AS Unapplied, 
ufx_D.RMR AS ActiveRMR, 
ufx_D.StartDate, 
AC.AlpFirstName,
ASite.SiteName, 
ASite.AlpFirstName as SiteFirstName, 
ufx_B.Amt

FROM 
	ALP_tblArCust_view AS AC
	INNER JOIN ufxALP_R_AR_R510b_NetOpenItems 
		(
			@CustID,
			@ComboBal_1234,
			@ComboBal_234,
			@ComboBal_34,
			@ComboBal_4 			) AS ufx_B -- CustID,AlpSiteID,RepID1,InvcNum,MinTransDate,Amt
		ON AC.CustId = ufx_B.CustId 

	INNER JOIN ufxALP_R_AR_R510c_OpenInvBal(@CustID) AS ufx_C -- gives balance
		ON AC.CustId = ufx_C.CustId		
	LEFT JOIN ufxALP_R_AR_R510d_ActiveRmrByCust() AS ufx_D -- CustID, RMR, StartDate
		ON AC.CustId = ufx_d.CustId
		
    LEFT JOIN ALP_tblArAlpSite_view AS ASite
		ON ufx_B.AlpSiteID = ASite.SiteId

WHERE (AC.CustId=@CustID OR @CustID = '<ALL>')
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
ufx_B.InvcNum,
AC.CustId,  
ufx_B.AlpSiteID, 
ufx_B.[MinTransDate],
ufx_B.Rep1Id,
AC.CustName,
ufx_C.Balance,
AC.Contact, 
AC.Phone, 
AC.CurAmtDue, 
AC.BalAge1, 
AC.BalAge2, 
AC.BalAge3, 
AC.BalAge4, 
AC.UnapplCredit *-1, 
ufx_D.RMR, 
ufx_D.StartDate, 
ASite.SiteName, 
ufx_B.Amt, 
BalAge1+BalAge2+BalAge3+BalAge4, 
BalAge2+BalAge3+BalAge4, 
BalAge3+BalAge4,
AC.AlpFirstName,
ASite.AlpFirstName

ORDER BY 
ufx_B.InvcNum,
AC.CustId,
ufx_B.MinTransDate