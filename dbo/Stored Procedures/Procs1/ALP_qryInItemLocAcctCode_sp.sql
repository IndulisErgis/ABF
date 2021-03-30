Create procedure [dbo].[ALP_qryInItemLocAcctCode_sp]
(
	@ItemId varchar(24),
	@LocId varchar(10)
)
As

Select GLAcctCode  from tblInItemLoc where ItemId=@ItemId and LocId=@LocId