

CREATE VIEW [dbo].[ALP_lkpCSServices]  
AS  
SELECT ALP_tblCSServices.CSSvcID, ALP_tblCSServices.SvcCode, ALP_tblCSServices.Descr  , ALP_tblCSsvcperbillingCode.CSsvcperBillCodeID, 
ALP_tblCSsvcperbillingCode.ItemId
FROM ALP_tblCSServices INNER JOIN
     ALP_tblCSsvcperbillingCode ON ALP_tblCSServices.CSSvcID = ALP_tblCSsvcperbillingCode.CSSvcID