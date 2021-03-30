CREATE TABLE [dbo].[tblPcEmpRates] (
    [Id]        INT            IDENTITY (1, 1) NOT NULL,
    [EmpId]     [dbo].[pEmpID] NOT NULL,
    [RateId]    NVARCHAR (10)  NOT NULL,
    [Rate]      [dbo].[pDec]   CONSTRAINT [DF_tblPcEmpRates_Rate] DEFAULT ((0)) NOT NULL,
    [Cost]      [dbo].[pDec]   CONSTRAINT [DF_tblPcEmpRates_Cost] DEFAULT ((0)) NOT NULL,
    [EarnCode]  NVARCHAR (3)   NULL,
    [DefaultYN] BIT            CONSTRAINT [DF_tblPcEmpRates_DefaultYN] DEFAULT ((0)) NOT NULL,
    [CF]        XML            NULL,
    [ts]        ROWVERSION     NULL,
    CONSTRAINT [PK_tblPcEmpRates] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [uiEmpRates]
    ON [dbo].[tblPcEmpRates]([EmpId] ASC, [RateId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcEmpRates';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcEmpRates';

