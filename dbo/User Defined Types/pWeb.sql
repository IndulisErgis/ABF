﻿CREATE TYPE [dbo].[pWeb]
    FROM VARCHAR (255) NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pWeb] TO PUBLIC;
