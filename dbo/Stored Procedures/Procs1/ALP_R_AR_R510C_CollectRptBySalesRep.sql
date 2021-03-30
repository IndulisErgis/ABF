

CREATE PROCEDURE [dbo].[ALP_R_AR_R510C_CollectRptBySalesRep] 
	(
		@CustID varchar(10),
		@ComboBal_1234 decimal(20,10),
		@ComboBal_234 decimal(20,10),
		@ComboBal_34 decimal(20,10),
		@ComboBal_4 decimal(20,10),
		@SalesRep varchar(10)
	)
AS
SELECT 
AC.SalesRepId1, 
AC.CustName, 
AC.CustId, 
AC.Contact, 
AC.Phone, 
ufx_C.Balance, 
AC.CurAmtDue AS [Current], 
AC.BalAge1 AS [30to59], 
AC.BalAge2 AS [60to89], 
AC.BalAge3 AS [90to119], 
AC.BalAge4 AS [Over120Days], 
AC.UnapplCredit*-1 AS Unapplied, 
ufx_D.RMR AS ActiveRMR,
ufx_D.StartDate, 
ufx_B.AlpSiteID,
ASite.AlpFirstName,
ASite.SiteName, 
ufx_B.Rep1Id,
ufx_B.InvcNum,
ufx_B.[MinTransDate] AS Date2,
ufx_B.Amt
 
FROM 
	(((tblArCust AS AC
	INNER JOIN ufxALP_R_AR_R510b_NetOpenItems 
		(
			@CustID,
			@ComboBal_1234,
			@ComboBal_234,
			@ComboBal_34,
			@ComboBal_4 			) AS ufx_B -- CustID,AlpSiteID,RepID1,InvcNum,MinTransDate,Amt
		ON AC.CustId = ufx_B.CustId) 
	LEFT JOIN ALP_tblArAlpSite_view AS ASite 
		ON ufx_B.AlpSiteID = ASite.SiteId)
	INNER JOIN ufxALP_R_AR_R510c_OpenInvBal(@CustID) AS ufx_C -- gives balance
		ON AC.CustId = ufx_C.CustId)		
	LEFT JOIN ufxALP_R_AR_R510d_ActiveRmrByCust() AS ufx_D -- CustID, RMR, StartDate
		ON AC.CustId = ufx_d.CustId
		
WHERE (AC.CustId=@CustID OR @CustID = '<ALL>')
	AND
	  (AC.SalesRepId1 = @SalesRep OR @SalesRep = '<ALL>')
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
AC.SalesRepId1,
AC.CustName, 
AC.CustId, 
AC.Contact, 
AC.Phone,
ufx_C.Balance,
AC.CurAmtDue, 
AC.BalAge1, 
AC.BalAge2, 
AC.BalAge3, 
AC.BalAge4,  
UnapplCredit *-1, 
ufx_D.RMR, 
ufx_D.StartDate, 
ufx_B.AlpSiteID,
ASite.AlpFirstName, 
ASite.SiteName, 
ufx_B.Rep1Id,
InvcNum, 
ufx_B.[MinTransDate],
ufx_B.Amt, 
BalAge1+BalAge2+BalAge3+BalAge4,
BalAge2+BalAge3+BalAge4, 
BalAge3+BalAge4


ORDER BY 
ASite.AlpFirstName