Create View [dbo].[Alp_lkpArAlpDefaultWhseID]
As
(
SELECT DfltLocID,BranchId ,Branch  from Alp_tblaralpbranch
)