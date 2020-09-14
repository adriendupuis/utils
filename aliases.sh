alias git-graph='git log --all --graph --date-order --oneline --decorate';
alias git-current-branch='git rev-parse --abbrev-ref HEAD';
alias git-current-commit='git rev-parse --verify --short HEAD';
alias git-current-tag='git fetch --tags --force --quiet && git describe --tags 2> /dev/null';
alias git-reset='git reset --hard origin/$(git-current-branch)';
alias git-clean-local-branches='git fetch --quiet && git branch -vv | grep -v  "^\*" | grep "\[.*: gone\]" | cut -d " " -f 3 | xargs git branch --delete';

alias docker-ps='docker ps --all --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Networks}}\t{{.Ports}}\t{{.Image}}"'
alias docker-rm='docker rm --force --volumes';
alias docker-comp-env='docker-compose --env-file=$(if [[ -e .env.local ]]; then echo .env.local; else echo .env; fi;)';
alias docker-comp-rm='docker-compose rm -fv --stop';
alias docker-comp-www='docker-compose exec -u www-data';
