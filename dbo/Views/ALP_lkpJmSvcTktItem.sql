
  
CREATE VIEW [dbo].[ALP_lkpJmSvcTktItem] AS SELECT ResDesc, ItemId ,TicketId
--Below column added by NSK on 20 Apr 2015
,Comments
 FROM dbo.ALP_tblJmSvcTktItem