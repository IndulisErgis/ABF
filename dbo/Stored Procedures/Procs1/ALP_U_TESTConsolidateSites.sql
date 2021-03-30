
CREATE PROCEDURE [dbo].[ALP_U_TESTConsolidateSites]
(
	@NewCustId varchar(10)
	,@OldIdList varchar(110)  
)

AS
BEGIN

SET NOCOUNT ON

SELECT ('Here in ALP_TESTConsolidateSites with ' + @NewCustId + ': ' + @OldIdList)

END