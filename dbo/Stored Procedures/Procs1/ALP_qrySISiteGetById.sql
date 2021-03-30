CREATE PROCEDURE [dbo].[ALP_qrySISiteGetById]
-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
@SiteId int
AS
SELECT [s].[SiteId], [s].[SiteName], [s].[AlpFirstName], [s].[AlpDear], [s].[Status], [s].[Attn],
[s].[Addr1], [s].[Addr2], [s].[City], [s].[Region], [s].[Country], [s].[PostalCode], [s].[IntlPrefix],
[s].[Phone], [s].[Fax], [s].[Email], [s].[CrossStreet], [s].[MapId], [s].[Directions], [s].[SubDivID],
[s].[Block], [s].[SiteMemo], [s].[SalesRepId1], [s].[Rep1PctInvc], [s].[SalesRepId2], [s].[Rep2PctInvc],
[s].[TermsCode], [s].[DistCode], [s].[TaxLocId], [s].[Taxable], [s].[CreditHoldYn], [s].[BranchId],
[s].[MarketId], [s].[LeadSourceId], [s].[ReferBy], [s].[Referral Fee], [s].[PromoId], [s].[Structure], [s].[Basement],
[s].[Attic], [s].[SqFt], [s].[InitialContactDate], [s].[PrefApptDate], [s].[PrefApptTime], [s].[DeadProspectYN], [s].[FinSourceID],
[s].[FinanceDate], [s].[FinanceEnds], [s].[Contact], [s].[County], [s].[OldSiteId], [s].[OldBillId],
[s].[CreateDate], [s].[LastUpdateDate], [s].[UploadDate], [s].[BundledYn], [s].[RecurTaxLocId], [s].[DealerSiteYn],
[s].[WDBTemplateYN],
[s].[ts], [s].[TaxExemptID], [s].[ModifiedBy], [s].[ModifiedDate], [s].[DisplayRmrInvoiceLineItemByMonth] ,
[s].Branch ,[s].Subdivision
FROM [dbo].[ALP_tblArAlpSite_view] AS [s]
WHERE [s].[SiteId] = @SiteId