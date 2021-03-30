


CREATE VIEW dbo.ALP_stpJm0021SvcJobPrice
--EFI# 1456 MAH 06/20/04 - allowed for null values in LabPriceTotal field
AS
SELECT dbo.ALP_tblJmSvcTkt.TicketId, dbo.ALP_tblJmSvcTkt.PartsPrice, 
	 LaborPrice = CASE WHEN LabPriceTotal Is Null THEN 0 ELSE LabPriceTotal END,
	CASE WHEN OtherPriceExt Is Null THEN 0 ELSE OtherPriceExt END AS OtherPrice,
	Sum(CASE WHEN PartsPrice Is Null THEN 0 ELSE PartsPrice END)
	+ Sum(CASE WHEN LabPriceTotal Is Null THEN 0 ELSE LabPriceTotal END)
	+ Sum(CASE WHEN OtherPriceExt Is Null THEN 0 ELSE OtherPriceExt END) AS JobPrice
FROM         dbo.ALP_tblJmSvcTkt LEFT OUTER JOIN
                      dbo.ALP_stpJm0003SvcActionsOtherItems ON dbo.ALP_tblJmSvcTkt.TicketId = dbo.ALP_stpJm0003SvcActionsOtherItems.TicketId 
GROUP BY dbo.ALP_tblJmSvcTkt.TicketId, dbo.ALP_tblJmSvcTkt.PartsPrice, dbo.ALP_tblJmSvcTkt.LabPriceTotal, dbo.ALP_stpJm0003SvcActionsOtherItems.OtherPriceExt