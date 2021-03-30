

CREATE PROCEDURE [dbo].[ALP_R_AR_R510C_NetOpenItems_SPECIAL_3]
(
@CustID varchar(10)
)
AS
BEGIN
CREATE TABLE #OIU2
(AlpSiteID int,
FirstOfTransDate datetime,
InvoiceDate datetime,
InvcNum nvarchar(15),
Amount decimal(10,2),
Applied decimal(10,2),
Balance decimal(10,2),
CustID varchar(10)
)		 


--INSERT #OIU2 EXECUTE ALP_R_AR_R510C_CollectRptBySalesRep_SPECIAL @CustID,'1','1','1','1'
--INSERT #OIU2 EXECUTE ALP_R_AR_R510C_CollectRptBySalesRep_SPECIAL '104450','1','1','1','1'
INSERT #OIU2 EXECUTE qryJm110b00ARItems_sp '113449'

select * from #OIU2

--ALTER TABLE #OIU2
--ADD	
--CustName varchar(30),
--AlpFirstName varchar(30),
--Contact varchar(25),
--Phone varchar(15),
--CurAmtDue Decimal(20,10),
--BalAge1 Decimal(20,10),
--BalAge2 Decimal(20,10),
--BalAge3 Decimal(20,10),
--BalAge4 Decimal(20,10),	
--UnapplCredit Decimal(20,10),
--SiteName varchar(80),
--SiteFirstName varchar(30)	

--select * from #OIU2	 
--------------------------THIS WORKS TO THIS POINT --------------------------------------

	
--INSERT INTO #OIU2
--(
--CustName varchar(30),
--AlpFirstName varchar(30),
--Contact varchar(25),
--Phone varchar(15),
--CurAmtDue Decimal(20,10),
--BalAge1 Decimal(20,10),
--BalAge2 Decimal(20,10),
--BalAge3 Decimal(20,10),
--BalAge4 Decimal(20,10),	
--UnapplCredit Decimal(20,10),
--SiteName varchar(80),
--SiteFirstName varchar(30)	

--)

--VALUES
--(
--#OpenItemsUnique.AlpSiteID,
--#OpenItemsUnique.FirstOfTransDate,
--#OpenItemsUnique.InvoiceDate,
--#OpenItemsUnique.InvcNum,
--#OpenItemsUnique.Amount,
--#OpenItemsUnique.Applied,
--#OpenItemsUnique.Balance,
--#OpenItemsUnique.CustID
--)
--


--SELECT * FROM #OpenItemsUnique	  
--GO

--DROP TABLE #OpenItemsUnique  

DROP TABLE #OIU2  

 
END