CREATE Procedure [dbo].[ALP_qryALP_tblQMU]        
@UserName varchar(30)       
AS 

Select  * from ALP_tblQMU
where UserName=@UserName