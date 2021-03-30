Create procedure [dbo].[ALP_qryArAlpDivisionSegId_sp]
(
	@DivisionId int
)
As

Select GLSegID from ALP_tblArAlpDivision  where DivisionId=@DivisionId