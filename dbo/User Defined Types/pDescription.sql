CREATE TYPE [dbo].[pDescription]
    FROM NVARCHAR (255) NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pDescription] TO PUBLIC;

