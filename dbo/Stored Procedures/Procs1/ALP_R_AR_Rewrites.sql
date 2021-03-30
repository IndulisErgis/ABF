

CREATE PROCEDURE [dbo].[ALP_R_AR_Rewrites]
@Rewriter nvarchar(3),
@RewriteGroup nvarchar(3)
AS
BEGIN
SET NOCOUNT ON;

SELECT 
ObjectName,
Title,
ReportGroup,
Rewriter,
RewriteGroup      
  FROM [TST].[dbo].[tblReports]
  
  WHERE 
  (Rewriter=@Rewriter OR @Rewriter = '<ALL>')
  AND 
  (RewriteGroup=@RewriteGroup OR @RewriteGroup='<ALL>')
    
  ORDER BY ReportGroup
END