CREATE  Procedure [dbo].[ALP_rptAlpEI_GetCustExchangeRate_sp]    
 @CustID pCustID,    
 @BaseCurrency pCurrency    
As    
Begin    
 declare @CustCurrencyID pCurrency    
 SET @CustCurrencyID = (SELECT CurrencyID from tblArCust where custid = @CustID)    
 SELECT CurrencyID from tblArCust where custid = @CustID    
 IF(@BaseCurrency <> @CustCurrencyID)    
  Select  ExchRate ,  EffectDate from ALP_lkpSmExchRate    
   where CurrencyTo  = @CustCurrencyID and CurrencyFrom = @BaseCurrency ORDER BY EffectDate Desc    
 ELSE    
  Select  1 AS ExchRate, '01/01/1900' AS EffectDate    
END