
CREATE PROCEDURE dbo.trav_PsTransPost_Prepare_proc 
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @NextID int, @RecordCount int, @PaymentRecordCount int, @FunctionIDPSTRANHIST nvarchar(10), @FunctionIDPSPMTHIST nvarchar(10)

	SELECT @FunctionIDPSTRANHIST = 'PSTRANHIST', @FunctionIDPSPMTHIST = 'PSPMTHIST'

	INSERT INTO #PsTransList(ID, TransID, InvoiceNum, InvoiceTotal, NetDue, DistCode, LocID)
	SELECT h.ID, ROW_NUMBER() OVER (ORDER BY h.ID), h.TransIDPrefix + RIGHT(CAST(100000000 + h.TransID AS varchar),8), d.InvoiceTotal, d.NetDue,
		c.DistCode, c.LocID
	FROM #PsHostList t INNER JOIN dbo.tblPsTransHeader h ON t.HostID = h.HostID 
		INNER JOIN (SELECT HeaderID, SUM(CASE WHEN LineType = -1 OR LineType = -4 THEN 0 ELSE SIGN(LineType) * ExtPrice END) AS InvoiceTotal,
			SUM(SIGN(LineType) * ExtPrice) AS NetDue
			FROM dbo.tblPsTransDetail GROUP BY HeaderID) d ON h.ID = d.HeaderID 
		LEFT JOIN dbo.tblPsConfig c ON h.ConfigID = c.ID
	WHERE h.TransType IN (1, -1) AND Synched = 1 AND h.ID NOT IN (SELECT HeaderID FROM dbo.tblPsPayment WHERE HeaderID IS NOT NULL AND Synched = 0)
	
	SET @RecordCount = @@ROWCOUNT

	INSERT INTO #PsPaymentList(ID, TransID, DistCode, LocID)
	SELECT p.ID, ROW_NUMBER() OVER (ORDER BY p.ID), p.DistCode, p.LocID
	FROM (SELECT p.ID, c.DistCode, c.LocID
	FROM #PsHostList t INNER JOIN dbo.tblPsPayment p ON t.HostID = p.HostID 
		LEFT JOIN dbo.tblPsConfig c ON p.ConfigID = c.ID
	WHERE p.HeaderID iS NULL AND p.Synched = 1 AND p.PostedYN = 0
	UNION ALL
	SELECT p.ID, NULL AS DistCode, c.LocID
	FROM #PsTransList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.HeaderID 
		LEFT JOIN dbo.tblPsConfig c ON p.ConfigID = c.ID
	WHERE p.Synched = 1 AND p.PostedYN = 0) p

	SET @PaymentRecordCount = @@ROWCOUNT

	IF @RecordCount > 0
	BEGIN
		--Update TransID in #PsTransList
		SELECT @NextID = NextID FROM dbo.tblSmTransID WITH (ROWLOCK) WHERE FunctionID = @FunctionIDPSTRANHIST
		IF @NextID IS NOT NULL
		BEGIN
			UPDATE dbo.tblSmTransID WITH (ROWLOCK) SET NextID = @NextID + @RecordCount WHERE FunctionID = @FunctionIDPSTRANHIST
		END
		ELSE
		BEGIN
			SET @NextID = 1
			INSERT INTO dbo.tblSmTransID (FunctionID, NextID)
			VALUES (@FunctionIDPSTRANHIST, @RecordCount + 1)
		END
		UPDATE #PsTransList SET TransID = RIGHT(CAST(100000000 + (TransID + @NextID - 1) AS varchar),8)

	END

	IF @PaymentRecordCount > 0
	BEGIN
		--Update TransID in #PsPaymentList
		SET @NextID = NULL
		SELECT @NextID = NextID FROM dbo.tblSmTransID WITH (ROWLOCK) WHERE FunctionID = @FunctionIDPSPMTHIST
		IF @NextID IS NOT NULL
		BEGIN
			UPDATE dbo.tblSmTransID WITH (ROWLOCK) SET NextID = @NextID + @PaymentRecordCount WHERE FunctionID = @FunctionIDPSPMTHIST
		END
		ELSE
		BEGIN
			SET @NextID = 1
			INSERT INTO dbo.tblSmTransID (FunctionID, NextID)
			VALUES (@FunctionIDPSPMTHIST, @PaymentRecordCount + 1)
		END
		UPDATE #PsPaymentList SET TransID = RIGHT(CAST(100000000 + (TransID + @NextID - 1) AS varchar),8)

	END

	SELECT @RecordCount + @PaymentRecordCount

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_Prepare_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_Prepare_proc';

