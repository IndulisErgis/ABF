


CREATE PROCEDURE [dbo].[ALP_R_JM_R172_Dropdown_WarehouseID] 
AS
BEGIN
SET NOCOUNT ON;
--provides Warehouse options for report dropdown - 10/18/2018 - ER

-- Create a Temp table with Warehouse varchar(255)
CREATE TABLE #ALP_R_JM_R172_Dropdown_WarehouseID(WarehouseID varchar(10))

-- Aquire the warehouse ID's from the service ticket item table
INSERT INTO #ALP_R_JM_R172_Dropdown_WarehouseID 
	SELECT DISTINCT WhseID
	FROM ALP_tblJmSvcTktItem ORDER BY WhseID

-- Send it down to the report dataset
SELECT * FROM #ALP_R_JM_R172_Dropdown_WarehouseID

DROP TABLE #ALP_R_JM_R172_Dropdown_WarehouseID
END