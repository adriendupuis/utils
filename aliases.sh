alias git-graph='git log --all --graph --date-order --oneline --decorate';
alias git-current-branch='git rev-parse --abbrev-ref HEAD';
alias git-current-commit='git rev-parse --verify --short HEAD';
alias git-reset='git reset --hard origin/$(git-current-branch)';
alias git-clean-local-branches='echo TODO';
