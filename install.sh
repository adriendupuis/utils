# First installation script (just after having cloned the repository)

if [[ "$1" =~ 'zsh' ]]; then
  rc='zshrc';
elif [[ "$1" =~ 'bash' ]]; then
  rc='bashrc';
else
  echo 'Error: Unsupported shell';
  exit 1;
fi;

if [[ -f ~/utils/rc/$rc ]]; then
  if [[ -z `grep "/utils/rc/$rc" ~/.$rc;` ]]; then
    echo "Info: Load ~/utils/rc/$rc into ~/.$rc…";
    echo '' >> ~/.$rc;
    echo '# https://github.com/adriendupuis/utils' >> ~/.$rc;
    echo "source \$HOME/utils/rc/$rc" >> ~/.$rc;
  else
    echo "Info: ~/utils/$rc already loaded from ~/.$rc.";
  fi;
else
  echo "Info: No “rc” file for this shell."
fi;
