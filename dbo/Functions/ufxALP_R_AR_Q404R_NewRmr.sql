
CREATE FUNCTION [dbo].[ufxALP_R_AR_Q404R_NewRmr] 
(
@StartDate datetime,
@EndDate datetime
)
RETURNS TABLE 
AS
RETURN 
(
--converted from access qrySite-Q404-NewRMR - 3/23/2015 - ER

SELECT 
SRBSP.RecBillServId, 
SRBSP.RecBillServPriceId, 
SRBSP.Price AS RMR, 
MAX(SRBSP.StartBillDate) AS MaxOfStartBillDate

FROM ALP_tblArAlpSiteRecBillServPrice_view AS SRBSP

WHERE SRBSP.StartBillDate >= @StartDate AND SRBSP.StartBillDate <= @EndDate

GROUP BY SRBSP.RecBillServId, SRBSP.Price, SRBSP.RecBillServPriceId
)