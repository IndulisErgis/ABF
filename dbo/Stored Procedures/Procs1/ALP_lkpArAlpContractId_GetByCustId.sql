CREATE PROC [dbo].[ALP_lkpArAlpContractId_GetByCustId]
(
	@CustId VARCHAR(10)
)
AS
BEGIN
	SELECT * 
	FROM [dbo].[ALP_lkpArAlpContractId_CustID] AS [c]
	WHERE	[c].[CustId] = @CustId
END