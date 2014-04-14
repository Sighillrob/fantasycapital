GameScore.where(playdate: '2050-12-31', ext_game_id: 'FAKE-1562c93a-10ed-4346-b982-f73b4c10fb94', status: 'scheduled', scheduledstart: Time.new(2050,12,31), home_team: Team.where(ext_team_id: '583ec825-fb46-11e1-82cb-f4ce4684ea4c').first, away_team: Team.where(ext_team_id: '583ec773-fb46-11e1-82cb-f4ce4684ea4c').first).first_or_create
GameScore.where(playdate: '2050-12-31', ext_game_id: 'FAKE-15934c3a-cc82-4057-a313-2188db1edb1a', status: 'scheduled', scheduledstart: Time.new(2050,12,31), home_team: Team.where(ext_team_id: '583ecc9a-fb46-11e1-82cb-f4ce4684ea4c').first, away_team: Team.where(ext_team_id: '583ed056-fb46-11e1-82cb-f4ce4684ea4c').first).first_or_create
GameScore.where(playdate: '2050-12-31', ext_game_id: 'FAKE-d6c43df2-37c5-40e7-b12f-ec2c3fe3b6ed', status: 'scheduled', scheduledstart: Time.new(2050,12,31), home_team: Team.where(ext_team_id: '583ecda6-fb46-11e1-82cb-f4ce4684ea4c').first, away_team: Team.where(ext_team_id: '583eca88-fb46-11e1-82cb-f4ce4684ea4c').first).first_or_create
GameScore.where(playdate: '2050-12-31', ext_game_id: 'FAKE-db449bd5-33da-4bd5-9aac-13c9f56ead28', status: 'scheduled', scheduledstart: Time.new(2050,12,31), home_team: Team.where(ext_team_id: '583ec97e-fb46-11e1-82cb-f4ce4684ea4c').first, away_team: Team.where(ext_team_id: '583eca2f-fb46-11e1-82cb-f4ce4684ea4c').first).first_or_create
GameScore.where(playdate: '2050-12-31', ext_game_id: 'FAKE-869bb60b-b00f-40dd-8523-10e824d38ef2', status: 'scheduled', scheduledstart: Time.new(2050,12,31), home_team: Team.where(ext_team_id: '583ece50-fb46-11e1-82cb-f4ce4684ea4c').first, away_team: Team.where(ext_team_id: '583ecdfb-fb46-11e1-82cb-f4ce4684ea4c').first).first_or_create
GameScore.where(playdate: '2050-12-31', ext_game_id: 'FAKE-713067dd-82cd-4c80-beeb-10e53d869a02', status: 'scheduled', scheduledstart: Time.new(2050,12,31), home_team: Team.where(ext_team_id: '583ecd4f-fb46-11e1-82cb-f4ce4684ea4c').first, away_team: Team.where(ext_team_id: '583ecae2-fb46-11e1-82cb-f4ce4684ea4c').first).first_or_create
GameScore.where(playdate: '2050-12-31', ext_game_id: 'FAKE-86a69970-8047-461c-b844-0bcf967ebc26', status: 'scheduled', scheduledstart: Time.new(2050,12,31), home_team: Team.where(ext_team_id: '583ec8d4-fb46-11e1-82cb-f4ce4684ea4c').first, away_team: Team.where(ext_team_id: '583ec9d6-fb46-11e1-82cb-f4ce4684ea4c').first).first_or_create
GameScore.where(playdate: '2050-12-31', ext_game_id: 'FAKE-28174a5a-0cec-4b3c-8bc0-826910911f47', status: 'scheduled', scheduledstart: Time.new(2050,12,31), home_team: Team.where(ext_team_id: '583ecb8f-fb46-11e1-82cb-f4ce4684ea4c').first, away_team: Team.where(ext_team_id: '583ed102-fb46-11e1-82cb-f4ce4684ea4c').first).first_or_create
GameScore.where(playdate: '2050-12-31', ext_game_id: 'FAKE-c7bd7c1a-d065-4dfb-9973-53717b6bbe98', status: 'scheduled', scheduledstart: Time.new(2050,12,31), home_team: Team.where(ext_team_id: '583ec5fd-fb46-11e1-82cb-f4ce4684ea4c').first, away_team: Team.where(ext_team_id: '583ed0ac-fb46-11e1-82cb-f4ce4684ea4c').first).first_or_create
GameScore.where(playdate: '2050-12-31', ext_game_id: 'FAKE-17902077-a4f1-4da8-817d-c849462b05e3', status: 'scheduled', scheduledstart: Time.new(2050,12,31), home_team: Team.where(ext_team_id: '583ec70e-fb46-11e1-82cb-f4ce4684ea4c').first, away_team: Team.where(ext_team_id: '583ecefd-fb46-11e1-82cb-f4ce4684ea4c').first).first_or_create
GameScore.where(playdate: '2050-12-31', ext_game_id: 'FAKE-657ac7bd-8291-4ea9-98e7-00a2fc3da8d8', status: 'scheduled', scheduledstart: Time.new(2050,12,31), home_team: Team.where(ext_team_id: '583ec87d-fb46-11e1-82cb-f4ce4684ea4c').first, away_team: Team.where(ext_team_id: '583ec7cd-fb46-11e1-82cb-f4ce4684ea4c').first).first_or_create
GameScore.where(playdate: '2050-12-31', ext_game_id: 'FAKE-c06fe2aa-2c8a-42bd-870e-8151fe111cf9', status: 'scheduled', scheduledstart: Time.new(2050,12,31), home_team: Team.where(ext_team_id: '583eccfa-fb46-11e1-82cb-f4ce4684ea4c').first, away_team: Team.where(ext_team_id: '583ecfa8-fb46-11e1-82cb-f4ce4684ea4c').first).first_or_create

# remove a few simulated games (if found) that cause players to be part of 2 games.
# Simulation has 12 games instead of 16 after this.
GameScore.where(ext_game_id:['FAKE-caf6771b-8010-477c-8388-5d3e3fc9cf65', 'FAKE-ca876b9a-db68-4e85-b2bc-6e4e80100c0b', 'FAKE-c9cb0b2f-a044-4adb-81c7-72c07b6f58ba', 'FAKE-4f1f5787-4212-4e9d-9565-e11c949c0f29']).destroy_all
