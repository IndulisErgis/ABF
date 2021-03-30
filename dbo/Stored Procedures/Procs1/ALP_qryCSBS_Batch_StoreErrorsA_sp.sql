       CREATE Procedure dbo.ALP_qryCSBS_Batch_StoreErrorsA_sp
	(@Transmitter varchar(36))
AS
SET NOCOUNT ON
If NOT EXISTS (SELECT Transmitter FROM dbo.ALP_tblCSBSComparisonResults
		WHERE Transmitter = @Transmitter)
	INSERT INTO dbo.ALP_tblCSBSComparisonResults (Transmitter)values(@Transmitter)