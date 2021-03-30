
CREATE PROCEDURE [dbo].[ALP_qrySmComments_sp]
(
@Type varchar(10) = null,
@CustID varchar(10)=null,
@SiteID int=null,
@StartDate datetime = null,
@EndDate datetime = null
)
AS
BEGIN
SET NOCOUNT ON;
SELECT
SMA.LinkType,
SMA.LinkKey,
SMA.EntryDate,
SMA.ExpireDate,
SMA.Comment,
SMA.EnteredBy,
--CASE SMA.Status
-- WHEN 0 THEN 'Public' ELSE 'Private' END AS Private,
SMA.Description,
--SMA.FileName added by NSK on 19 Aug 2014
SMA.FileName 

FROM tblSmAttachment AS SMA
WHERE SMA.[Status] = 0 --select only 'public' comments
AND
(@Type IS NULL OR SMA.LinkType=@Type)
AND
SMA.EntryDate >= isnull(@StartDate,'1/1/1900')
And
SMA.EntryDate <= isnull(@EndDate,GETDATE() )
AND
(((@CustID IS NULL OR @CustID=SMA.LinkKey) AND SMA.LinkType='ARCUSTOMER')
OR
((@SiteID IS NULL OR @SiteID=SMA.LinkKey) AND SMA.LinkType='ARALPSITE'))


ORDER BY SMA.LinkKey, SMA.EntryDate DESC


END