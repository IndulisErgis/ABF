
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktProjDelete]	
@SvcTktProjectId int
AS
Delete ALP_tblJmSvcTktProject where SvcTktProjectId=@SvcTktProjectId