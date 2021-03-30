

CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktCommSplitDelete]	
@CommSplitID int
AS
Delete ALP_tblJmSvcTktCommSplit  where CommSplitID=@CommSplitID