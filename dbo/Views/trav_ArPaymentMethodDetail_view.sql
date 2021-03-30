
CREATE VIEW dbo.trav_ArPaymentMethodDetail_view AS

         SELECT detail.PmtMethodId AS PaymentMethodId,
                detail.FiscalYear,
                detail.GLPeriod AS FiscalPeriod,
                SUM(ISNULL(detail.PmtAmt, 0) ) AS TotalPayments
           FROM dbo.tblArHistPmt detail
     INNER JOIN dbo.tblArPmtMethod header -- only return detail for current payment methods
             ON detail.PmtMethodId = header.PmtMethodID
		  WHERE detail.VoidYn = 0
       GROUP BY detail.PmtMethodId, detail.FiscalYear, detail.GlPeriod
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArPaymentMethodDetail_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArPaymentMethodDetail_view';

