CREATE TABLE [dbo].[tblPaLeaveCodeHdr] (
    [Id]                 [dbo].[pCode] NOT NULL,
    [Description]        NVARCHAR (35) NULL,
    [MaxAccrual]         [dbo].[pDec]  CONSTRAINT [DF_tblPaLeaveCodeHdr_MaxAccrual] DEFAULT ((0)) NOT NULL,
    [IncludeAccrualCalc] BIT           CONSTRAINT [DF_tblPaLeaveCodeHdr_IncludeAccrualCalc] DEFAULT ((0)) NOT NULL,
    [CF]                 XML           NULL,
    [ts]                 ROWVERSION    NULL,
    CONSTRAINT [PK_tblPaLeaveCodeHdr] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaLeaveCodeHdr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaLeaveCodeHdr';

