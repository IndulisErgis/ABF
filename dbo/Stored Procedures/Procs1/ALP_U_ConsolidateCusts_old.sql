
CREATE PROCEDURE [dbo].[ALP_U_ConsolidateCusts_old]
(
	@NewCustId varchar(10), 
	@OldIdList varchar(110)  -- 10 chars X 10 Ids ending with 10 commas = 110
)
AS
	-- param import: 
	-- the new master CustID (@NewCustId) to be consolidated into and 
	-- list of all Old IDs, 10 IDs max in comma delimited string  
	-- build temp table containing OLD Cust IDs from @OldIdList
	
CREATE TABLE #ALP_tblCustidChanges (OldCustId varchar(10))
CREATE TABLE #Results (Msg varchar(100))

DECLARE @Original varchar(110)
SET @Original = @OldIdList
			
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
	
	
	SET @OldIdList = SUBSTRING(@OldIdList,@comma+1,@length )
					INSERT INTO #Results (Msg) SELECT ('After removing the ID, the list is now = ' + @OldIdList)
					INSERT INTO #Results (Msg) SELECT ('New Length = ' + cast(Len(@OldIdList) as char))					
					

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
			
				INSERT INTO #Results (Msg) SELECT ('842a done;')
									
 							
		-- "Moving System data ..." 842bMoveSysToMasterCust
			
				UPDATE dbo.ALP_tblArAlpSiteSys 
				SET CustId = @NewCustId 
				FROM dbo.ALP_tblArAlpSiteSys INNER JOIN #ALP_tblCustidChanges 
				ON CustId = OldCustId 
				WHERE CustId IN (select OldCustID from #ALP_tblCustidChanges)
			
				INSERT INTO #Results (Msg) SELECT ('842b done;')

				
		-- "Moving Recurring Bill data ..." 842c MoveRecBillToMasterCust
				
				UPDATE dbo.ALP_tblArAlpSiteRecBill 
				SET CustId = @NewCustId
				FROM dbo.ALP_tblArAlpSiteRecBill INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE CustId IN (select OldCustID from #ALP_tblCustidChanges)
			
				INSERT INTO #Results (Msg) SELECT ('842c done;')
						
			
		-- "Moving open AR data ..." 842d MoveOpenArToMasterCust
				
				UPDATE dbo.tblArOpenInvoice 
				SET CustId = @NewCustId
				FROM dbo.tblArOpenInvoice INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
				WHERE CustId IN (select OldCustID from #ALP_tblCustidChanges)
			
				INSERT INTO #Results (Msg) SELECT ('842d done;')

				
				UPDATE dbo.ALP_tblArOpenInvoice 
				SET AlpCustId = @NewCustId
				FROM dbo.ALP_tblArOpenInvoice INNER JOIN #ALP_tblCustidChanges
				ON AlpCustId = OldCustId 
				WHERE AlpCustId IN (select OldCustID from #ALP_tblCustidChanges)
			
				INSERT INTO #Results (Msg) SELECT ('842d2 done;')
				

		-- "Moving AR history data ..." 842e MoveArTransHistToMasterCust
				
				UPDATE dbo.tblArHistHeader 
				SET CustId = @NewCustId
				FROM dbo.tblArHistHeader INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
 				WHERE CustId IN (select OldCustID from #ALP_tblCustidChanges)
			
				INSERT INTO #Results (Msg) SELECT ('842e done;')

			
		-- perform each Update, changing the old cust to the new 
				-- "Moving AR payments data ..." 842f MoveArPmtHistToMasterCust
			
				UPDATE dbo.tblArHistPmt
				SET CustId = @NewCustId
				FROM dbo.tblArHistPmt INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
 				WHERE CustId IN (select OldCustID from #ALP_tblCustidChanges)
			
				INSERT INTO #Results (Msg) SELECT ('842f done;')

				
		-- "Moving Comments data ..." 842g MoveSmCommentsToMasterCust
			
				UPDATE dbo.tblSmAttachment
				SET LinkKey = @NewCustId
				FROM dbo.tblSmAttachment INNER JOIN #ALP_tblCustidChanges
				ON LinkKey = OldCustId 
				WHERE LinkKey IN (select OldCustID from #ALP_tblCustidChanges)
				AND LinkType = 'ARCUSTOMER'
				INSERT INTO #Results (Msg) SELECT ('842g done;')
		
			
		-- "Moving Jobs data ..." 842h MoveJobsToMasterCust
			
				UPDATE dbo.ALP_tblJmSvcTkt 
				SET CustId = @NewCustId
				FROM dbo.ALP_tblJmSvcTkt INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('842h done;')
				INSERT INTO #Results (Msg) SELECT ('Preparing to inactivate from ALP;')
				
------------Begin template for addnl changes---------------------------------	

				--UPDATE dbo.ALP_ 
				--SET SomeId  = @NewCustId
				--FROM dbo.ALP_ INNER JOIN #ALP_tblCustidChanges
				--ON SomeId = OldCustId 
			
				--INSERT INTO #Results (Msg) SELECT (' done;')

------------End template for addnl changes---------------------------------	

				UPDATE dbo.ALP_tblArAlpRecBillRunRecords 
				SET CustId  = @NewCustId
				FROM dbo.ALP_tblArAlpRecBillRunRecords INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('ALP_tblArAlpRecBillRunRecords done;')
				
				
				UPDATE dbo.ALP_tblArAlpSiteRecJob 
				SET CustId  = @NewCustId
				FROM ALP_tblArAlpSiteRecJob INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('ALP_tblArAlpSiteRecJob done;')
				
				UPDATE dbo.tblArCustPmtMethod 
				SET CustId  = @NewCustId
				FROM dbo.tblArCustPmtMethod INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('tblArCustPmtMethod done;')

					
				UPDATE dbo.tblArHistAddress 
				SET CustId  = @NewCustId
				FROM dbo.tblArHistAddress INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('tblArHistAddress done;')
					
				
				UPDATE dbo.tblArHistDeposit 
				SET CustId  = @NewCustId
				FROM dbo.tblArHistDeposit INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('tblArHistDeposit done;')	
				
				
				UPDATE dbo.tblArHistFinch 
				SET CustId  = @NewCustId
				FROM dbo.tblArHistFinch INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('tblArHistFinch done;')
				
	
				UPDATE dbo.tblArPaymentACH
				SET CustId  = @NewCustId
				FROM dbo.tblArPaymentACH INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('tblArPaymentACH done;')
				
				
				UPDATE dbo.tblArPmtMethod 
				SET CustId  = @NewCustId
				FROM dbo.tblArPmtMethod INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('tblArPmtMethod done;')
				
								
				UPDATE dbo.tblArRecurHeader
				SET CustId  = @NewCustId
				FROM dbo.tblArRecurHeader INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('tblArRecurHeader done;')	
				
				
				UPDATE dbo.tblArShipTo 
				SET CustId  = @NewCustId
				FROM dbo.tblArShipTo INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('tblArShipTo done;')
				
				
				UPDATE dbo.tblInMatReqDetail 
				SET CustId  = @NewCustId
				FROM dbo.tblInMatReqDetail INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('tblInMatReqDetail done;')
				
				
				UPDATE dbo.tblPoHistDetail 
				SET CustId  = @NewCustId
				FROM dbo.tblPoHistDetail INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('tblPoHistDetail done;')
				
				
				UPDATE dbo.tblPoPurchaseReq 
				SET CustId  = @NewCustId
				FROM dbo.tblPoPurchaseReq INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('tblPoPurchaseReq done;')
				

				UPDATE dbo.tblPoTransDetail 
				SET CustId  = @NewCustId
				FROM dbo.tblPoTransDetail INNER JOIN #ALP_tblCustidChanges
				ON CustId = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT ('tblPoTransDetail done;')	
				
				
				UPDATE dbo.ALP_tblArAlpSiteRecBillServ 
				SET CanCustId  = @NewCustId
				FROM dbo.ALP_tblArAlpSiteRecBillServ INNER JOIN #ALP_tblCustidChanges
				ON CanCustId = OldCustId 
		
				INSERT INTO #Results (Msg) SELECT ('ALP_tblArAlpSiteRecBillServ done;')
		
		
				UPDATE dbo.tblArCust 
				SET BillToID  = @NewCustId
				FROM dbo.tblArCust INNER JOIN #ALP_tblCustidChanges
				ON BillToID = OldCustId 
			
				INSERT INTO #Results (Msg) SELECT (' done;')
				
				---------------------------------------------
				UPDATE dbo.ALP_tblArCust 
				SET AlpInactive = 1
				FROM dbo.ALP_tblArCust 
				WHERE AlpCustId  
				IN (select OldCustID from #ALP_tblCustidChanges)
									
				INSERT INTO #Results (Msg) SELECT ('842i ALP_inactivated;')
				INSERT INTO #Results (Msg) SELECT ('Preparing to inactivate 842i2 ArCust;')	
							
				UPDATE dbo.tblArCust 
				SET Status = 1
				FROM dbo.tblArCust 
				WHERE CustId  
				IN (select OldCustID from #ALP_tblCustidChanges)

			   INSERT INTO #Results (Msg) SELECT (@Original + ' inactivated;')			
	

COMMIT TRANSACTION	
			
		INSERT INTO #Results (Msg) SELECT ('COMMITTED;')
	   SELECT * FROM #Results		
		RETURN (0)
END TRY


BEGIN CATCH	
		ROLLBACK TRANSACTION
		INSERT INTO #Results (Msg) SELECT ('ROLLED BACK')
		SELECT * FROM #Results
		RETURN (1)
END CATCH