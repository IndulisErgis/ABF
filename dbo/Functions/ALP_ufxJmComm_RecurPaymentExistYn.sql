

CREATE FUNCTION [dbo].[ALP_ufxJmComm_RecurPaymentExistYn]
/* created 06/21/04 EFI#1440  MAH			*/
(
	@CustID pCustID = null,
	@SiteId int = null,
	@StartDate datetime = '01/01/1900'
)
RETURNS varchar(4)
AS
begin
declare @RecurPaymentExist varchar(4)
set @RecurPaymentExist = 'NO' 
IF EXISTS 
	(SELECT  
	tblArHistHeader.InvcNum
	FROM tblArHistDetail 
		INNER JOIN tblArHistHeader 
			ON tblArHistDetail.PostRun = tblArHistHeader.PostRun 
				AND 
			tblArHistDetail.TransID = tblArHistHeader.TransID
		INNER JOIN ALP_tblArHistHeader 
			ON tblArHistDetail.PostRun = ALP_tblArHistHeader.AlpPostRun 
				AND 
			tblArHistDetail.TransID = ALP_tblArHistHeader.AlpTransID
		INNER JOIN ALP_tblInItem 
			ON tblArHistDetail.PartId = ALP_tblInItem.AlpItemId
	WHERE     (tblArHistHeader.CustID = @CustID) 
		AND  (ALP_tblArHistHeader.AlpSiteID = @SiteId)
		AND tblArHistHeader.InvcDate >=  @StartDate
		AND (tblArHistDetail.UnitPriceSell <> 0)
	GROUP BY tblArHistHeader.InvcNum 
	HAVING (SUM(CASE WHEN AlpServiceType = 0 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell 
			WHEN AlpServiceType >= 4 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell
			ELSE 0 END) > 0)
		AND
		(dbo.ALP_ufxJmComm_CheckInvcStatus(tblArHistHeader.InvcNum) = 'PAID')
	)
BEGIN
	set  @RecurPaymentExist = 'YES' 
END
return @RecurPaymentExist
end
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_ufxJmComm_RecurPaymentExistYn] TO [JMCommissions]
    AS [dbo];

