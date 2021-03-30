 CREATE Procedure dbo.ALP_qryCSBS_Batch_StoreErrorsB_sp 
	(
	@Transmitter varchar(36),
	@ErrorCode varchar(4),
	@BSCustId varchar(50),
	@BSSiteId varchar(50),
	@CSCustId varchar(50),
	@CSSiteId varchar(50),
	@BSMonStartDate varchar(50),
	@CSHasSignalsYn char(1) 
	) 
AS
SET NOCOUNT ON
INSERT INTO ALP_tblCSBSComparisonResultsErrors
	(Transmitter,
	ErrorCode,
	BSCustId,
	BSSiteId,
	CSCustId,
	CSSiteId,
	BSMonStartDate,
	CSHasSignalsYn )
values
	(
	@Transmitter,
	@ErrorCode,
	@BSCustId,
	@BSSiteId,
	@CSCustId,
	@CSSiteId,
	@BSMonStartDate,
	@CSHasSignalsYn 
	)