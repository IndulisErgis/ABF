





CREATE PROCEDURE [dbo].[ALP_R_AR_R407_Dropdown_Market] 
AS
BEGIN
SET NOCOUNT ON;
--provides market options for report dropdown - 03/18/2015 - ER

-- Create a Temp table with Market varchar(255)
CREATE TABLE #ALP_R_AR_R407_Dropdown_Market(Market varchar(255),MarketType varchar(255))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #ALP_R_AR_R407_Dropdown_Market(Market,MarketType) Values ('<ALL>','<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #ALP_R_AR_R407_Dropdown_Market 
	SELECT MarketType
	, CASE WHEN MarketType=1 THEN 'RESIDENTIAL' WHEN MarketType=2 THEN 'COMMERCIAL' ELSE 'GOVERNMENT' END AS ResComGov 
	FROM ALP_tblArAlpMarket GROUP BY MarketType ORDER BY MarketType

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_R407_Dropdown_Market

DROP TABLE #ALP_R_AR_R407_Dropdown_Market
END