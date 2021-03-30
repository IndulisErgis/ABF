CREATE TABLE [dbo].[tblCmContactAccessFilter] (
    [ID]       BIGINT         NOT NULL,
    [LinkType] SMALLINT       NOT NULL,
    [LinkID]   NVARCHAR (255) NOT NULL,
    [Filter]   NVARCHAR (MAX) NULL,
    [CF]       XML            NULL,
    [ts]       ROWVERSION     NULL,
    CONSTRAINT [PK_tblCmContactAccessFilter] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblCmContactAccessFilter_LinkTypeID]
    ON [dbo].[tblCmContactAccessFilter]([LinkType] ASC, [LinkID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactAccessFilter';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactAccessFilter';

