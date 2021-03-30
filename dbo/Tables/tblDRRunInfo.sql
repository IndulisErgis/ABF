CREATE TABLE [dbo].[tblDRRunInfo] (
    [RunId]   [dbo].[pPostRun] NOT NULL,
    [RunDate] DATETIME         CONSTRAINT [DF_tblDrRunInfo_RunDate] DEFAULT (getdate()) NOT NULL,
    [Flags]   INT              CONSTRAINT [DF_tblDrRunInfo_Flags] DEFAULT ((0)) NOT NULL,
    [CF]      XML              NULL,
    [ts]      ROWVERSION       NULL,
    CONSTRAINT [PK_tblDrRunInfo] PRIMARY KEY CLUSTERED ([RunId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDRRunInfo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDRRunInfo';

