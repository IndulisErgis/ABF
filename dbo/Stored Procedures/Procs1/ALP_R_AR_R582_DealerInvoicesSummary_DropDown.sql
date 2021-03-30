

CREATE PROCEDURE [dbo].[ALP_R_AR_R582_DealerInvoicesSummary_DropDown]
AS
BEGIN
SET NOCOUNT ON;

select '<ALL>' as CustID, 'All Dealers' as CustName
UNION
select CustID, CustName
FROM ALP_tblArCust_view as AR
WHERE (AlpDealerYn<> 0)
ORDER BY CustId

END