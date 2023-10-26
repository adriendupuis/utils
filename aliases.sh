source ~/utils/functions.sh;

alias utils-install='utils-update';
alias utils-update='_utils_update';
alias utils-version='_utils_version';

alias git-graph='git log --all --graph --date-order --oneline --decorate';
alias git-current-branch='git rev-parse --abbrev-ref HEAD';
alias git-current-commit='git rev-parse --verify --short HEAD';
alias git-current-tag='git fetch --tags --force --quiet && git describe --tags 2> /dev/null';
alias git-tag-list='git fetch --tags --force --quiet && git tag --sort=-committerdate --format "%(refname:short)%09%(committerdate:short)%09%(objectname:short=8)"';
alias git-reset='git reset --hard origin/$(git-current-branch)';
alias git-clean-local-branches='git fetch --prune --quiet && git branch -vv | grep -v  "^\*" | grep "\[.*: gone\]" | cut -d " " -f 3 | xargs git branch --delete';
alias git-force-pull='git fetch --force && git pull --force';
alias git-delete-tag='_git_delete_tag';
alias git-global-ignore='git config --global core.excludesfile "~/utils/gitignore"';

alias sf-cs-fix='php-cs-fixer fix --rules=@Symfony';

alias gz='gzip --keep';

alias textedit='open -e';
alias gimp='open -a Gimp'
