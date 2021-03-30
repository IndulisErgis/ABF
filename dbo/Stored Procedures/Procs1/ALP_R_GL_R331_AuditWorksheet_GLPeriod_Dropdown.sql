


CREATE PROCEDURE [dbo].[ALP_R_GL_R331_AuditWorksheet_GLPeriod_Dropdown] 
AS
BEGIN
SET NOCOUNT ON;

SELECT distinct Period FROM tblGlAcctDtl order by Period

END