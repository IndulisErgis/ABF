    
CREATE Procedure [dbo].[ALP_qryJm110e00SiteInfo_sp]    
/* RecordSource for Site Info subform of Control Center */    
/* EFI# 1189 MAH 09/18/03      */    
/* EFI# 1469 MAH 08/19/04 - added MonitoredStatus field   */    
/* EFI# 1521 MAH 10/01/04 - return  Inactive ( rather than Active) status as blank */    
/* MAH 01/26/14:  Handle null values in Addr1 field  */    
/* MAH 05/13/16:  Corrected where Contact is now retrieved from.  */    
/*          Site record Contact field no longer being populated in the Site form.  */    
 (    
 @SiteID int = null    
 )    
As    
 set nocount on    
 DECLARE @Contact varchar(100)    
 SET @Contact = ''    
 SET @Contact = ( SELECT TOP 1 CASE WHEN FirstName is NULL THEN Name     
      WHEN FirstName = '' THEN Name    
      ELSE FirstName + ' ' + Name END     
      + CASE WHEN PrimaryPhone IS NULL THEN ' '     
      WHEN PrimaryPhone = '' THEN ' '    
      ELSE ' ' + PrimaryPhone END    
      + CASE WHEN Title IS NULL THEN ''    
      WHEN Title = ' ' THEN ''    
      ELSE ' ' + Title END AS Contact    
      FROM ALP_tblArAlpSiteContact where SiteID = @SiteID    
      Order by ALP_tblArAlpSiteContact.PrimaryYN DESC)    
 SELECT SiteId,    
  [Name] = [SiteName] +     
    CASE     
       WHEN([AlpFirstName] + '' <> '') Then CONVERT(varchar,', ') +[AlpFirstName]    
        ELSE ''    
   END,    
  [FirstName] = isnull(AlpFirstName,''),    
  [LastName] = isnull(SiteName,''),    
  --MAH 1/26/14:  changed to check for null value in ADDR1    
  [Address] = CASE WHEN ([Addr1] + '' <> '' )     
      THEN [Addr1] +    
       CASE    
           WHEN ( [addr2] + '' <> '') Then Char(13) + Char(10) + [addr2]    
           ELSE  ''    
       END    
      ELSE     
       CASE    
           WHEN ( [addr2] + '' <> '') Then Char(13) + Char(10) + [addr2]    
           ELSE  ''    
       END    
      END    
    + Char(13) + Char(10)     
    + isnull([city],'') + CONVERT(varchar,', ')    
    + isnull([region],'') + CONVERT(varchar,' ')    
    -- + isnull([postalcode],''),--Commented and added the line below by NSK on 16 Oct 2020 for bug id 1097     
    + CASE
    WHEN Len(postalcode) >5 THEN isnull(Substring([postalcode], 1, 5) + '-' + Substring([postalcode], 6, 9) ,'')
    ELSE isnull([postalcode],'')
END,     
  --[Address] = [Addr1] +    
  -- CASE    
  --     WHEN ( [addr2] + '' <> '') Then Char(13) + Char(10) + [addr2]    
  --     ELSE  ''    
  -- END    
  --  + Char(13) + Char(10)     
  --  + isnull([city],'') + CONVERT(varchar,', ')    
  --  + isnull([region],'') + CONVERT(varchar,' ')    
  --  + isnull([postalcode],''),    
  Phone = isnull(Phone,''),     
  --Contact = isnull(Contact,''),    
  Contact = isnull(@Contact,''),    
--   EFI# 1521 MAH 10/01/04    
  SiteStatus = CASE    
    WHEN [Status] ='Inactive' Then ''    
    ELSE  [Status]    
        END,    
  Rep = isnull(SalesRepId1,''),    
  MonitoredStatus = dbo.ufxArAlpSiteMonitoredStatus(SiteId)    
 FROM ALP_tblArAlpSite (NOLOCK)    
 WHERE SiteId = @SiteID    
 ORDER BY SiteID    
 return