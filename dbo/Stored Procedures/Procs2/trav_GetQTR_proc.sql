
CREATE PROCEDURE [dbo].[trav_GetQTR_proc]
@CurrYr smallint,
@Period smallint,
@PeriodPerYear smallint,
@Qtr smallint OUT,
@PdFrom smallint OUT,
@PdThru smallint OUT

AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @qpd smallint

	SET @qpd = @PeriodPerYear / 4

	SELECT @qtr=qtr FROM
	(SELECT CASE WHEN glperiod <= @qpd THEN 1 
		WHEN glperiod <= (@qpd * 2) THEN 2
		WHEN glperiod <= (@qpd * 3) THEN 3
		WHEN glperiod <= (@qpd * 4) THEN 4
		ELSE 0 END qtr, glperiod FROM dbo.tblsmperiodconversion WHERE glyear = @CurrYr) q
	WHERE glperiod = @period

	SELECT @pdfrom = MIN(glperiod), @pdthru = MAX(glperiod) FROM
	(SELECT CASE WHEN glperiod <= @qpd THEN 1 
		WHEN glperiod <= (@qpd * 2) THEN 2
		WHEN glperiod <= (@qpd * 3) THEN 3
		WHEN glperiod <= (@qpd * 4) THEN 4
		ELSE 0 END qtr, glperiod FROM dbo.tblsmperiodconversion WHERE glyear = @CurrYr) q
	WHERE qtr = @qtr

	--select @qpd,@qtr,@pdfrom,@pdthru
	SET @pdthru = CASE WHEN @pdthru > @period THEN @period ELSE @pdthru END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GetQTR_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GetQTR_proc';

