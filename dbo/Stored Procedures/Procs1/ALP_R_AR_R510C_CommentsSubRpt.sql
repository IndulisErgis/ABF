

CREATE PROCEDURE [dbo].[ALP_R_AR_R510C_CommentsSubRpt] 
(	
	@CustID varchar(10)=null,
	@StartDate datetime = null,
	@EndDate datetime = null
)
AS
BEGIN
	SET NOCOUNT ON;
	
--DECLARE @CustID varchar(10)
--declare
--SET @StartDate='01-01-2011'
--set @EndDate='12-31-2013'
--set @CustID = '104450'
SELECT 
SubQ003.LinkKey, 
SubQ003.EntryDate, 

CASE SubQ003.Status
	WHEN 0 THEN 'Public' ELSE 'Private' END AS Private , 
SubQ003.EnteredBy, 
SubQ003.Comment

FROM ufxALP_R_AR_R510f_Q003forComments() AS SubQ003

WHERE 
--SubQ003.EntryDate >= isnull(@StartDate,'1/1/1900')  
--And 
--SubQ003.EntryDate <= isnull(@EndDate,GETDATE() )
--AND(@CustID IS NULL OR @CustID=SubQ003.LinkKey)

SubQ003.EntryDate >= @StartDate  
And 
SubQ003.EntryDate <= @EndDate
AND(@CustID=SubQ003.LinkKey)

ORDER BY LinkKey,EntryDate DESC


END