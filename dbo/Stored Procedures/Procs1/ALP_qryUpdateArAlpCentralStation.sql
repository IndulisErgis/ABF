CREATE PROCEDURE [dbo].[ALP_qryUpdateArAlpCentralStation]	
@CentralId int,
@Name varchar(255),
@Addr1 varchar(255),
@Addr2 varchar(255),
@PostalCode varchar(10),
@Phone varchar(15),
@Fax varchar(15),
@Email text,
@DealerNum varchar(255)

AS

Update ALP_tblArAlpCentralStation set Name=@Name,Addr1=@Addr1,Addr2=@Addr2,PostalCode=@PostalCode,
Phone=@Phone,Fax=@Fax,Email=@Email,DealerNum=@DealerNum
where CentralId=@CentralId