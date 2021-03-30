CREATE FUNCTION [dbo].[GetSiteServiceFuturePrice](@pserviceId int ) RETURNS decimal
AS
BEGIN
 DECLARE @Price decimal;
 DECLARE @BilledThruDate datetime;
 
  SELECT @BilledThruDate=BilledThruDate  FROM ALP_tblArAlpSiteRecBillServ WHERE RecBillServId =@pserviceId;
   if( @BilledThruDate IS NOT NULL OR @BilledThruDate <>'' )
   BEGIN
   	 SELECT Top 1 @Price =Price FROM ALP_tblArAlpSiteRecBillServPrice WHERE StartBillDate > @BilledThruDate ORDER BY StartBillDate
   END
   ELSE
   BEGIN
   	SELECT Top 1 @Price=Price   FROM ALP_tblArAlpSiteRecBillServPrice WHERE RecBillServId = @pserviceId ORDER BY StartBillDate  
   END
	RETURN @price ;
END