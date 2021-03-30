

CREATE FUNCTION [dbo].[ufxALP_R_GL_R331b_LastYear]
(	
	@Period smallint,
	@Year smallint
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
DTL.AcctId, 
HDR.AcctIdMasked, 
HDR.[Desc], 
--Changed to use ActualBase instead of Actual as it caused issues with multi-currency - ER - 02/12/16
Sum(DTL.ActualBase*HDR.BalType) AS LastYrAmt

FROM 
tblGlAcctDtl AS DTL
INNER JOIN trav_GlAccountHeader_view AS HDR
ON DTL.AcctId = HDR.AcctId

WHERE	
 (DTL.Period<=@Period) 
 AND (DTL.Year=(@Year-1))
		
GROUP BY 
DTL.AcctId, 
HDR.AcctIdMasked, 
HDR.[Desc]
)