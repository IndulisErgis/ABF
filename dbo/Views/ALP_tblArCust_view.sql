
CREATE VIEW [dbo].[ALP_tblArCust_view]
AS
SELECT     dbo.trav_tblArCust_view.CustId, dbo.ALP_tblArCust.AlpCustId, dbo.trav_tblArCust_view.AcctType, dbo.trav_tblArCust_view.Addr1, dbo.trav_tblArCust_view.Addr2, 
                      dbo.trav_tblArCust_view.AllowCharge, dbo.trav_tblArCust_view.Attn, dbo.trav_tblArCust_view.AutoCreditHold, dbo.trav_tblArCust_view.BalAge1, 
                      dbo.trav_tblArCust_view.BalAge2, dbo.trav_tblArCust_view.BalAge3, dbo.trav_tblArCust_view.BalAge4, dbo.trav_tblArCust_view.BillToId, 
                      dbo.trav_tblArCust_view.CalcFinch, dbo.trav_tblArCust_view.CcCompYn, dbo.trav_tblArCust_view.City, dbo.trav_tblArCust_view.ClassId, 
                      dbo.trav_tblArCust_view.Contact, dbo.trav_tblArCust_view.Country, dbo.trav_tblArCust_view.CreditHold, dbo.trav_tblArCust_view.CreditLimit, 
                      dbo.trav_tblArCust_view.CreditStatus, dbo.trav_tblArCust_view.CurAmtDue, dbo.trav_tblArCust_view.CurAmtDueFgn, dbo.trav_tblArCust_view.CurrencyId, 
                      dbo.trav_tblArCust_view.CustLevel, dbo.trav_tblArCust_view.CustName, dbo.trav_tblArCust_view.DistCode, dbo.trav_tblArCust_view.Email, 
                      dbo.trav_tblArCust_view.Fax, dbo.trav_tblArCust_view.FirstSaleDate, dbo.trav_tblArCust_view.GroupCode, dbo.trav_tblArCust_view.HighBal, 
                      dbo.trav_tblArCust_view.Internet, dbo.trav_tblArCust_view.IntlPrefix, dbo.trav_tblArCust_view.LastPayAmt, dbo.trav_tblArCust_view.LastPayCheckNum, 
                      dbo.trav_tblArCust_view.LastPayDate, dbo.trav_tblArCust_view.LastSaleAmt, dbo.trav_tblArCust_view.LastSaleDate, dbo.trav_tblArCust_view.LastSaleInvc, 
                      dbo.trav_tblArCust_view.NewFinch, dbo.trav_tblArCust_view.PartialShip, dbo.trav_tblArCust_view.Phone, dbo.trav_tblArCust_view.Phone1, 
                      dbo.trav_tblArCust_view.Phone2, dbo.trav_tblArCust_view.PmtMethod, dbo.trav_tblArCust_view.PostalCode, dbo.trav_tblArCust_view.PriceCode, 
                      dbo.trav_tblArCust_view.Region, dbo.trav_tblArCust_view.Rep1PctInvc, dbo.trav_tblArCust_view.Rep2PctInvc, dbo.trav_tblArCust_view.SalesRepId1, 
                      dbo.trav_tblArCust_view.SalesRepId2, dbo.trav_tblArCust_view.ShipZone, dbo.trav_tblArCust_view.Status, dbo.trav_tblArCust_view.StmtInvcCode, 
                      dbo.trav_tblArCust_view.Taxable, dbo.trav_tblArCust_view.TaxExemptId, dbo.trav_tblArCust_view.TaxLocId, dbo.trav_tblArCust_view.TermsCode, 
                      dbo.trav_tblArCust_view.TerrId, dbo.trav_tblArCust_view.UnapplCredit, dbo.trav_tblArCust_view.UnpaidFinch, dbo.trav_tblArCust_view.WebDisplInQtyYn, 
                      dbo.ALP_tblArCust.AlpAllowCharge, dbo.ALP_tblArCust.AlpFirstName, dbo.ALP_tblArCust.AlpDear, dbo.ALP_tblArCust.AlpJmCustLevel, 
                      dbo.ALP_tblArCust.AlpListServices, dbo.ALP_tblArCust.AlpInactive, dbo.ALP_tblArCust.AlpComment, dbo.ALP_tblArCust.AlpCreditHoldDays, 
                      dbo.ALP_tblArCust.AlpCommYn, dbo.ALP_tblArCust.AlpLastName, dbo.ALP_tblArCust.AlpTaxId, dbo.ALP_tblArCust.AlpBillCycleDay, dbo.ALP_tblArCust.AlpAchAcctType, 
                      dbo.ALP_tblArCust.AlpAchAba, dbo.ALP_tblArCust.AlpAchAcctNo, dbo.ALP_tblArCust.AlpCreditBureau, dbo.ALP_tblArCust.AlpCreditScore, 
                      dbo.ALP_tblArCust.AlpCreateDate, dbo.ALP_tblArCust.AlpLastUpdateDate, dbo.ALP_tblArCust.AlpUploadDate, dbo.ALP_tblArCust.AlpOldCustId, 
                      dbo.ALP_tblArCust.AlpDealerYn, dbo.ALP_tblArCust.AlpEmbContractType, dbo.ALP_tblArCust.AlpPoRequiredYn, dbo.ALP_tblArCust.Alpts
FROM         [dbo].[trav_tblArCust_view] LEFT OUTER JOIN
                      dbo.ALP_tblArCust ON dbo.trav_tblArCust_view.CustId = dbo.ALP_tblArCust.AlpCustId