﻿

CREATE PROCEDURE [dbo].[ALP_R_JM_R176_SvcLaborCostOffsets] 
(
@StartDate datetime,
@EndDate datetime
)
AS
BEGIN
SET NOCOUNT ON
--Procedure converted from access query 'qryJm-R176' 12/24 - ER

SELECT 
CosOffsetParts,
CosOffsetPartsOh,
CosOffsetOtherItems

FROM 
ALP_tblJmOption

END