CREATE TABLE [dbo].[tblHrIndWithhold] (
    [ID]               BIGINT           NOT NULL,
    [IndId]            [dbo].[pEmpID]   NOT NULL,
    [TaxAuthorityId]   INT              NOT NULL,
    [MaritalStatus]    NVARCHAR (3)     NULL,
    [Exemptions]       TINYINT          CONSTRAINT [DF_tblHrIndWithhold_Exemptions] DEFAULT ((0)) NOT NULL,
    [ExtraWithholding] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndWithhold_ExtraWithholding] DEFAULT ((0)) NOT NULL,
    [FixedWithholding] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndWithhold_FixedWithholding] DEFAULT ((0)) NOT NULL,
    [HomeState]        NVARCHAR (2)     NULL,
    [DefaultWH]        BIT              CONSTRAINT [DF_tblHrIndWithhold_DefaultWH] DEFAULT ((0)) NOT NULL,
    [SUIState]         NVARCHAR (2)     NULL,
    [EICCode]          NVARCHAR (1)     NULL,
    [CF]               XML              NULL,
    [ts]               ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrIndWithhold] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndWithhold_IndId]
    ON [dbo].[tblHrIndWithhold]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndWithhold';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndWithhold';

