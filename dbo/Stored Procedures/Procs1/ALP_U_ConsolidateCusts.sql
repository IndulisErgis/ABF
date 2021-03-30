

CREATE PROCEDURE [dbo].[ALP_U_ConsolidateCusts]
(
	@NewCustId varchar(10), 
	@OldIdList varchar(110)  -- 10 chars X 10 Ids ending with 10 commas = 110
)
	-- param import: 
	-- the new master CustID (@NewCustId) to be consolidated into and 
	-- list of all Old IDs, 10 IDs max in comma delimited string  
AS
	
CREATE TABLE #Results (Msg varchar(100))


-- test for violation "Duplicate primary key"
--BEGIN TRY
--IF NOT EXISTS 
--	(
--	SELECT CustId from dbo.tblArHistFinch 
--	WHERE (CustId = @NewCustId)
--	UNION
--	SELECT CustId from tblArCustPmtMethod 
--	WHERE (CustId = @NewCustId)
--	UNION 
--	SELECT CustId from tblArHistAddress
--	WHERE (CustID = @NewCustId)
--	)
--END TRY	
--BEGIN CATCH
--		INSERT INTO #Results (Msg) SELECT ('Please Note! ')
--		INSERT INTO #Results (Msg) SELECT ('One or more CustIDs in this group cannot be consolidated.') 
--		INSERT INTO #Results (Msg) SELECT ('The consolidation would have resulted in incorrect customer data.')
--		INSERT INTO #Results (Msg) SELECT ('Please contact ABPro support for assistance.')
--				SELECT * FROM #Results

--		RETURN
--END CATCH

-- Continue and Consolidate

DECLARE @Original varchar(110)
SET @Original = @OldIdList
DECLARE @ErrCode int	
SET @ErrCode = 0
		
-- Populate temp table with Cust IDs from @OldIdList		
CREATE TABLE #ALP_tblCustidChanges (OldCustId varchar(10))			
DECLARE @Length int
DECLARE @comma int -- wheres the comma?
DECLARE @OldID varchar(10)	
		
WHILE LEN(@OldIdList) > 1
BEGIN

	SET @Length = Len(@OldIdList)
					--INSERT INTO #Results (Msg) SELECT ('OldIdList length = ' + cast(@Length as char))
	
	SET @comma = (PATINDEX('%,%',@OldIdList) )
					--INSERT INTO #Results (Msg) SELECT ('Comma location = ' + cast(@comma as char))
					
	SET @OldID = SUBSTRING(@OldIdList,1,@comma-1) 
					--INSERT INTO #Results (Msg) SELECT ('Id is ' + @OldId)
					
	INSERT INTO #ALP_tblCustidChanges VALUES (@OldID)
					--INSERT INTO #Results (Msg) SELECT * FROM #ALP_tblCustidChanges		
	
	SET @OldIdList = SUBSTRING(@OldIdList,@comma+1,@length )
				
					--INSERT INTO #Results (Msg) SELECT ('New Length = ' + cast(Len(@OldIdList) as char))					
					--INSERT INTO #Results (Msg) SELECT ('ID parsed.')
END	


