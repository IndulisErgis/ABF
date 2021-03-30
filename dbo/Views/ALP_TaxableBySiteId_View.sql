CREATE View [dbo].[ALP_TaxableBySiteId_View]  
as  
(  
Select Taxable,SiteId,TaxLocID  from dbo.alp_tblaralpsite   
)