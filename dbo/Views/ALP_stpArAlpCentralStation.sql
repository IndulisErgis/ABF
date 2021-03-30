CREATE VIEW dbo.ALP_stpArAlpCentralStation  
AS  
SELECT     TOP 100 PERCENT CentralId, Central, InactiveYN, Name, Addr1, Addr2, City, Region, Country, PostalCode, IntlPrefix, Phone, Fax, Email, Internet,   
                      DealerNum, CompOwnedYN, MonSoftwareYN, MonSoftwareId, ts  
FROM         dbo.ALP_tblArAlpCentralStation  
ORDER BY Central