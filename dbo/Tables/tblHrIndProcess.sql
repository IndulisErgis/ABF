CREATE TABLE [dbo].[tblHrIndProcess] (
    [ID]                   BIGINT         NOT NULL,
    [IndId]                [dbo].[pEmpID] NOT NULL,
    [ProcessTypeCodeId]    BIGINT         NOT NULL,
    [ProcessGroupDetailID] BIGINT         NOT NULL,
    [PersonResponsible]    [dbo].[pEmpID] NULL,
    [Status]               TINYINT        CONSTRAINT [DF_tblHrIndProcess_Status] DEFAULT ((0)) NOT NULL,
    [DateCompleted]        DATETIME       NULL,
    [CF]                   XML            NULL,
    [ts]                   ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrIndProcess] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndProcess_IndId]
    ON [dbo].[tblHrIndProcess]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndProcess';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndProcess';

