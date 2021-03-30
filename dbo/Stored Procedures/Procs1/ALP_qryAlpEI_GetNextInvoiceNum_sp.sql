CREATE  procedure [dbo].[ALP_qryAlpEI_GetNextInvoiceNum_sp]      
as      
  -- Below rowlock method adde by ravi on 02.13.2015, To fix the user concurrency issue.
   /*   
    Created by Ravi for EFI#1962 03/10/2013  
    To get New Invoice Number  
   */  
Begin    

 Select * from tblSmFormNum  WITH (ROWLOCK) where FormId = 'AR INVOICE' 
 update tblSmFormNum  with(ROWLOCK) set NextNum = NextNum +1 where FormId = 'AR INVOICE'     
  
End