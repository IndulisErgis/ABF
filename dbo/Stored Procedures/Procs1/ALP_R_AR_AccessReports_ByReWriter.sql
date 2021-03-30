

CREATE PROCEDURE [dbo].[ALP_R_AR_AccessReports_ByReWriter] 
@ReWriter nvarchar(10) = '<ALL>'
AS
BEGIN

SELECT 
AR.Rewriter,
AR.RewriteGroup,
AR.Title,
AR.ObjectName,
AR.ReportGroup

FROM tblALP_R_AccessReports as AR
WHERE (AR.ReWriter=@ReWriter OR @ReWriter = '<ALL>')
-- AND RewriteGroup is not Null -- AND Rewriter is not Null

ORDER BY 
Rewriter DESC,
RewriteGroup,
ObjectName

END