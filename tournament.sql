-- Table definitions for the tournament project.

DROP DATABASE IF EXISTS tournament;

CREATE DATABASE tournament;
\c tournament

CREATE TABLE players(
  id serial PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE matches(
  match_id serial PRIMARY KEY,
  winner int REFERENCES players(id) ON DELETE CASCADE,
  loser int REFERENCES players(id) ON DELETE CASCADE,
  CHECK (winner <> loser)
);

CREATE VIEW wincount
  AS SELECT players.id, coalesce(count(matches.winner),0)
  AS wins FROM players
  LEFT JOIN matches
  ON players.id = matches.winner
  GROUP BY players.id
  ORDER BY wins DESC;

CREATE VIEW totalmatches
  AS SELECT players.id, coalesce(count(matches.winner + matches.loser),0)
  AS total_matches FROM players
  LEFT JOIN matches
  ON players.id = matches.winner
  OR players.id = matches.loser
  GROUP BY players.id;

CREATE VIEW standings
  AS SELECT players.id, players.name,
  (SELECT wincount.wins AS wins FROM wincount WHERE wincount.id = players.id),
  (SELECT total_matches
  FROM totalmatches
  WHERE totalmatches.id = players.id)
  FROM players
  LEFT JOIN wincount
  ON players.id=wincount.id
  GROUP BY players.id, players.name
  ORDER BY wins DESC;