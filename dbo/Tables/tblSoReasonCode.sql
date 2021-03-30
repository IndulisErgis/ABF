CREATE TABLE [dbo].[tblSoReasonCode] (
    [ResCode]  VARCHAR (10) NOT NULL,
    [Descr]    VARCHAR (35) NULL,
    [ActiveYN] BIT          DEFAULT ((0)) NULL,
    [ts]       ROWVERSION   NULL,
    [CF]       XML          NULL,
    PRIMARY KEY CLUSTERED ([ResCode] ASC) WITH (FILLFACTOR = 90)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoReasonCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoReasonCode';

