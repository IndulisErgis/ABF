CREATE TABLE [dbo].[tblCmContactRelation] (
    [ID]            BIGINT          NOT NULL,
    [ContactID]     BIGINT          NOT NULL,
    [RelationID]    BIGINT          NOT NULL,
    [Sequence]      SMALLINT        CONSTRAINT [DF_tblCmContactRelation_Sequence] DEFAULT ((0)) NOT NULL,
    [LastUpdated]   DATETIME        NOT NULL,
    [LastUpdatedBy] [dbo].[pUserID] NOT NULL,
    [CF]            XML             NULL,
    [ts]            ROWVERSION      NULL,
    CONSTRAINT [PK_tblCmContactRelation] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UC_tblCmContactRelation] UNIQUE NONCLUSTERED ([ContactID] ASC, [RelationID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactRelation';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactRelation';

