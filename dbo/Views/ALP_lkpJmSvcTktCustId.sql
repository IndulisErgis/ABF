CREATE VIEW [dbo].[ALP_lkpJmSvcTktCustId] AS 
SELECT     TOP 100 PERCENT ALP_tblArCust_view.CustId, ALP_tblArCust_view.CustName, ALP_tblArCust_view.AlpFirstName, ALP_tblArCust_view.Addr1, ALP_tblArCust_view.AlpInactive, 
                      ALP_tblArCust_view.AlpJmCustLevel, ALP_tblArCust_view.TermsCode, ALP_tblArCust_view.DistCode, ALP_tblArCust_view.CurrencyId, ALP_tblArCust_view.AlpPoRequiredYn
                      --Added by NSK on 22 Apr 2014 
                      ,ALP_tblArCust_view.Status
FROM         ALP_tblArCust_view