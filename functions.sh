function _utils_update {
  cd ~/utils;

  previous=$(_utils_version);

  git fetch;
  if [[ 0 -lt $# ]]; then
    git checkout "$1";
  else
    git checkout master;
  fi;
  git pull;

  current=$(_utils_version);

  if [ "$current" == "$previous" ]; then
    echo "Utils is up-to-date and actualy in $previous";
  else
    source ~/utils/aliases.sh;
    echo "Utils updated from $previous to $current.";
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