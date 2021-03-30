

CREATE PROCEDURE [dbo].[ALP_R_AR_AccessReports] 
@ReportGroup varchar(15),
@ReWriter varchar(10) = '<ALL>'
AS
BEGIN

SELECT 
AR.ReportID,
AR.ReportGroup,
AR.ObjectName,
AR.Title, 
AR.Rewriter,
AR.RewriteGroup
--AR.Param1, 
--AR.Param2, 
--AR.Param3, 
--AR.Param4,


FROM tblALP_R_AccessReports as AR

WHERE (ReportGroup=@ReportGroup OR @ReportGroup='<ALL>') AND
		(Rewriter=@ReWriter OR @ReWriter='<ALL>')
 
ORDER BY 
AR.ReportGroup,
AR.ObjectName


END