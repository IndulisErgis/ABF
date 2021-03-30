CREATE      Procedure [dbo].[ALP_qryCSOptions_Update_sp]  
 @ID int,
 @SignalDateAllowance smallint,  
 @CancelDateAllowance smallint,  
 @StartBillingAllowance smallint

 
AS  

SET NOCOUNT ON  
Update ALP_tblCSOptions set  SignalDateAllowance= @SignalDateAllowance,CancelDateAllowance= @CancelDateAllowance, StartBillingAllowance= @StartBillingAllowance
where ID=@ID