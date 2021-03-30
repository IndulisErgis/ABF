
CREATE PROCEDURE dbo.ALP_qryUpdateTimeCode
@sTimeCode varchar(50), @sDesc varchar(255), @lTimeType bigint, @nToggleOrder int, @lBarColor bigint, @lTextColor bigint, @bInactiveYN bit, @ID int
As
SET NOCOUNT ON
UPDATE ALP_tblJmTimeCode 
SET ALP_tblJmTimeCode.TimeCode = @sTimeCode, ALP_tblJmTimeCode.[Desc] = @sDesc, ALP_tblJmTimeCode.TimeType = @lTimeType, 
	ALP_tblJmTimeCode.ToggleOrder = @nToggleOrder, ALP_tblJmTimeCode.BarColor = @lBarColor, ALP_tblJmTimeCode.TextColor = @lTextColor, 
	ALP_tblJmTimeCode.InactiveYN = @bInactiveYN
WHERE ALP_tblJmTimeCode.TimeCodeID = @ID