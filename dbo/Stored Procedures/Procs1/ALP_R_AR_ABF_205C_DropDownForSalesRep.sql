


CREATE PROCEDURE [dbo].[ALP_R_AR_ABF_205C_DropDownForSalesRep]
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with SalesRep varchar(50)
CREATE TABLE #R205C_SalesRep_Dropdown(SaleRep varchar(50))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #R205C_SalesRep_Dropdown (SaleRep) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #R205C_SalesRep_Dropdown SELECT AlpSalesRepID FROM ALP_tblArSalesRep WHERE AlpInactiveYn = 0

-- Send it down to the report dataset
SELECT * FROM #R205C_SalesRep_Dropdown

DELETE FROM #R205C_SalesRep_Dropdown
DROP TABLE #R205C_SalesRep_Dropdown

END