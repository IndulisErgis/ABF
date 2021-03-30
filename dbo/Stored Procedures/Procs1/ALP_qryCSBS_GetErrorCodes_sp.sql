

        CREATE PROCEDURE dbo.ALP_qryCSBS_GetErrorCodes_sp
AS
SELECT ErrorCode,ErrorMessage,ErrorCategory,SvcCode FROM ALP_tblCSErrorCodes
ORDER BY ErrorCode