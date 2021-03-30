CREATE PROCEDURE Alp_UpdateRecurringJobforSiteCancel
	( @pRecJobEntryId int ,@pCheck bit,@pServiceEndDate Date)
AS
 BEGIN
		IF (@pCheck= 0)
		BEGIN 
			UPDATE ALP_tblArAlpSiteRecJob 
			SET RecBillEntryId =null,RecSvcId =null 
			WHERE RecJobEntryId = @pRecJobEntryId
		END
		
		IF (@pCheck=1)
		BEGIN
			UPDATE ALP_tblArAlpSiteRecJob 
			SET RecBillEntryId =null,RecSvcId =null,ExpirationDate =@pServiceEndDate 
			WHERE RecJobEntryId = @pRecJobEntryId
		END
 END