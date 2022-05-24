function _utils_update {
  cd ~/utils;

  previous=$(_utils_version);

  git fetch --quiet;
  if [[ 0 -lt $# ]]; then
    git checkout --quiet "$1" 2> /dev/null;
    if [[ 0 -lt $? ]]; then
      echo "Error: can't checkout $1";
      return;
    fi;
  else
    git checkout --quiet master 2> /dev/null;
  fi;
  git pull --quiet;

  current=$(_utils_version);

  if [ "$current" == "$previous" ]; then
    echo "Info: Utils is up-to-date and in $previous";
  else
    rc=~/.${SHELL##*/}rc;
    if [[ -f $rc ]]; then
      source $rc;
      echo "Info: $rc reloaded.";
    else
      source ~/utils/aliases.sh;
      echo 'Notice: ~/utils/aliases.sh reloaded. Shell RC file might need a manual reload too.';
    fi;
    echo "Info: Utils updated from $previous to $current.";
  fi
}

function _utils_version {
  cd ~/utils;

  git fetch --tags --quiet;
  version=$(git describe --tags 2> /dev/null);
  if [ -z "$version" ]; then
    version=$(git rev-parse --verify --short HEAD);
  fi;

  echo "$version";
}

function _git_delete_tag {
  if [[ 1 -eq $# ]]; then
    git tag -d $1;
    git push --delete origin $1;
  elif [[ 2 -eq $# ]]; then
    git tag -d $2;
    git push --delete $1 $2;
  fi;
}
