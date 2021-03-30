Create procedure [dbo].[ALP_qryArAlpDeptSegId_sp]
(
	@DeptId int
)
As

Select GLSegID from ALP_tblArAlpDept where DeptId=@DeptId