
CREATE VIEW [dbo].[ALP_lkpCSTransmitterExceptions]  
AS  
SELECT     TOP 100 PERCENT Transmitter  
FROM         dbo.ALP_tblCSTransmitterExceptions  
ORDER BY Transmitter