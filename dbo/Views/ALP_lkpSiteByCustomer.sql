Create View [dbo].[ALP_lkpSiteByCustomer]
  as
   
   SELECT siteSys.CustId,a.SiteId,SiteName,Addr1,Addr2,SubDivID 
    FROM Alp_tblaralpsite a Inner Join ALP_tblArAlpSiteSys siteSys
 on a.SiteId = siteSys.SiteId