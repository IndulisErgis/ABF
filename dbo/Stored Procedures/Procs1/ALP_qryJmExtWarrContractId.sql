
CREATE Procedure dbo.ALP_qryJmExtWarrContractId
@Sysid int = null,
@ItemDate datetime = null
As
set nocount on
	SELECT ExtRepPlanId, ContractId
	FROM ALP_tblArAlpSiteRecBillServ
       	WHERE ExtRepPlanId is not null 
		AND SysId = @SysId
         		AND ((Status = 'Cancelled' AND CanServEndDate >= @ItemDate)
		OR (Status <> 'Cancelled' 
		AND ((FinalBillDate is  null) Or FinalBillDate >=@ItemDate)))