CREATE VIEW [dbo].[ALP_lkpJmSvcTktCustSysId] AS 
SELECT     TOP 100 PERCENT dbo.ALP_tblArCust_view.CustId, dbo.ALP_tblArCust_view.CustName, dbo.ALP_tblArCust_view.AlpFirstName, dbo.ALP_tblArCust_view.Addr1, dbo.ALP_tblArCust_view.AlpInactive, 
                      dbo.ALP_tblArCust_view.AlpJmCustLevel, dbo.ALP_tblArCust_view.TermsCode, dbo.ALP_tblArCust_view.DistCode, dbo.ALP_tblArCust_view.CurrencyId, dbo.ALP_tblArCust_view.AlpPoRequiredYn, 
                      dbo.ALP_tblArAlpSiteSys.SysId
                        --Added by NSK on 22 Apr 2014 
                      ,ALP_tblArCust_view.Status
FROM         dbo.ALP_tblArCust_view INNER JOIN
                      dbo.ALP_tblArAlpSiteSys ON dbo.ALP_tblArCust_view.CustId = dbo.ALP_tblArAlpSiteSys.CustId