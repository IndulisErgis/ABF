


CREATE PROCEDURE [dbo].[ALP_qryJmComm_GetSiteInvoices_sp]
/* Get invoices for a Cust/Site from AR Hist table 	*/
/* created 06/02/04 EFI#1440  MAH			*/
(
	@CustID pCustID = null,
	@SiteId int = null,
	@StartDate datetime = '01/01/1900'
)
AS
SET NOCOUNT ON
SELECT  tblArHistHeader.InvcNum,   InvoiceDate = MIN(tblArHistHeader.InvcDate),
	AmtBilled = SUM(CASE WHEN tblArHistHeader.TransType > 0 THEN (tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell)
					ELSE (tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell * -1 )
					END),
	--AmtBilledH = tblArHistHeader.TaxSubTotal + tblArHistHeader.NonTaxSubTotal,
	--tblArHistHeader.TaxSubTotal, tblArHistHeader.NonTaxSubTotal,
	--tblArHistDetail.PartId, tblArHistHeader.AlpSiteID,
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
				AND tblArHistDetail.TransID = tblArHistHeader.TransID
			INNER JOIN ALP_tblArHistHeader 
				ON tblArHistHeader.PostRun = ALP_tblArHistHeader.AlpPostRun 
				AND tblArHistHeader.TransID = ALP_tblArHistHeader.AlpTransID
			INNER JOIN ALP_tblInItem 
				ON tblArHistDetail.PartId = ALP_tblInItem.AlpItemId
WHERE     (tblArHistHeader.CustID = @CustID) 
	AND  (ALP_tblArHistHeader.AlpSiteID = @SiteId)
	AND tblArHistHeader.InvcDate >=  @StartDate
	AND (tblArHistDetail.UnitPriceSell <> 0)
--WHERE     (tblArHistHeader.InvcNum = '402392') AND (tblArHistDetail.UnitPriceSell <> 0)
GROUP BY tblArHistHeader.InvcNum 
order by tblArHistHeader.InvcNum
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_qryJmComm_GetSiteInvoices_sp] TO [JMCommissions]
    AS [dbo];

