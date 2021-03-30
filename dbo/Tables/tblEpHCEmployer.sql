CREATE TABLE [dbo].[tblEpHCEmployer] (
    [ID]                    BIGINT       NOT NULL,
    [PaYear]                SMALLINT     NOT NULL,
    [Status]                TINYINT      NOT NULL,
    [GovEntity]             NVARCHAR (1) NOT NULL,
    [ALEGroup]              NVARCHAR (1) NOT NULL,
    [SelfInsured]           NVARCHAR (1) NOT NULL,
    [QualifyingOfferMethod] NVARCHAR (1) NOT NULL,
    [QOMTransitionRelief]   NVARCHAR (1) NOT NULL,
    [4980HTransitionRelief] NVARCHAR (1) NOT NULL,
    [98PctOfferMethod]      NVARCHAR (1) NOT NULL,
    [CF]                    XML          NULL,
    [ts]                    ROWVERSION   NULL,
    CONSTRAINT [PK_tblEpHCEmployer] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblEpHCEmployer_PaYear]
    ON [dbo].[tblEpHCEmployer]([PaYear] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployer';