-----------------------------------------------------------
BEGIN TRANSACTION 

	BEGIN TRY
			
		-- "Moving Contract data ..." 842aMoveContractToMasterCust	
			
				UPDATE dbo.ALP_tblArAlpCustContract 
				SET CustId = @NewCustId
				FROM dbo.ALP_tblArAlpCustContract INNER JOIN #ALP_tblCustidChanges 
				ON CustId = OldCustId
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('842a...')
									
 							
		-- "Moving System data ..." 842bMoveSysToMasterCust
			
				UPDATE dbo.ALP_tblArAlpSiteSys 
				SET CustId = @NewCustId 
				FROM dbo.ALP_tblArAlpSiteSys INNER JOIN #ALP_tblCustidChanges 
				ON CustId = OldCustId 
				WHERE CustId IN (select OldCustID from #ALP_tblCustidChanges)
			
				--INSERT INTO #Results (Msg) SELECT ('842b...')

				
		-- "Moving Recurring Bill data ..." 842c MoveRecBillToMasterCust
				
				UPDATE dbo.ALP_tblArAlpSiteRecBill 
				SET CustId = @NewCustId
				FROM dbo.ALP_tblArAlpSiteRecBill INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE CustId IN (select OldCustID from #ALP_tblCustidChanges)
			
				--INSERT INTO #Results (Msg) SELECT ('842c...')
						
			
		-- "Moving open AR data ..." 842d MoveOpenArToMasterCust
				
				UPDATE dbo.tblArOpenInvoice 
				SET CustId = @NewCustId
				FROM dbo.tblArOpenInvoice INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE CustId IN (select OldCustID from #ALP_tblCustidChanges)
			
				--INSERT INTO #Results (Msg) SELECT ('842d...')

				
				UPDATE dbo.ALP_tblArOpenInvoice 
				SET AlpCustId = @NewCustId
				FROM dbo.ALP_tblArOpenInvoice INNER JOIN #ALP_tblCustidChanges
				ON AlpCustId = OldCustId 
				WHERE AlpCustId IN (select OldCustID from #ALP_tblCustidChanges)
			
				--INSERT INTO #Results (Msg) SELECT ('842d2...')
				

		-- "Moving AR history data ..." 842e MoveArTransHistToMasterCust
				
				UPDATE dbo.tblArHistHeader 
				SET CustId = @NewCustId
				FROM dbo.tblArHistHeader INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
 				WHERE CustId IN (select OldCustID from #ALP_tblCustidChanges)
			
				--INSERT INTO #Results (Msg) SELECT ('842e...')

			
		-- perform each Update, changing the old cust to the new 
				-- "Moving AR payments data ..." 842f MoveArPmtHistToMasterCust
			
				UPDATE dbo.tblArHistPmt
				SET CustId = @NewCustId
				FROM dbo.tblArHistPmt INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
 				WHERE CustId IN (select OldCustID from #ALP_tblCustidChanges)
			
				--INSERT INTO #Results (Msg) SELECT ('842f...')

				
		-- "Moving Comments data ..." 842g MoveSmCommentsToMasterCust
			
				UPDATE dbo.tblSmAttachment
				SET LinkKey = @NewCustId
				FROM dbo.tblSmAttachment INNER JOIN #ALP_tblCustidChanges
				ON LinkKey = OldCustId 
				WHERE LinkKey IN (select OldCustID from #ALP_tblCustidChanges)
				AND LinkType = 'ARCUSTOMER'
				--INSERT INTO #Results (Msg) SELECT ('842g...')
		
			
		-- "Moving Jobs data ..." 842h MoveJobsToMasterCust
			
				UPDATE dbo.ALP_tblJmSvcTkt 
				SET CustId = @NewCustId
				FROM dbo.ALP_tblJmSvcTkt INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('842h...')
				--INSERT INTO #Results (Msg) SELECT ('Inactivating ALP_;')
				
------------Begin addnl changes---------------------------------	

				UPDATE dbo.ALP_tblArAlpRecBillRunRecords 
				SET CustId  = @NewCustId
				FROM dbo.ALP_tblArAlpRecBillRunRecords INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('ALP_tblArAlpRecBillRunRecords...')
				
				
				UPDATE dbo.ALP_tblArAlpSiteRecJob 
				SET CustId  = @NewCustId
				FROM ALP_tblArAlpSiteRecJob INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
				--INSERT INTO #Results (Msg) SELECT ('ALP_tblArAlpSiteRecJob...')


			--================================================================	


				IF NOT EXISTS 
				(
				--SELECT CustId from dbo.tblArHistFinch 
				--WHERE (CustId = @NewCustId)
				--UNION
				--SELECT CustId from tblArCustPmtMethod 
				--WHERE (CustId = @NewCustId)
				--UNION 
				SELECT CustId from tblArHistAddress
				WHERE (CustID = @NewCustId)
				)
				BEGIN
					UPDATE dbo.tblArHistAddress 
					SET CustId  = @NewCustId
					FROM dbo.tblArHistAddress INNER JOIN #ALP_tblCustidChanges
					ON CustId = OldCustId 
					WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
				END			
				
				--INSERT INTO #Results (Msg) SELECT ('tblArHistAddress...')					 
			--===============================================================	

			
				IF NOT EXISTS 
				(
				SELECT CustId from dbo.tblArHistFinch 
				WHERE (CustId = @NewCustId)
				--UNION
				--SELECT CustId from tblArCustPmtMethod 
				--WHERE (CustId = @NewCustId)
				--UNION 
				--SELECT CustId from tblArHistAddress
				--WHERE (CustID = @NewCustId)
				)
				BEGIN
					UPDATE dbo.tblArHistFinch 
					SET CustId  = @NewCustId
					FROM dbo.tblArHistFinch INNER JOIN #ALP_tblCustidChanges
					ON CustId = OldCustId 
					WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
				END
				--INSERT INTO #Results (Msg) SELECT ('tblArHistFinch...')
				
	--======================================================			


				--IF NOT EXISTS 
				--	(
				--	SELECT CustId from dbo.tblArHistFinch 
				--	WHERE (CustId = @NewCustId)
				--UNION
				--SELECT CustId from tblArCustPmtMethod 
				--WHERE (CustId = @NewCustId)
				--UNION 
				--SELECT CustId from tblArHistAddress
				--WHERE (CustID = @NewCustId)
				--)		
				--UPDATE dbo.tblArCustPmtMethod 
				--SET CustId  = @NewCustId
				--FROM dbo.tblArCustPmtMethod INNER JOIN #ALP_tblCustidChanges
				--ON CustId = OldCustId 
				--WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('tblArCustPmtMethod...')

  --==============================================================		


				UPDATE dbo.tblArHistDeposit 
				SET CustId  = @NewCustId
				FROM dbo.tblArHistDeposit INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('tblArHistDeposit...')	
		--=============================================		
				
	
				UPDATE dbo.tblArPaymentACH
				SET CustId  = @NewCustId
				FROM dbo.tblArPaymentACH INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('tblArPaymentACH...')
				
				
				UPDATE dbo.tblArPmtMethod 
				SET CustId  = @NewCustId
				FROM dbo.tblArPmtMethod INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('tblArPmtMethod...')
				
								
				UPDATE dbo.tblArRecurHeader
				SET CustId  = @NewCustId
				FROM dbo.tblArRecurHeader INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('tblArRecurHeader...')	
				
				
				UPDATE dbo.tblArShipTo 
				SET CustId  = @NewCustId
				FROM dbo.tblArShipTo INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('tblArShipTo...')
				
				
				UPDATE dbo.tblInMatReqDetail 
				SET CustId  = @NewCustId
				FROM dbo.tblInMatReqDetail INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('tblInMatReqDetail...')
				
				
				UPDATE dbo.tblPoHistDetail 
				SET CustId  = @NewCustId
				FROM dbo.tblPoHistDetail INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('tblPoHistDetail...')
				
				
				UPDATE dbo.tblPoPurchaseReq 
				SET CustId  = @NewCustId
				FROM dbo.tblPoPurchaseReq INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('tblPoPurchaseReq...')
				

				UPDATE dbo.tblPoTransDetail 
				SET CustId  = @NewCustId
				FROM dbo.tblPoTransDetail INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE (CustID IN (select OldCustID from #ALP_tblCustidChanges) )
			
				--INSERT INTO #Results (Msg) SELECT ('tblPoTransDetail...')	
				
				
				UPDATE dbo.ALP_tblArAlpSiteRecBillServ 
				SET CanCustId  = @NewCustId
				FROM dbo.ALP_tblArAlpSiteRecBillServ INNER JOIN #ALP_tblCustidChanges
				ON CanCustId = OldCustId 
				WHERE (CanCustId IN (select OldCustID from #ALP_tblCustidChanges) )
		
				--INSERT INTO #Results (Msg) SELECT ('ALP_tblArAlpSiteRecBillServ...')
		
		
				UPDATE dbo.tblArCust 
				SET BillToID  = @NewCustId
				FROM dbo.tblArCust INNER JOIN #ALP_tblCustidChanges
				ON BillToID = OldCustId 
				WHERE (BillToId IN (select OldCustID from #ALP_tblCustidChanges) )

				--INSERT INTO #Results (Msg) SELECT ('tblArCust...')
				
				---------------------------------------------
				-- Produces "Consolidated on Date 2013/10/1 with CustId: 000000JVH1"
				UPDATE dbo.ALP_tblArCust
				SET AlpComment =
				CASE WHEN AlpComment is not null 
				THEN 
					'Consolidated on Date ' +
					+ Convert( varchar(4), DATEPART(YEAR,GETDATE()) )
					+ '/' + Convert(varchar(2), DATEPART(MONTH,GETDATE()) )  
					+ '/' + Convert(varchar(2), DATEPART(DAY,GETDATE()) )
					+ ' with CustId: ' + @NewCustId + '. '
					+ convert(varchar(1000),AlpComment) 
				ELSE 
					'Consolidated on Date ' +
					+ Convert( varchar(4), DATEPART(YEAR,GETDATE()) )
					+ '/' + Convert(varchar(2), DATEPART(MONTH,GETDATE()) )  
					+ '/' + Convert(varchar(2), DATEPART(DAY,GETDATE()) )
					+ ' with CustId: ' + @NewCustId + '. '				
				END
				,AlpInactive = 1
				FROM dbo.ALP_tblArCust 
				WHERE AlpCustId IN (select OldCustID from #ALP_tblCustidChanges)

									
				--INSERT INTO #Results (Msg) SELECT ('Consolidation complete.')
				----------------------------------------------
				
				--INSERT INTO #Results (Msg) SELECT ('Inactivating 842i2 tblArCust...')	
							
				UPDATE dbo.tblArCust 
				SET Status = 1
				FROM dbo.tblArCust 
				WHERE CustId IN (select OldCustID from #ALP_tblCustidChanges)

			   INSERT INTO #Results (Msg) SELECT ('IDs: ' + @Original + ' now inactive.')			
	

COMMIT TRANSACTION	
			
		--INSERT INTO #Results (Msg) SELECT ('Transaction Committed.')
		INSERT INTO #Results (Msg) SELECT ('Consolidation Complete.')
	   SELECT * FROM #Results		
		RETURN (0)
END TRY


BEGIN CATCH	
		ROLLBACK TRANSACTION
		--INSERT INTO #Results (Msg) SELECT ('ROLLED BACK')
		SELECT * FROM #Results
		RETURN (1)
END CATCH		

INSERT INTO #Results (Msg) SELECT ('END Of Consolidation')
SELECT * FROM #Results