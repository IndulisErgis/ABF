CREATE VIEW dbo.ALP_tblArAlpSite_view
AS
SELECT     dbo.ALP_tblArAlpSite.SiteId, dbo.ALP_tblArAlpSite.SiteName, dbo.ALP_tblArAlpSite.AlpFirstName, dbo.ALP_tblArAlpSite.AlpDear, dbo.ALP_tblArAlpSite.Status, 
                      dbo.ALP_tblArAlpSite.Attn, dbo.ALP_tblArAlpSite.Addr1, dbo.ALP_tblArAlpSite.Addr2, dbo.ALP_tblArAlpSite.City, dbo.ALP_tblArAlpSite.Region, 
                      dbo.ALP_tblArAlpSite.Country, dbo.ALP_tblArAlpSite.PostalCode, dbo.ALP_tblArAlpSite.IntlPrefix, dbo.ALP_tblArAlpSite.Phone, dbo.ALP_tblArAlpSite.Fax, 
                      dbo.ALP_tblArAlpSite.Email, dbo.ALP_tblArAlpSite.CrossStreet, dbo.ALP_tblArAlpSite.MapId, dbo.ALP_tblArAlpSite.Directions, dbo.ALP_tblArAlpSite.SubDivID, 
                      dbo.ALP_tblArAlpSite.Block, dbo.ALP_tblArAlpSite.SiteMemo, dbo.ALP_tblArAlpSite.SalesRepId1, dbo.ALP_tblArAlpSite.Rep1PctInvc, dbo.ALP_tblArAlpSite.SalesRepId2, 
                      dbo.ALP_tblArAlpSite.Rep2PctInvc, dbo.ALP_tblArAlpSite.TermsCode, dbo.ALP_tblArAlpSite.DistCode, dbo.ALP_tblArAlpSite.TaxLocId, dbo.ALP_tblArAlpSite.Taxable, 
                      dbo.ALP_tblArAlpSite.CreditHoldYn, dbo.ALP_tblArAlpSite.BranchId, dbo.ALP_tblArAlpSite.MarketId, dbo.ALP_tblArAlpSite.LeadSourceId, dbo.ALP_tblArAlpSite.ReferBy, 
                      dbo.ALP_tblArAlpSite.[Referral Fee], dbo.ALP_tblArAlpSite.PromoId, dbo.ALP_tblArAlpSite.Structure, dbo.ALP_tblArAlpSite.Basement, dbo.ALP_tblArAlpSite.Attic, 
                      dbo.ALP_tblArAlpSite.SqFt, dbo.ALP_tblArAlpSite.InitialContactDate, dbo.ALP_tblArAlpSite.PrefApptDate, dbo.ALP_tblArAlpSite.PrefApptTime, 
                      dbo.ALP_tblArAlpSite.DeadProspectYN, dbo.ALP_tblArAlpSite.FinSourceID, dbo.ALP_tblArAlpSite.FinanceDate, dbo.ALP_tblArAlpSite.FinanceEnds, 
                      dbo.ALP_tblArAlpSite.Contact, dbo.ALP_tblArAlpSite.County, dbo.ALP_tblArAlpSite.OldSiteId, dbo.ALP_tblArAlpSite.OldBillId, dbo.ALP_tblArAlpSite.CreateDate, 
                      dbo.ALP_tblArAlpSite.LastUpdateDate, dbo.ALP_tblArAlpSite.UploadDate, dbo.ALP_tblArAlpSite.BundledYn, dbo.ALP_tblArAlpSite.RecurTaxLocId, 
                      dbo.ALP_tblArAlpSite.DealerSiteYn, dbo.ALP_tblArAlpSite.WDBTemplateYN, dbo.ALP_tblArAlpSite.ts, dbo.ALP_tblArAlpSite.TaxExemptID, 
                      dbo.ALP_tblArAlpSite.ModifiedBy, dbo.ALP_tblArAlpSite.ModifiedDate, dbo.ALP_tblArAlpSite.DisplayRmrInvoiceLineItemByMonth, 
                      dbo.ALP_tblArAlpSubdivision.Subdiv AS Subdivision, dbo.ALP_tblArAlpBranch.Branch
FROM         dbo.ALP_tblArAlpSite LEFT OUTER JOIN
                      dbo.ALP_tblArAlpBranch ON dbo.ALP_tblArAlpSite.BranchId = dbo.ALP_tblArAlpBranch.BranchId LEFT OUTER JOIN
                      dbo.ALP_tblArAlpSubdivision ON dbo.ALP_tblArAlpSite.SubDivID = dbo.ALP_tblArAlpSubdivision.SubdivId