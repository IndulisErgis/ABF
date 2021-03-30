
CREATE FUNCTION [dbo].[ALP_ufxJmComm_GetSiteInvoices]
/* Get invoices for a Cust/Site from AR Hist table 	*/
/* created 06/04/04 EFI#1440  MAH			*/
(
	@CustID pCustID = null,
	@SiteId int = null,
	@StartDate datetime = '01/01/1900'
)
RETURNS TABLE
AS
RETURN
(
SELECT  tblArHistHeader.InvcNum,   InvoiceDate = MIN(tblArHistHeader.InvcDate),
	AmtBilled = SUM(tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell),
	RecurAmt = SUM(CASE WHEN AlpServiceType = 0 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell 
			WHEN AlpServiceType >= 4 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell
			ELSE 0 END),
        PartsLaborAmt = SUM(CASE WHEN AlpServiceType = 1 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell
			WHEN AlpServiceType = 2 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell
			ELSE 0 END),
	PaidStatus = dbo.ALP_ufxJmComm_CheckInvcStatus(tblArHistHeader.InvcNum),
	Balance = dbo.ALP_ufxJmComm_CheckInvcBalance(tblArHistHeader.InvcNum)
FROM      tblArHistDetail 
		INNER JOIN tblArHistHeader 
			ON tblArHistDetail.PostRun = tblArHistHeader.PostRun 
				AND 
				tblArHistDetail.TransID = tblArHistHeader.TRansID
		INNER JOIN ALP_tblArHistHeader 
			ON ALP_tblArHistHeader.AlpPostRun = tblArHistHeader.PostRun 
				AND 
			ALP_tblArHistHeader.AlpTransID = tblArHistHeader.TRansID
		LEFT OUTER JOIN ALP_tblInItem 
			ON tblArHistDetail.PartId = ALP_tblInItem.AlpItemId
WHERE     ((@CustID is null) OR(tblArHistHeader.CustID = @CustID)) 
	AND  (ALP_tblArHistHeader.AlpSiteID = @SiteId)
	AND tblArHistHeader.InvcDate >=  @StartDate
	AND (tblArHistDetail.UnitPriceSell <> 0)
GROUP BY tblArHistHeader.InvcNum 
)
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_ufxJmComm_GetSiteInvoices] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_ufxJmComm_GetSiteInvoices] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_ufxJmComm_GetSiteInvoices] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_ufxJmComm_GetSiteInvoices] TO [JMCommissions]
    AS [dbo];

