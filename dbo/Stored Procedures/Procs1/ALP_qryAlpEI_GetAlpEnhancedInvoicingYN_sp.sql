CREATE procedure [dbo].[ALP_qryAlpEI_GetAlpEnhancedInvoicingYN_sp]  
As  
 Begin  
  /*  
  Created by Sudharson - EFI# 1901 07/14/2010 - Added to check the Enhanced Invoicing feature is installed  
  */  
  Select AlpEnhancedInvoicingYN from tblArOption  
 End