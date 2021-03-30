

CREATE PROCEDURE [dbo].[ALP_R_JM_R152_Dropdown_Market] 
AS
BEGIN
SET NOCOUNT ON;
--provides market options for report dropdown - 08/02/2018 - ER

-- Create a Temp table with Market varchar(255)
CREATE TABLE #ALP_R_JM_R152_Dropdown_Market(MarketCode varchar(255),[Desc] varchar(255))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #ALP_R_JM_R152_Dropdown_Market(MarketCode,[Desc]) Values ('<ALL>','<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #ALP_R_JM_R152_Dropdown_Market 
	SELECT MarketCode, [Desc]
	FROM ALP_tblJmMarketCode ORDER BY MarketCode

-- Send it down to the report dataset
SELECT * FROM #ALP_R_JM_R152_Dropdown_Market

DROP TABLE #ALP_R_JM_R152_Dropdown_Market
END