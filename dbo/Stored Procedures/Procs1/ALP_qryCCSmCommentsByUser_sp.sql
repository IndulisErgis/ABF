CREATE PROCEDURE [dbo].[ALP_qryCCSmCommentsByUser_sp]    
(    
@Type varchar(10) = null,    
@CustID varchar(10)=null,    
@SiteID int=null,
@UserId varchar(50)=null--added by NSK on 20 Jan 2016 
)  
--modified to take Alpine userID length of 50 from 20, but comparison will use only first 20 characters, due to TRaverse limit  
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
CASE SMA.Status -- Uncommented by NSK on Sep 15 2014    
WHEN 0 THEN 'Public' ELSE 'Private' END AS Status,    
SMA.Description,    
  --SMA.FileName added by NSK on 18 Nov 2015     
SMA.FileName   
FROM tblSmAttachment AS SMA    
WHERE     
--Below line commented by NSK on 15 Sep 2014    
--SMA.[Status] = 0 --select only 'public' comments    
--AND    
(@Type IS NULL OR SMA.LinkType=@Type)
--added by NSK on 20 Jan 2016
--start  
AND 
(
SMA.[Status] = 0 
OR
(SMA.[Status] <> 0 and @UserId IS NOT NULL and LEFT( @UserId,20) =SMA.EnteredBy) 
)  
--end
AND    
(((@CustID IS NULL OR @CustID=SMA.LinkKey) AND SMA.LinkType='ARCUSTOMER')    
OR    
((@SiteID IS NULL OR @SiteID=SMA.LinkKey) AND SMA.LinkType='ARALPSITE'))    
    
    
ORDER BY SMA.LinkKey, SMA.EntryDate DESC    
    
    
END