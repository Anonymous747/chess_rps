-- Add effect column to user_settings table
-- Run this SQL script directly on your database if migrations fail

ALTER TABLE user_settings 
ADD COLUMN IF NOT EXISTS effect VARCHAR;

