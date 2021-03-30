CREATE PROCEDURE [dbo].[ALP_R_AR_R580_Customer_Dealers_DropDown]
AS
BEGIN
SET NOCOUNT ON;

select CustID, CustName
FROM ALP_tblArCust_view
WHERE (AlpDealerYn<> 0)
ORDER BY CustId

END