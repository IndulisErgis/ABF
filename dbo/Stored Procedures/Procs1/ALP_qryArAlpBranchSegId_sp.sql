Create procedure [dbo].[ALP_qryArAlpBranchSegId_sp]
(
	@BranchId int
)
As

Select GLSegID  from ALP_tblArAlpBranch where BranchId=@BranchId