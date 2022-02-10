source ~/utils/functions.sh;

alias utils-install='utils-update';
alias utils-update='_utils_update';
alias utils-version='_utils_version';

alias git-graph='git log --all --graph --date-order --oneline --decorate';
alias git-current-branch='git rev-parse --abbrev-ref HEAD';
alias git-current-commit='git rev-parse --verify --short HEAD';
alias git-current-tag='git fetch --tags --force --quiet && git describe --tags 2> /dev/null';
alias git-reset='git reset --hard origin/$(git-current-branch)';
alias git-clean='git clean -df';
alias git-clean-local-branches='git fetch --prune --quiet && git branch -vv | grep -v  "^\*" | grep "\[.*: gone\]" | cut -d " " -f 3 | xargs git branch --delete';
alias git-force-pull='git fetch --force && git pull --force';
alias git-global-ignore='git config --global core.excludesfile "~/utils/gitignore"';

alias sf-cs-fix='php-cs-fixer fix --rules=@Symfony';

alias mv-ln='function _mv_ln { mv $1 $2 && ln -s $2 $1; }; _mv_ln';
alias cpd='function _cpd { mkdir -p ${@: -1} && cp $@; }; _cpd';
alias mvd='function _mvd { mkdir -p ${@: -1} && mv $@; }; _mvd';
alias gz='gzip --keep';

if [ 'Darwin' = `uname` ]; then
  # Mac OS X
  alias lsd='ls -GhalF@';
else
  alias lsd='ls -halF --color';
fi;
alias grep='grep --color=auto';
alias grepc='grep --color=always';
alias less='less --RAW-CONTROL-CHARS';

alias calc='bc -l <<< ';
