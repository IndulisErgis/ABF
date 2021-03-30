CREATE FUNCTION [dbo].[ufxPresentValue] 
	(
	@CashFlow FLOAT, -- like 512.89 or (RMRAdded-RMRExp)
   @IntRateAnnual FLOAT, -- like .05 for 5%
	@months INT 
	) 

RETURNS MONEY 
AS 
  BEGIN 
	DECLARE @IntMonthly FLOAT
	DECLARE @A FLOAT
	DECLARE @B FLOAT
   DECLARE @Value FLOAT 	
    
   SET @IntMonthly = @IntRateAnnual/12
	SET @A = POWER( (1+@IntMonthly), -(@months))
	SET @B=(1-@A) / @IntMonthly
   SET @Value = @CashFlow * @B
	SET @Value=CAST(@Value as Money) 
    
   RETURN @Value

  END