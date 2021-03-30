


/****** Object:  StoredProcedure [dbo].[ALP_R_GL_R331_AuditWorksheet]    Script Date: 01/08/2013 19:08:59 ******/
CREATE PROCEDURE [dbo].[ALP_R_GL_R331_AuditWorksheet] 
(
@Period smallint,
@Year smallint
) 
--converted from access qryGL-R331-AuditWorksheet - 3/30/15 - ER

AS
BEGIN
SET NOCOUNT ON;
SELECT 
DTL.AcctId, 
HDR.AcctIdMasked, 
HDR.[Desc], 
qry331b.LastYrAmt, 
--Changed to use ActualBase instead of Actual as it caused issues with multi-currency - ER - 02/12/16
Sum(DTL.ActualBase*HDR.BalType) AS CurrentAmt

FROM 
(tblGlAcctDtl AS DTL
INNER JOIN trav_GlAccountHeader_view AS HDR
ON DTL.AcctId = HDR.AcctId) 
INNER JOIN ufxALP_R_GL_R331b_LastYear(@Period,@Year) AS qry331b
ON HDR.AcctId = qry331b.AcctId

WHERE	
(DTL.Period<=@Period) 
AND (DTL.Year=@Year)
		
GROUP BY 
DTL.AcctId, 
HDR.AcctIdMasked, 
HDR.[Desc], 
qry331b.LastYrAmt

END