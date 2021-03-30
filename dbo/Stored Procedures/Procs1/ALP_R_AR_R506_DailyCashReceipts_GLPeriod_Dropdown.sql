

CREATE PROCEDURE [dbo].[ALP_R_AR_R506_DailyCashReceipts_GLPeriod_Dropdown] 
AS
BEGIN
SET NOCOUNT ON;

SELECT distinct GLPeriod FROM tblArHistPmt order by GLPeriod

END