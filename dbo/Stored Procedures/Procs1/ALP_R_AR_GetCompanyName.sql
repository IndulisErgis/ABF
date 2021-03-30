CREATE PROCEDURE [dbo].[ALP_R_AR_GetCompanyName]
AS
BEGIN
SET NOCOUNT ON;
SELECT 
[Name] AS CompanyName,
Addr1,
Addr2,
City,
Region,
PostalCode,
[CompId],
DB_NAME() AS DataBaseName

FROM [SYS].[dbo].[tblSmCompInfo]
WHERE DB_NAME() = [CompID]
END