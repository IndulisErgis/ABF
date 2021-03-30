
CREATE PROCEDURE dbo.ALP_qryWriteNewTimeCard
@lTechID int, @sStartDate datetime, @sEndDate datetime, @lStartTime bigint, @lEndTime bigint, @lTimeCodeID int, 
@nPayBasedOn int, @nPworkRate pdec, @nLaborCostRate pdec
As
SET NOCOUNT ON
INSERT INTO ALP_tblJmTimeCard ( TechID, StartDate, EndDate, StartTime, EndTime, TimeCodeID, SvcJobYN, PayBasedOn, PworkRate, LaborCostRate )
SELECT @lTechID, @sStartDate, @sEndDate, @lStartTime, @lEndTime, @lTimeCodeID, 1, @nPayBasedOn, @nPworkRate, @nLaborCostRate