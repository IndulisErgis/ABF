
CREATE PROCEDURE [dbo].[ALP_qryJmUpdateNextRecJobProcDate]
@NextDate datetime
As
SET NOCOUNT ON
UPDATE ALP_tblJmOption 
SET ALP_tblJmOption.DfltRecJobProcDate = @NextDate