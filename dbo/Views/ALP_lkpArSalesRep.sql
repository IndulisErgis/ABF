CREATE VIEW dbo.ALP_lkpArSalesRep
AS
SELECT     dbo.tblArSalesRep.SalesRepID, dbo.tblArSalesRep.Name, dbo.tblArSalesRep.Addr1, dbo.tblArSalesRep.Addr2, dbo.tblArSalesRep.City, dbo.tblArSalesRep.Region, 
                      dbo.tblArSalesRep.Country, dbo.tblArSalesRep.PostalCode, dbo.tblArSalesRep.IntlPrefix, dbo.tblArSalesRep.Phone, dbo.tblArSalesRep.Fax, dbo.tblArSalesRep.EmplId, 
                      dbo.tblArSalesRep.RunCode, dbo.tblArSalesRep.CommRate, dbo.tblArSalesRep.PctOf, dbo.tblArSalesRep.BasedOn, dbo.tblArSalesRep.PayOnLineItems, 
                      dbo.tblArSalesRep.PayOnSalesTax, dbo.tblArSalesRep.PayOnFreight, dbo.tblArSalesRep.PayOnMisc, dbo.tblArSalesRep.PTDSales, dbo.tblArSalesRep.YTDSales, 
                      dbo.tblArSalesRep.LastSalesDate, dbo.tblArSalesRep.Email, dbo.tblArSalesRep.Internet, dbo.tblArSalesRep.ts, dbo.tblArSalesRep.EarnCode, 
                      dbo.tblArSalesRep.PayVia, dbo.tblArSalesRep.VendorId, dbo.tblArSalesRep.CF, dbo.ALP_tblArSalesRep.AlpInactiveYn
FROM         dbo.tblArSalesRep INNER JOIN
                      dbo.ALP_tblArSalesRep ON dbo.tblArSalesRep.SalesRepID = dbo.ALP_tblArSalesRep.AlpSalesRepID