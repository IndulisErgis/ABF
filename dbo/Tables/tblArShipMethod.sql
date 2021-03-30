CREATE TABLE [dbo].[tblArShipMethod] (
    [ShipMethodID]      VARCHAR (6)   NOT NULL,
    [Desc]              VARCHAR (20)  NULL,
    [ts]                ROWVERSION    NULL,
    [OnlineTrackYn]     BIT           CONSTRAINT [DF_tblArShipMethod_OnlineTrackYn] DEFAULT ((0)) NOT NULL,
    [InternetPath]      VARCHAR (255) NULL,
    [HoldingCharacters] VARCHAR (10)  NULL,
    [Additional1]       VARCHAR (50)  NULL,
    [Additional2]       VARCHAR (50)  NULL,
    [CF]                XML           NULL,
    PRIMARY KEY CLUSTERED ([ShipMethodID] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArShipMethod';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArShipMethod';

