

CREATE PROCEDURE [dbo].[ALP_R_AR_R510a_CommentsSubRpt] 
(	
	@CustID varchar(10)=null,
	@StartDate datetime = null,
	@EndDate datetime = null
)
AS
BEGIN
	SET NOCOUNT ON;

SELECT 
SubQ003.LinkKey, 
SubQ003.EntryDate, 

CASE SubQ003.Status
	WHEN 0 THEN 'Public' ELSE 'Private' END AS Private , 
SubQ003.EnteredBy, 
SubQ003.Comment

FROM ufxALP_R_AR_R510f_Q003forComments() AS SubQ003

WHERE 
SubQ003.EntryDate >= isnull(@StartDate,'1/1/1900')  
And 
SubQ003.EntryDate <= isnull(@EndDate,GETDATE() )
AND(@CustID IS NULL OR @CustID=SubQ003.LinkKey)

ORDER BY SubQ003.LinkKey, SubQ003.EntryDate DESC


END