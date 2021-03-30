
CREATE VIEW dbo.trav_SmTaxLocationDetailAmounts_view AS

         SELECT         detail.TaxLocId           AS TaxLocationId       ,
                        detail.TaxClassCode                              ,
                (ISNULL(detail.TaxSales    , 0) ) AS TaxableSales        ,
                (ISNULL(detail.NonTaxSales , 0) ) AS NontaxableSales     ,
                (ISNULL(detail.TaxPurch    , 0) ) AS TaxablePurchases    ,
                (ISNULL(detail.NonTaxPurch , 0) ) AS NontaxablePurchases ,
                (ISNULL(detail.TaxRefund   , 0) ) AS RefundableTax       ,
                (ISNULL(detail.TaxCollect  , 0) ) AS CollectedTax        ,
                (ISNULL(detail.TaxPaid     , 0) ) AS PaidTax             ,
                (ISNULL(detail.TaxCalcPurch, 0) ) AS TaxCalcPurchases    ,
                (ISNULL(detail.TaxCalcSales, 0) ) AS TaxCalcSales        ,
                        detail.TransDate          AS TransactionDate     ,
                        detail.GLPeriod           AS FiscalPeriod        ,
                        detail.FiscalYear
           FROM dbo.tblSmTaxLocTrans detail
     INNER JOIN dbo.tblSmTaxLoc taxLocationHeader -- only return detail for current tax locations
             ON detail.TaxLocId = taxLocationHeader.TaxLocId
     INNER JOIN dbo.tblSmTaxClass taxClassHeader -- only return detail for current tax classes
             ON detail.TaxClassCode = taxClassHeader.TaxClassCode
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SmTaxLocationDetailAmounts_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SmTaxLocationDetailAmounts_view';

