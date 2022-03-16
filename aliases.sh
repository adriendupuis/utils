source ~/utils/functions.sh;

alias utils-install='utils-update';
alias utils-update='_utils_update';
alias utils-version='_utils_version';

alias git-graph='git log --all --graph --date-order --oneline --decorate';
alias git-current-branch='git rev-parse --abbrev-ref HEAD';
alias git-current-commit='git rev-parse --verify --short HEAD';
alias git-current-tag='git fetch --tags --force --quiet && git describe --tags 2> /dev/null';
alias git-reset='git reset --hard origin/$(git-current-branch)';
alias git-clean-local-branches='git fetch --prune --quiet && git branch -vv | grep -v  "^\*" | grep "\[.*: gone\]" | cut -d " " -f 3 | xargs git branch --delete';
alias git-force-pull='git fetch --force && git pull --force';
alias git-global-ignore='git config --global core.excludesfile "~/utils/gitignore"';

alias sf-cs-fix='php-cs-fixer fix --rules=@Symfony';

alias gz='gzip --keep';

alias docker-ps='docker ps --all --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Networks}}\t{{.Ports}}\t{{.Image}}"'
alias docker-rm='docker rm --force --volumes';
alias docker-prune='docker system prune --all --force';
alias docker-comp-env='docker-compose --env-file=$(if [[ -e .env.local ]]; then echo .env.local; else echo .env; fi;)';
alias docker-comp-rm='docker-compose rm -fv --stop';
alias docker-comp-www='docker-compose exec -u www-data';
alias docker-comp-logs='docker-compose logs --follow';
alias docker-rm-img='_docker_rm'
alias docker-start-img='_docker_cmd_select start Image';
alias docker-start-name='_docker_cmd_select start Names';
alias docker-stop-img='_docker_cmd_select stop Image';
alias docker-stop-name='_docker_cmd_select stop Names';
alias docker-rm-img='_docker_cmd_select "rm --force --volumes" Image';
alias docker-rm-name='_docker_cmd_select "rm --force --volumes" Names';
