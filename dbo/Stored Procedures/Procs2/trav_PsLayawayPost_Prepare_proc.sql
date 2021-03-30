
CREATE PROCEDURE dbo.trav_PsLayawayPost_Prepare_proc 
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @NextID int, @RecordCount int, @PaymentRecordCount int, @FunctionIDPSTRANHIST nvarchar(10), @FunctionIDPSPMTHIST nvarchar(10)

	SELECT @FunctionIDPSTRANHIST = 'PSTRANHIST', @FunctionIDPSPMTHIST = 'PSPMTHIST'

	--Completed layaway
	INSERT INTO #PsCompletedLayawayList(ID, TransID, InvoiceNum, InvoiceTotal, DistCode, LocID)
	SELECT h.ID, ROW_NUMBER() OVER (ORDER BY h.ID), h.TransIDPrefix + RIGHT(CAST(100000000 + h.TransID AS varchar),8), d.InvoiceTotal,
		c.DistCode, c.LocID
	FROM #PsHostList t INNER JOIN dbo.tblPsTransHeader h ON t.HostID = h.HostID 
		INNER JOIN (SELECT HeaderID, SUM(CASE WHEN LineType = -1 OR LineType = -4 THEN 0 ELSE SIGN(LineType) * ExtPrice END) AS InvoiceTotal
			FROM dbo.tblPsTransDetail GROUP BY HeaderID) d ON h.ID = d.HeaderID 
		LEFT JOIN dbo.tblPsConfig c ON h.ConfigID = c.ID
	WHERE h.TransType = 10 AND h.CompletedDate IS NOT NULL AND h.ID NOT IN (SELECT HeaderID FROM dbo.tblPsPayment WHERE HeaderID IS NOT NULL AND Synched = 0)
	
	SET @RecordCount = @@ROWCOUNT

	IF @RecordCount > 0
	BEGIN
		--Update TransID in ##PsCompletedLayawayList
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
		UPDATE #PsCompletedLayawayList SET TransID = RIGHT(CAST(100000000 + (TransID + @NextID - 1) AS varchar),8) 
	END

	--Synched incomplete layaway with synched and unposted payment.
	INSERT INTO #PsIncompleteLayawayList(ID, InvoiceNum, DistCode)
	SELECT h.ID, h.TransIDPrefix + RIGHT(CAST(100000000 + h.TransID AS varchar),8), c.DistCode
	FROM #PsHostList t INNER JOIN dbo.tblPsTransHeader h ON t.HostID = h.HostID 
		INNER JOIN (SELECT HeaderID FROM dbo.tblPsPayment WHERE HeaderID IS NOT NULL AND PostedYN = 0 AND Synched = 1 GROUP BY HeaderID) p ON h.ID = p.HeaderID 
		LEFT JOIN dbo.tblPsConfig c ON h.ConfigID = c.ID
	WHERE h.TransType = 10 AND h.Synched = 1 AND h.CompletedDate IS NULL

	--Unposted payment
	INSERT INTO #PsLayawayPaymentList(ID, TransID, LocID)
	SELECT p.ID, ROW_NUMBER() OVER (ORDER BY p.ID), p.LocID
	FROM (SELECT p.ID, c.LocID
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.HeaderID
		LEFT JOIN dbo.tblPsConfig c ON p.ConfigID = c.ID
	WHERE p.PostedYN = 0 --Unposted payment of completed layaway
	UNION ALL
	SELECT p.ID, LocID
	FROM #PsIncompleteLayawayList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.HeaderID 
		LEFT JOIN dbo.tblPsConfig c ON p.ConfigID = c.ID
	WHERE p.PostedYN = 0 AND p.Synched = 1 --synched and unposted payment of synched incomplete layaway
	) p 

	SET @PaymentRecordCount = @@ROWCOUNT

	IF @PaymentRecordCount > 0
	BEGIN
		--Update TransID in ##PsLayawayPaymentList
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
		UPDATE #PsLayawayPaymentList SET TransID = RIGHT(CAST(100000000 + (TransID + @NextID - 1) AS varchar),8)

	END

	SELECT @RecordCount + @PaymentRecordCount

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_Prepare_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_Prepare_proc';

