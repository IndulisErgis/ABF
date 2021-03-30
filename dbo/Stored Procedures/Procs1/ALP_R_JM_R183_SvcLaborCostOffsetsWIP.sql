
CREATE PROCEDURE [dbo].[ALP_R_JM_R183_SvcLaborCostOffsetsWIP] 
(
@EndDate datetime
)
AS
BEGIN
SET NOCOUNT ON
--Procedure converted from access query 'qryJm-R176' 11/26 - ER

SELECT 
CosOffsetParts,
CosOffsetPartsOh,
CosOffsetOtherItems

FROM 
ALP_tblJmOption

END