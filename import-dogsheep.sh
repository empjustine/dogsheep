#!/bin/sh

if [ ! -f auth-pocket.json ]; then
	pipx run pocket-to-sqlite auth --auth auth-pocket.json
fi

# pipx run github-to-sqlite
if [ ! -f auth-github.json ]; then
	github-to-sqlite auth --auth auth-github.json
fi

# pipx run pocket-to-sqlite fetch pocket.db --all --auth auth-pocket.json
# pipx run pocket-to-sqlite fetch pocket.db --auth auth-pocket.json

#github-to-sqlite starred github.db empjustine --auth auth-github.json
#github-to-sqlite repos github.db empjustine --auth auth-github.json
#github-to-sqlite get --auth auth-github.json --accept 'application/vnd.github.v3+json' --paginate --nl https://api.github.com/gists >"gists.ndjson"
#github-to-sqlite get --auth auth-github.json --accept 'application/vnd.github.v3+json' --paginate --nl https://api.github.com/gists/starred >gists.starred.ndjson

venv/bin/pocket-to-sqlite fetch pocket.db --auth auth-pocket.json
venv/bin/github-to-sqlite starred github.db empjustine --auth auth-github.json
venv/bin/github-to-sqlite repos github.db empjustine --auth auth-github.json

# pipx run datasette serve pocket.db github.db --metadata metadata.json
