alias git-graph='git log --all --graph --date-order --oneline --decorate';
alias git-current-branch='git rev-parse --abbrev-ref HEAD';
alias git-current-commit='git rev-parse --verify --short HEAD';
alias git-current-tag='git fetch --tags --force && git describe --tags';
alias git-reset='git reset --hard origin/$(git-current-branch)';
alias git-clean-local-branches='git fetch --quiet && for branch in $(git branch -vv | grep -v  "^\*" | grep "\[.*: gone\]" | cut -d " " -f 3); do git branch --delete "$branch"; done'
