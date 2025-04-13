CREATE TABLE Ab_Computer (
    id VARCHAR(255) PRIMARY KEY, -- Utilisation de l'ID basé sur les coordonnées
    state ENUM('active', 'broken', 'lock', 'full_lock') NOT NULL DEFAULT 'active',
    health INT NOT NULL DEFAULT 100,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);