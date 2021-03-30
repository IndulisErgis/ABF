CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktCommSplitUpdate]
-- modified by MAH 02/28/14 - corrected the precision of the CommAmt field. Changed from decimal to decimal (20,10)

@CommSplitID int,
@TicketID int,
@SalesRep varchar(3),
@CommSplitPct float(8)= 100,
@CommAmt decimal(20,10) =0,
@JobShare float(8)= 100,
@Comments text,
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@ModifiedBy varchar(50)

AS
Update ALP_tblJmSvcTktCommSplit  set SalesRep= @SalesRep,CommSplitPct=@CommSplitPct,CommAmt=@CommAmt,JobShare=@JobShare,Comments=@Comments,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE() where CommSplitID=@CommSplitID