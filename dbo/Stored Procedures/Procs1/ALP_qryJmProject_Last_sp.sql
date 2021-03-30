

CREATE PROCEDURE dbo.ALP_qryJmProject_Last_sp
--Created 10/27/04 MAH for EFI# 1532
	(
	@LastProjectID int = 0 OUTPUT	
	)
AS
Set NOCOUNT on
SET @LastProjectID = 0
SET @LastProjectID = (SELECT max(SvcTktProjectID)
			FROM ALP_tblJmSvcTktProject)