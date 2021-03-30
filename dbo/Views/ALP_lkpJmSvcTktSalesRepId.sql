
CREATE VIEW dbo.ALP_lkpJmSvcTktSalesRepId AS SELECT SalesRepID, Name,AlpInactiveYN FROM dbo.ALP_tblArSalesRep_view --WHERE (AlpInactiveYN = 0) 