﻿CREATE TYPE [dbo].[pEisID]
    FROM NVARCHAR (50) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pEisID] TO PUBLIC;

