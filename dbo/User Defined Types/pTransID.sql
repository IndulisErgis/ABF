﻿CREATE TYPE [dbo].[pTransID]
    FROM VARCHAR (8) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pTransID] TO PUBLIC;
