
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktGetCompInfo_sp]
(
@CompID char(3)
)
 AS
SET NOCOUNT ON
SELECT 
Name, 
Addr1,
Addr2, 
City, 
Region, 
PostalCode, 
Phone, Logo
FROM SYS.dbo.tblSmCompInfo WHERE CompId =@CompID