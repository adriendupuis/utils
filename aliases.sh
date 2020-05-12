alias utils-install='utils-update';
alias utils-update='function _utils_update { cd ~/utils; git fetch; if [[ 0 < $# ]]; then git checkout $1; fi; git pull; }; _utils_update';
alias utils-version='cd ~/utils && git-current-tag'

alias git-graph='git log --all --graph --date-order --oneline --decorate';
alias git-current-branch='git rev-parse --abbrev-ref HEAD';
alias git-current-commit='git rev-parse --verify --short HEAD';
alias git-current-tag='git fetch --tags --force --quiet && git describe --tags 2> /dev/null';
alias git-reset='git reset --hard origin/$(git-current-branch)';
alias git-clean-local-branches='git fetch --quiet && for branch in $(git branch -vv | grep -v  "^\*" | grep "\[.*: gone\]" | cut -d " " -f 3); do git branch --delete "$branch"; done';
