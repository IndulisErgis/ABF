

CREATE PROCEDURE [dbo].[ALP_R_AR_R510C_NetOpenItems_WithCSFix]
(
@CustID varchar(10),
@AlpSiteID int OUTPUT,
@FirstOfTransDate datetime OUTPUT,
@InvoiceDate datetime OUTPUT,
@InvcNum nvarchar(15) OUTPUT,
@Amount decimal(10,2) OUTPUT,
@Applied decimal(10,2) OUTPUT,
@Balance decimal(10,2) OUTPUT
)
AS

CREATE TABLE #OIU2
(
CustID varchar(10),
AlpSiteID int,
FirstOfTransDate datetime,
InvoiceDate datetime,
InvcNum nvarchar(15),
Amount decimal(10,2),
Applied decimal(10,2),
Balance decimal(10,2)
)		 

INSERT #OIU2 EXECUTE ALP_R_AR_R510C_NetOpenItems_SPECIAL_1 @CustID
select * from #OIU2
SELECT @AlpSiteID = AlpSiteID
FROM #OIU2
WHERE @CustID = CustID

RETURN