CREATE TABLE IF NOT EXISTS Ab_Garbages (
    StashID VARCHAR(255) NOT NULL, 
    CoordID VARCHAR(255) NOT NULL,
    GarbageKind VARCHAR(255) NOT NULL,
    label VARCHAR(255) NOT NULL,
    slots INT NOT NULL,
    weight INT NOT NULL,
    PRIMARY KEY (StashID, CoordID)  -- On définit la clé primaire combinée par StashID et CoordID
);