


CREATE PROCEDURE [dbo].[ALP_R_GL_R331_AuditWorksheet_Year_Dropdown] 
AS
BEGIN
SET NOCOUNT ON;
--Populates Year parameter dropdown for R331 report - 3/30/2015 - ER
SELECT distinct Year FROM tblGlAcctDtl order by Year

END