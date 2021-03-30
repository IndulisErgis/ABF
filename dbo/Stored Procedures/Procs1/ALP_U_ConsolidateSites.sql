

CREATE PROCEDURE [dbo].[ALP_U_ConsolidateSites]
(
	@NewSiteId varchar(10), 
	@OldIdList varchar(110)  -- 10 chars X 10 Ids ending with 10 commas = 110
)
AS
	-- param import of a new master SiteID (@NewSiteId) destination AND 
	-- the source list of all Old IDs[10 IDs max in comma delimited string]  
	
	-- build table of OLD Site IDs from @OldIdList param
	CREATE TABLE #ALP_tblSiteIdChanges (OldSiteId varchar(10))
	-- build table of results to return as recordset
	CREATE TABLE #Results (Msg varchar(100))
	-- preserve orig param for later use
	DECLARE @Original varchar(110)
	SET @Original = @OldIdList
			
DECLARE @Length int
DECLARE @comma int -- for where's-the-comma
DECLARE @OldID varchar(10)	
		
WHILE LEN(@OldIdList) > 1
BEGIN

	SET @Length = Len(@OldIdList)
					--INSERT INTO #Results (Msg) SELECT ('OldIdList length = ' + cast(@Length as char))
	
	SET @comma = (PATINDEX('%,%',@OldIdList) )
					--INSERT INTO #Results (Msg) SELECT ('Comma location = ' + cast(@comma as char))
					
	SET @OldID = SUBSTRING(@OldIdList,1,@comma-1) 
					--INSERT INTO #Results (Msg) SELECT ('Id is ' + @OldId)
					
	INSERT INTO #ALP_tblSiteIdChanges (OldSiteId) VALUES (@OldID)
	
	
	SET @OldIdList = SUBSTRING(@OldIdList,@comma+1,@length )
					INSERT INTO #Results (Msg) SELECT ('ID parsed')
					--INSERT INTO #Results (Msg) SELECT ('Remaining Length = ' + cast(Len(@OldIdList) as char))					
					
END

-----------------------------------------------------------
BEGIN TRANSACTION 
	BEGIN TRY
			-- 843a1 RenameOldSysIfDuplicateInMasterSite
			UPDATE dbo.ALP_tblArAlpSiteSys_view  
			SET SysDesc = SysDesc + ' - from old site'
			WHERE SiteId IN (SELECT OldSiteID from #ALP_tblSiteIdChanges)
			
			INSERT INTO #Results (Msg) SELECT ('Consolidating into ' + @NewSiteId)
			--INSERT INTO #Results (Msg) SELECT ('843a1;')
									

 			-- 843a MoveSysToMasterSite				
			UPDATE dbo.ALP_tblArAlpSiteSys_view 
			SET SiteId = @NewSiteId
			WHERE SiteId IN (SELECT OldSiteID from #ALP_tblSiteIdChanges)
			--INNER JOIN #ALP_tblSiteIdChanges AS SC 
			--ON SS.SiteId = SC.OldSiteId 

			--INSERT INTO #Results (Msg) SELECT ('843a;')

			-- 843b MoveRecBillToMasterSite	
			UPDATE dbo.ALP_tblArAlpSiteRecBill_view 
			SET SiteId = @NewSiteId
			WHERE SiteId IN (SELECT OldSiteID from #ALP_tblSiteIdChanges)
			--INNER JOIN tblSiteIdChanges AS SC 
			--ON RB.SiteId = SC.OldSiteId 

			--INSERT INTO #Results (Msg) SELECT ('843b;')
						
			-- 843c MoveOpenArToMasterSite
			UPDATE dbo.ALP_tblArOpenInvoice 
			SET AlpSiteID = @NewSiteId
			WHERE AlpSiteID IN (SELECT OldSiteID from #ALP_tblSiteIdChanges)
			--INNER JOIN tblSiteIdChanges AS SC 
			--ON OI.AlpSiteID=SC.OldSiteId 

			--INSERT INTO #Results (Msg) SELECT ('843c;')

			-- 843d MoveArTransHistToMasterSite
		
			UPDATE dbo.ALP_tblArHistHeader_view
			SET AlpSiteID = @NewSiteId
			WHERE AlpSiteID IN (SELECT OldSiteID from #ALP_tblSiteIdChanges)
			--INNER JOIN tblSiteIdChanges AS SC 
			--ON HH.AlpSiteID = SC.OldSiteId 
			
			--INSERT INTO #Results (Msg) SELECT ('843d;')
		
		
			UPDATE dbo.ALP_tblArAlpSiteContact_view 
			SET SiteId = @NewSiteId		
			WHERE SiteID IN (SELECT OldSiteID from #ALP_tblSiteIdChanges)
			--INNER JOIN tblSiteIdChanges AS IdChg 
			--ON SCon.SiteId = IdChg.OldSiteId 

			--INSERT INTO #Results (Msg) SELECT ('843e;')

			-- 843f MoveJobsToMasterSite
			UPDATE dbo.ALP_tblJmSvcTkt 
			SET SiteId = @NewSiteId
			WHERE SiteID IN (SELECT OldSiteID from #ALP_tblSiteIdChanges)			
			--INNER JOIN tblSiteIdChanges AS IdChg 
			--ON ST.SiteId = IdChg.OldSiteId 

			--INSERT INTO #Results (Msg) SELECT ('843f;')

			-- 843g MoveProjectsToMasterSite				
			UPDATE dbo.ALP_tblJmSvcTktProject 
			SET SiteId = @NewSiteId	
			WHERE SiteId IN (SELECT OldSiteID from #ALP_tblSiteIdChanges)		
			--INNER JOIN tblSiteIdChanges AS IdChg 
			--ON TP.SiteId = IdChg.OldSiteId 

			--INSERT INTO #Results (Msg) SELECT ('843g;')
		
		
			-- 843h MoveSmCommentsToMasterSite
			UPDATE dbo.tblSmAttachment 
			SET LinkKey = @NewSiteId
			WHERE LinkType = 'SISITE' AND
			LinkKey IN (SELECT OldSiteID from #ALP_tblSiteIdChanges)		
			--INNER JOIN tblSiteIdChanges 
			--ON dbo_tblSmCmntDetail.Id=CSTR([tblSiteIdChanges].[OldSiteId]) 	
			--INSERT INTO #Results (Msg) SELECT ('843h;')
		

			-- 843i DeleteDupSite			
			UPDATE dbo.ALP_tblArAlpSite_view 
			SET Status = 'Inactive' 
			WHERE SiteId IN (SELECT OldSiteID from #ALP_tblSiteIdChanges)
											
			--INSERT INTO #Results (Msg) SELECT ('843i ALP_inactivated;')
		   INSERT INTO #Results (Msg) SELECT (@Original + ' inactivated;')			
	
COMMIT TRANSACTION	
			
		INSERT INTO #Results (Msg) SELECT ('COMMITTED;')
		INSERT INTO #Results (Msg) SELECT ('Consolidation Successful.')

	   SELECT * FROM #Results		
		RETURN (0)
END TRY


BEGIN CATCH	
		ROLLBACK TRANSACTION
		INSERT INTO #Results (Msg) SELECT ('ROLLED BACK')
		SELECT * FROM #Results
		RETURN (1)
END CATCH