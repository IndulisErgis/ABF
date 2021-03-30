
CREATE VIEW [dbo].[ALP_lkpArTransHeader]
AS
SELECT     TransId, CustId, AlpJobNum, InvcNum, AlpFromJobYN
FROM         dbo.ALP_tblArTransHeader_view