CREATE PROCEDURE dbo.Alp_qryArAlpCustTrans @Cust varchar(10)  
As  
SET NOCOUNT ON  
SELECT Sum(([TaxSubTotal]+[NonTaxSubTotal]+[SalesTax]+[Freight]+[Misc])*Sign([TransType])) AS Amount  
FROM  tblArTransHeader  
WHERE (((tblArTransHeader.CustId)=@Cust));