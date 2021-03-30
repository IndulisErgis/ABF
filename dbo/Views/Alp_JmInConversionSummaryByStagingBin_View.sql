CREATE View [dbo].[Alp_JmInConversionSummaryByStagingBin_View]
AS ( 
SELECT Alp_tmpJmSvcTktItem_IN_Conversion.ID, Alp_tmpJmSvcTktItem_IN_Conversion.TicketId, Alp_tmpJmSvcTktItem_IN_Conversion.TicketItemId,
 Alp_tmpJmSvcTktItem_IN_Conversion.ItemId, Alp_tmpJmSvcTktItem_IN_Conversion.Action, Alp_tmpJmSvcTktItem_IN_Conversion.Qty, 
 Alp_tmpJmSvcTktItem_IN_Conversion.UOM, Alp_tmpJmSvcTktItem_IN_Conversion.BaseQty,   Alp_tmpJmSvcTktItem_IN_Conversion.Category , 
 Alp_tmpJmSvcTktItem_IN_Conversion.PullDate, Alp_tmpJmSvcTktItem_IN_Conversion.QtySeqNum, Alp_tblJmSvcTkt.BinNumber, 
 UPPER(tblInItem.UomDflt) as UomDflt,ALP_tblJmSvcTktItem.[Desc] as Descr
 FROM Alp_tmpJmSvcTktItem_IN_Conversion INNER JOIN Alp_tblJmSvcTkt ON Alp_tmpJmSvcTktItem_IN_Conversion.TicketId = Alp_tblJmSvcTkt.TicketId 
 INNER JOIN tblInItem ON Alp_tmpJmSvcTktItem_IN_Conversion.ItemId = tblInItem.ItemId 
 LEFT OUTER JOIN   ALP_tblJmSvcTktItem ON ALP_tblJmSvcTktItem.ItemId =Alp_tmpJmSvcTktItem_IN_Conversion.ItemId 
 AND ALP_tblJmSvcTktItem.TicketId  =Alp_tmpJmSvcTktItem_IN_Conversion.TicketId 
 AND ALP_tblJmSvcTktItem.TicketItemId  =Alp_tmpJmSvcTktItem_IN_Conversion.TicketItemId
 WHERE (Alp_tmpJmSvcTktItem_IN_Conversion.Category = 1) 
)