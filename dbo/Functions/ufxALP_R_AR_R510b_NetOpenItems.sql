
CREATE FUNCTION [dbo].[ufxALP_R_AR_R510b_NetOpenItems]
(
	@CustID varchar(10),
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
	ufx_A.CustId, 
	MAX(ufx_A.AlpSiteID) AS AlpSiteID, 
	ufx_A.Rep1Id, 
	ufx_A.InvcNum, 
	MIN(ufx_A.TransDate) AS MinTransDate,
	--ufx_A.TransDate AS [Date2], 
	Sum(ufx_A.Amount) AS Amt

FROM ufxALP_R_AR_R510a_FilteredOpenItems(
				@CustID,
				@ComboBal_1234,
				@ComboBal_234,
				@ComboBal_34,
				@ComboBal_4) AS ufx_A -- formerly ufxALP_R_AR_R510a_OpenItems
--removed site grouping to remove duplicate bill/pay invoice entries when no siteID supplied
GROUP BY 
	ufx_A.CustId, 
	--ufx_A.AlpSiteID, 
	ufx_A.Rep1Id, 
	ufx_A.InvcNum

HAVING 
	Sum(ufx_A.Amount)<>0
	
);