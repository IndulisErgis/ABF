
CREATE Procedure [dbo].[ALP_qryJm110o00CustComments_sp]
/* RecordSource for CustomerComments subform of Control Center */
	(
		@CompID varchar(3) = null,
		@CustID pCustid = null
	)
As
	set nocount on
	SELECT [User] = EnteredBy,
	      	[Date] =  EntryDate, 
	      	''  as Ref, 
               	Comment = Comment, 
		LinkKey
	FROM tblSmAttachment 
	WHERE ((LinkType ='Customer') 
			AND (LinkKey= @CustID))
	ORDER BY EntryDate DESC
	return