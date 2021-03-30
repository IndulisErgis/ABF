
CREATE VIEW dbo.ALP_lkpJmTimeCardSvcTkt AS SELECT DISTINCT(ALP_tblJmTimeCard.TechID),ALP_tblJmTimeCard.TicketId FROM ALP_tblJmTimeCard
 INNER JOIN ALP_tblJmSvcTkt ON ALP_tblJmTimeCard.TicketId = ALP_tblJmSvcTkt.TicketId