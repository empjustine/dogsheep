#!/bin/sh

_dependencies() {
	if [ ! -L venv ]; then
	    mkdir -p ~/.local/share/venv
	    python -m venv ~/.local/share/venv/dogsheep
	    ln -s ~/.local/share/venv/dogsheep/ venv
	fi

	# venv/bin/pip install --requirement requirements.in
	# venv/bin/pip freeze >requirements.txt
	venv/bin/pip install --requirement requirements.txt
}

_auth() {
	[ ! -f auth-pocket.json ] && venv/bin/pocket-to-sqlite auth --auth auth-pocket.json
	[ ! -f auth-github.json ] && venv/bin/github-to-sqlite auth --auth auth-github.json
}

_pocket() {
	# venv/bin/pocket-to-sqlite fetch --all pocket.db --auth auth-pocket.json
	venv/bin/pocket-to-sqlite fetch pocket.db --auth auth-pocket.json
}

_github() {
	venv/bin/github-to-sqlite starred github.db empjustine --auth auth-github.json
	venv/bin/github-to-sqlite repos github.db empjustine --auth auth-github.json
}

_gists() {
	venv/bin/github-to-sqlite get --auth auth-github.json --accept 'application/vnd.github.v3+json' --paginate --nl https://api.github.com/gists/starred >gists.starred.jsonnl
	venv/bin/github-to-sqlite get --auth auth-github.json --accept 'application/vnd.github.v3+json' --paginate --nl https://api.github.com/gists >gists.user.jsonnl

	_starred="$(pwd)/gists.starred.jsonnl"
	_user="$(pwd)/gists.user.jsonnl"

	(
		git init --bare --shared=group ~/com.github.gist.starred.git
		cd ~/com.github.gist.starred.git || exit 1
		jq -r '.html_url' "$_starred" | while read -r u; do
			git remote add "$(basename "$u")" "${u}.git"
		done
		git remote | xargs -r -n 1 -P 3 git remote update
	)
	(
		git init --bare --shared=group ~/com.github.gist.user.git
		cd ~/com.github.gist.user.git || exit 1
		jq -r '.html_url' "$_user" | while read -r u; do
			git remote add "$(basename "$u")" "${u}.git"
		done
		git remote | xargs -r -n 1 -P 3 git remote update
	)
}

_serve_datasette() {
	venv/bin/datasette serve pocket.db --metadata metadata.json
}

_main() {
	_dependencies
	_auth
	_pocket
	#_github
	#_gists
	#_serve_datasette
}
_main