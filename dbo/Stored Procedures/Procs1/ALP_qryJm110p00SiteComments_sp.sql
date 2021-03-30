

CREATE Procedure [dbo].[ALP_qryJm110p00SiteComments_sp]
/* RecordSource for Site Comments subform of Control Center */
	(
		@CompID varchar(3) = null,
		@SiteID varchar(10) = null
	)
As
	set nocount on
	SELECT [User] = EnteredBy,
	       	[Date] =  EntryDate, 
	      ''  as Ref, 
               	Comments = Comment, 
		LinkKey
	FROM tblSmAttachment
	WHERE ( LinkType ='Sites') 
		AND (LinkKey = @SiteID )
	ORDER BY EntryDate DESC
	return