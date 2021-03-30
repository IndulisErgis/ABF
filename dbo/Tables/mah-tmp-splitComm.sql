CREATE TABLE [dbo].[mah-tmp-splitComm] (
    [TicketId]     INT          NOT NULL,
    [Expr1]        INT          NULL,
    [CommPaidDate] DATETIME     NULL,
    [CommAmt]      [dbo].[pDec] NULL,
    [CommSplitYn]  BIT          NULL,
    [CommPayNowYn] BIT          NULL
);

