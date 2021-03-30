CREATE FUNCTION [dbo].[ufxALP_R_AR_R510f_Q003forComments] 
(	
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
	-- SMA.CompId, 
	-- SMA.TopicNum, 
	SMA.LinkKey, 
	SMA.EntryDate,
	SMA.ExpireDate, 
	SMA.Comment, 
	SMA.EnteredBy, 
	SMA.Status, 
	SMA.Description

FROM  tblSmAttachment AS SMA -- no view

WHERE SMA.LinkType='ARCUSTOMER'

)