

CREATE PROCEDURE dbo.ALP_qryJmGetCentralID_sp
--created MAH 07/13/04  - for SIMS Integration 
(
@SysID integer,
@CentralID integer OUTPUT
)
AS

SELECT @CentralID = 
	(SELECT CS = CASE WHEN CentralID is null THEN 0 
				ELSE CentralID
				END
	 FROM ALP_tblArAlpSiteSys
	 WHERE SysID = @SysID)