#!/bin/sh

# @see https://github.com/pypa/pipx/releases

if [ ! -f auth-pocket.json ]; then
	pipx.pyz run pocket-to-sqlite auth --auth auth-pocket.json
fi

if [ ! -f auth-github.json ]; then
	pipx.pyz run github-to-sqlite auth --auth auth-github.json
fi

# pipx.pyz run pocket-to-sqlite fetch pocket.db --all --auth auth-pocket.json
# pipx.pyz run pocket-to-sqlite fetch pocket.db --auth auth-pocket.json

#pipx.pyz github-to-sqlite starred github.db empjustine --auth auth-github.json
#pipx.pyz github-to-sqlite repos github.db empjustine --auth auth-github.json
#pipx.pyz github-to-sqlite get --auth auth-github.json --accept 'application/vnd.github.v3+json' --paginate --nl https://api.github.com/gists >"gists.ndjson"
#pipx.pyz github-to-sqlite get --auth auth-github.json --accept 'application/vnd.github.v3+json' --paginate --nl https://api.github.com/gists/starred >gists.starred.ndjson

pipx.pyz run pocket-to-sqlite fetch pocket.db --auth auth-pocket.json
pipx.pyz run github-to-sqlite starred github.db empjustine --auth auth-github.json
pipx.pyz run github-to-sqlite repos github.db empjustine --auth auth-github.json

# pipx.pyz run datasette serve pocket.db github.db --metadata metadata.json
