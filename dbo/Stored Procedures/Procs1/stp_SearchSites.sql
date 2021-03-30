

/*
-- Author:		VTG
-- Create date: 24/4/08
-- Description:	This procedure is used to get all the Dealers from ABPro database based on 
search criterias like name,address,city etc.
 */
CREATE proc [dbo].[stp_SearchSites](  
@vaSiteName as  varchar(30)='',  
@vaAddr1 varchar(30)='',  
@vaAddr2 varchar(60)='',  
@vaCity varchar(30)='',  
@vaState varchar(30)='',  
@vaPostalCode varchar(10)='',  
@vaCustID varchar(24)='',  
@vaAlaramID varchar(50)='',  
@bTemplateYn bit=0)  
as  
if(@vaSiteName <> '')  
begin  
 set @vaSiteName = '%' + @vaSiteName + '%'  
end  
else  
begin  
 set @vaSiteName = @vaSiteName + '%'  
end  
  
if(@vaCustID <> '')  
begin  
 set @vaCustID = '%' + @vaCustID + '%'  
end  
else  
begin  
 set @vaCustID = @vaCustID + '%'  
end  
  
if(@vaAlaramID <> '')  
begin  
 set @vaAlaramID = '%' + @vaAlaramID + '%'  
end  
else  
begin  
 set @vaAlaramID = @vaAlaramID + '%'  
end  
  
if(@vaAddr1 <> '')  
begin  
 set @vaAddr1 = '%' + @vaAddr1 + '%'  
end  
else  
begin  
 set @vaAddr1 = @vaAddr1 + '%'  
end  
if(@vaAddr2 <> '')  
begin  
 set @vaAddr2 = '%' + @vaAddr2 + '%'  
end  
else  
begin  
 set @vaAddr2 = @vaAddr2 + '%'  
end  
if(@vaCity <> '')  
begin  
 set @vaCity = '%' + @vaCity + '%'  
end  
else  
begin  
 set @vaCity = @vaCity + '%'  
end  
if(@vaState <> '')  
begin  
 set @vaState = '%' + @vaState + '%'  
end  
else  
begin  
 set @vaState = @vaState + '%'  
end  
if(@vaPostalCode <> '')  
begin  
 set @vaPostalCode = '%' + @vaPostalCode + '%'  
end  
else  
begin  
 set @vaPostalCode = @vaPostalCode + '%'  
end  
select tblArAlpSite.SiteID,
tblArAlpSite.SiteName as [Site Name],
tblArAlpSite.Addr1 as Address1,
tblArAlpSite.Addr2 as Address2,
tblArAlpSite.City,
tblArAlpSite.Region as State,
tblArAlpSite.PostalCode as [Postal Code],    
tblArAlpSiteSys.AlarmID ,
tblarcust.CustID as DealerID
 from tblArAlpSiteSys inner join tblarcust on   
tblarcust.CustID= tblArAlpSiteSys.CustID   
inner join tblArAlpSite on tblArAlpSite.SiteID=tblArAlpSiteSys.SiteID  
where isnull(tblArAlpSite.SiteName,'') like @vaSiteName  
and isnull(tblArAlpSite.Addr1,'') like @vaAddr1  
and isnull(tblArAlpSite.Addr2,'') like @vaAddr2  
and isnull(tblArAlpSite.City,'') like @vaCity  
and isnull(tblArAlpSite.Region,'') like @vaState  
and isnull(tblArAlpSite.PostalCode,'') like @vaPostalCode  
and isnull(tblarcust.CustID,'') like @vaCustID  
and isnull(tblArAlpSiteSys.AlarmID,'') like @vaAlaramID  
and tblArAlpSite.WDBTemplateYN = @bTemplateYn