
CREATE PROCEDURE [dbo].[ALP_R_AR_R510C_Call_to_NOI_SPECIAL]
(
@CustID varchar(10)
)
AS
EXEC qryJm110b00ARItems_sp @CustID