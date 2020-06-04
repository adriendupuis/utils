alias git-graph='git log --all --graph --date-order --oneline --decorate';
alias git-current-branch='git rev-parse --abbrev-ref HEAD';
alias git-current-commit='git rev-parse --verify --short HEAD';
alias git-current-tag='git fetch --tags --force --quiet && git describe --tags 2> /dev/null';
alias git-reset='git reset --hard origin/$(git-current-branch)';
alias git-clean-local-branches='git fetch --quiet && git branch -vv | grep -v  "^\*" | grep "\[.*: gone\]" | cut -d " " -f 3 | xargs git branch --delete';

alias package-version='function _composer_package_version { grep "\"name\": \".*$1\"" -A 5 composer.lock; }; _composer_package_version';
