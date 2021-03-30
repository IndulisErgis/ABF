CREATE VIEW [dbo].[ALP_lkpJmSvcTktPriceId]  
AS  
--removed as record exists in table already, no need for default. #20180501DMM
--Select '0' as PriceId,'' as [Desc],0 as InactiveYN union  
SELECT     PriceId, [Desc], InactiveYN  
FROM         dbo.ALP_tblJmPricePlanGenHeader  
WHERE     (InactiveYN = 0)