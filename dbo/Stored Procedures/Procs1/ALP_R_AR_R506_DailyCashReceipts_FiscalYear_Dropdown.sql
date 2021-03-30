

CREATE PROCEDURE [dbo].[ALP_R_AR_R506_DailyCashReceipts_FiscalYear_Dropdown] 
AS
BEGIN
SET NOCOUNT ON;

SELECT distinct FiscalYear FROM tblArHistPmt

END