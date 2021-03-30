/****** Object:  StoredProcedure [dbo].[ALP_qryCSTransmitterExceptions_SiteInfo_sp]    Script Date: 07/23/2014 11:16:34 ******/


CREATE Procedure [dbo].[ALP_qryCSTransmitterExceptions_SiteInfo_sp]  
 (  
  @Transmitter varchar(36) = ''  
 )  
As  
set nocount on  
  
SELECT  SS.SysDesc,   
 SS.CustId,  
 SS.SiteId,  
 SiteFullName = S.SiteName +   
    CASE   
       WHEN(S.AlpFirstName + '' <> '') Then CONVERT(varchar,', ') + S.AlpFirstName  
        ELSE ''  
   END,  
 SiteFullAddress = S.Addr1 +  
   CASE  
       WHEN ( S.addr2 + '' <> '') Then Char(13) + Char(10) + S.addr2  
       ELSE  ''  
   END  
    + Char(13) + Char(10)   
    + isnull(S.city,'') + CONVERT(varchar,', ')  
    + isnull(S.region,'') + CONVERT(varchar,' ')  
    + isnull(S.postalcode,'')  
  
FROM  dbo.ALP_tblArAlpSiteSys SS  
     INNER JOIN dbo.ALP_tblArAlpSite S ON   
      SS.SiteId = S.SiteId  
WHERE  SS.AlarmId = @Transmitter  
return