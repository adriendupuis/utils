function _utils_update {
  cd ~/utils;
  git fetch;
  if [[ 0 -lt $# ]]; then
    git checkout "$1";
  fi;
  git pull;
}