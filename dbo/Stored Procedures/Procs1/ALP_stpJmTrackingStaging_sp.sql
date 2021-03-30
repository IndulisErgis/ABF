  
CREATE PROCEDURE [dbo].[ALP_stpJmTrackingStaging_sp]  
/* modified 8/19/03 by MAH. EFI# 1102 - added ProjectID filter     */  
/*        EFI# 1101 - modified to correct cursor / lost filter problem   */  
/* EFI# 1289 mah 12/05/03 - changed to use ProjectFilter with wildcard char appended.  */  
/*   - allows selcting all jobs within related projects.   */  
-- mah 3/4/16 - added fields: NextSched, NextTech
 (  
 @UseDateFilter char(1) = 'N',  
 @TimeCardDateFromFilter datetime = '',  
 @TimeCardDateToFilter datetime = '',  
 @UseProjectFilter char(1) = 'N',  
 @ProjectFilter varchar(10) = ''  
 )   
AS  
-- create a datatype of TABLE and populate  
-- with matching records  
-- dump to ALP_tblJMTrackingStaging_temp table for fastest version  
-- use stpJmTrackingStaging_EMPTY_sp to test using an empty recordset  
DECLARE @MatchingReportData TABLE  
(  
 [TicketID1] [int] PRIMARY KEY,  
 [SiteId1] [int] NULL,  
 [Status] [varchar] (10),  
 [WorkCodeId1] [int],  
 [LeadTechId] [int],  
 [FirstScheduledDate] [datetime] NULL,  
 [LastScheduledDate] [datetime] NULL,  
 [TechID] [int],  
 [Tech] [varchar] (3) ,  
 [WorkCode] [varchar] (10) ,  
 [NewWorkYN] [bit] ,  
 [SiteComposite] [varchar] (150)  
)  
SET NOCOUNT ON  
INSERT @MatchingReportData  
 (  
 [TicketId1],  
 [SiteId1],  
 [Status],  
 [WorkCodeId1],  
 [LeadTechId]  
 )  
 SELECT  
  [TicketId],  
  [SiteId],  
  [Status],  
  [WorkCodeId],  
  [LeadTechId]  
 FROM ALP_tblJmSvcTkt   
 WHERE ((ALP_tblJmSvcTkt.Status) = 'New' OR (ALP_tblJmSvcTkt.Status) = 'Targeted' OR  
    (ALP_tblJmSvcTkt.Status) = 'Scheduled')  
 ORDER BY ALP_tblJmSvcTkt.TicketId  
-- end of svctkt population --------------------------------------  
-- Populate from JmTech -----------------------------------------  
UPDATE @MatchingReportData  
SET   
Tech=ALP_tblJmTech.Tech  
FROM ALP_tblJmTech  
WHERE LeadtechID=ALP_tblJmTech.TechID  
-- end of JmTech population --------------------------------------  
-- Populate from JmWorkCode -----------------------------------------  
UPDATE @MatchingReportData  
SET   
WorkCode=ALP_tblJmWorkCode.WorkCode,  
NewWorkYN=ALP_tblJmWorkCode.NewWorkYN  
FROM ALP_tblJmWorkCode   
WHERE WorkcodeID1=ALP_tblJmWorkCode.WorkCodeID  
-- end of JmWorkCode population --------------------------------------  
-- Populate from ArAlpSites -----------------------------------------  
UPDATE @MatchingReportData  
SET   
SiteComposite=  
(dbo.ALP_ufxAlpFullName(ALP_tblArAlpSite.AlpFirstName,ALP_tblArAlpSite.SiteName)   
 + '    ' + [ALP_tblArAlpSite].[Addr1] + ',  ' + [ALP_tblArAlpSite].[City])   
FROM ALP_tblArAlpSite   
WHERE SiteID1=ALP_tblArAlpSite.SiteID  
-- end of ArAlpSites population --------------------------------------  
-- Populate from ALP_tblJmTimeCard -----------------------------------------  
UPDATE @MatchingReportData  
SET   
FirstScheduledDate=  
 (  
 SELECT min(ALP_tblJmTimeCard.StartDate)  
 FROM ALP_tblJmTimeCard   
 WHERE TicketID1=ALP_tblJmTimeCard.TicketID  
 AND ALP_tblJmTimeCard.StartDate is not null)  
UPDATE @MatchingReportData  
SET   
LastScheduledDate=  
 (  
 SELECT max(ALP_tblJmTimeCard.StartDate)  
 FROM ALP_tblJmTimeCard  
 WHERE TicketID1=ALP_tblJmTimeCard.TicketID  
 and ALP_tblJmTimeCard.StartDate is not null  
 )  
-- end of JmWorkCode population --------------------------------------  
--formerly exec stpJmTrackingStaging_DelTemp_sp  
DELETE FROM ALP_tblJmTrackingStaging_temp  
INSERT INTO dbo.ALP_tblJmTrackingStaging_Temp  
SELECT * FROM @MatchingReportData  
SELECT S.BoDate,  
 S.StagedDate,   
    S.BinNumber,   
 S.TicketId,   
    T.SiteComposite,   
  S.ProjectId,    
    S.CreateDate,  
    S.PrefDate,   
   T.SiteID1,  
    T.FirstScheduledDate,  
    T.LastScheduledDate,  
    T.Tech,  
    T.WorkCode,  
    CombinedID = (CASE   
    WHEN S.ProjectId IS NULL  
    THEN '         - ' + CONVERT(char(8), S.TicketId)   
       ELSE CONVERT(char(8),S.ProjectId) + ' - ' + CONVERT(char(8), S.TicketId)  
   END)  
   --mah 03/04/16: added three new fields to data returned  - LeadTech, NextSched, NextTech
   ,T.Tech as LeadTech
   ,dbo.ALP_ufxJmNextDate(T.TicketId1) as NextSched
   ,dbo.ALP_ufxJmNextTech(T.TicketId1) as NextTech
FROM dbo.ALP_tblJmSvcTkt S   
 INNER JOIN @MatchingReportData T  
 ON S.TicketId = T.TicketId1  
WHERE   
 ((@UseDateFilter = 'N')  
  OR  
  (  
  (@UseDateFilter = 'Y')  AND (((S.PrefDate >= @TimeCardDateFromFilter) and (S.PrefDate <= @TimeCardDateToFilter))  
      OR  
         ( (T.FirstScheduledDate >= @TimeCardDateFromFilter) and (T.FirstScheduledDate <= @TimeCardDateToFilter))  
      OR  
         ( (T.LastScheduledDate >= @TimeCardDateFromFilter) and (T.LastScheduledDate <= @TimeCardDateToFilter)))  
  )   
 )  
 AND  
 ((@UseProjectFilter = 'N')  
  OR  
-- EFI# 1289 mah 12/05/03  
--  ((@UseProjectFilter = 'Y') AND (S.ProjectId = @ProjectFilter))  
  ((@UseProjectFilter = 'Y') AND (S.ProjectId LIKE @ProjectFilter + '%'))  
 )  
ORDER BY TicketID