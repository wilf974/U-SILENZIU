-- Ajouter la colonne address à la table reservations
-- Cette colonne stockera l'adresse du client en JSON (optionnelle)

ALTER TABLE reservations 
ADD COLUMN IF NOT EXISTS address TEXT;

-- Commentaire pour expliquer l'utilisation
COMMENT ON COLUMN reservations.address IS 'Adresse de facturation du client au format JSON (optionnelle)';
