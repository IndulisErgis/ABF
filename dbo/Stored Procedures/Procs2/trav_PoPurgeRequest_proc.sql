CREATE PROCEDURE [dbo].[trav_PoPurgeRequest_proc]
	@DateNew datetime,
	@DatePending datetime,
	@DateDecline datetime,
	@DateApproved datetime
AS
SET NOCOUNT ON;
BEGIN TRY
	DECLARE @loop int;
	DECLARE @date datetime;
	CREATE TABLE #Results (TransId pTransId);
	
	SET @loop = 0
	WHILE @loop < 4
	BEGIN
		DELETE FROM #Results;
		SET @date = CASE @loop WHEN 0 THEN @DateNew WHEN 1 THEN @DatePending WHEN 2 THEN @DateApproved WHEN 3 THEN @DateDecline ELSE NULL END;
		
		IF @date IS NOT NULL
		BEGIN
			DELETE FROM #Results;
			
			IF (@loop != 2)
			BEGIN			
				INSERT INTO #Results (TransId)
				SELECT t.TransId
				FROM dbo.tblPoTransRequest t (NOLOCK)
					LEFT JOIN dbo.tblPoTransRequestResponse r (NOLOCK) ON t.TransId = r.TransId
				WHERE [Status] = @loop
				GROUP BY t.TransId
				HAVING MAX(CASE WHEN @loop IN (1, 3) 
						THEN ISNULL(CAST(FLOOR(CAST(r.ResponseDate as float)) as datetime), t.RequestedDate)
						WHEN @loop = 2 THEN t.ApprovedDate
						ELSE t.RequestedDate 
					END) <= @date
				
				DELETE d
				FROM #Results r
					INNER JOIN dbo.tblPoTransRequestBudget d ON r.TransId = d.TransID
					
				DELETE d
				FROM #Results r
					INNER JOIN dbo.tblPoTransRequestResponse d ON r.TransId = d.TransID
					
				DELETE d
				FROM #Results r
					INNER JOIN dbo.tblPoTransRequestStatus d ON r.TransId = d.TransID
				
				DELETE d
				FROM #Results r
					INNER JOIN dbo.tblPoTransDetail d ON r.TransId = d.TransID
					
				DELETE d
				FROM #Results r
					INNER JOIN dbo.tblPoTransHeader d ON r.TransId = d.TransID
					
				DELETE d
				FROM #Results r
					INNER JOIN dbo.tblPoTransRequest d ON r.TransId = d.TransID
					
				DELETE d
				FROM #Results r
					INNER JOIN dbo.tblPoTransDetailLandedCost d ON r.TransId = d.TransID
			END
			ELSE
			BEGIN			
				INSERT INTO #Results (TransId)
				SELECT t.TransId
				FROM dbo.tblPoTransRequest t (NOLOCK)
					LEFT JOIN dbo.tblPoTransRequestResponse r (NOLOCK) ON t.TransId = r.TransId
				WHERE [Status] = @loop
				GROUP BY t.TransId
				HAVING MAX(CASE WHEN @loop IN (1, 3) 
						THEN ISNULL(CAST(FLOOR(CAST(r.ResponseDate as float)) as datetime), t.RequestedDate)
						WHEN @loop = 2 THEN t.ApprovedDate
						ELSE t.RequestedDate 
					END) <= @date				
				
				DELETE d
				FROM #Results r
					INNER JOIN dbo.tblPoHistRequestBudget d ON r.TransId = d.TransID
					
				DELETE d
				FROM #Results r
					INNER JOIN dbo.tblPoHistRequestResponse d ON r.TransId = d.TransID
					
				DELETE d
				FROM #Results r
					INNER JOIN dbo.tblPoHistRequestHeader d ON r.TransId = d.TransID
					
				DELETE d
				FROM #Results r
					INNER JOIN dbo.tblPoHistRequestDetail d ON r.TransId = d.TransID
					
				DELETE d
				FROM #Results r
					INNER JOIN dbo.tblPoTransRequest d ON r.TransId = d.TransID
			END
		END
		SET @loop = @loop + 1
	END
	
	DROP TABLE #Results;
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPurgeRequest_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPurgeRequest_proc';

