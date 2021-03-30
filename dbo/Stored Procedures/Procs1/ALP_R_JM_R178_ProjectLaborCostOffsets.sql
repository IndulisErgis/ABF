


CREATE PROCEDURE [dbo].[ALP_R_JM_R178_ProjectLaborCostOffsets] 
(
@StartDate datetime,
@EndDate datetime
)
AS
BEGIN
SET NOCOUNT ON
--Procedure converted from access query 'qryJm-R178' 12/29 - ER

SELECT 
CosOffsetParts,
CosOffsetPartsOh,
CosOffsetOtherItems

FROM 
ALP_tblJmOption

END