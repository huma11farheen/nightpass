-- Add Google Places sync columns to club table
ALTER TABLE club
  ADD COLUMN IF NOT EXISTS is_active       boolean   NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS place_id        text      UNIQUE,
  ADD COLUMN IF NOT EXISTS last_synced_at  timestamptz;

-- All existing partner clubs stay active
UPDATE club SET is_active = true WHERE partner_club = true;

-- Index for fast map queries
CREATE INDEX IF NOT EXISTS idx_club_map
  ON club (partner_club, is_active, venue_type);
