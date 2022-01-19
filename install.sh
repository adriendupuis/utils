# First installation script (just after having cloned the repository)

if [[ `basename $1` = 'zsh' ]]; then
  rc='zshrc';
elif [[ `basename $1` = 'bash' ]]; then
  rc='bashrc';
else
  echo "Error: Unsupported shell.";
  exit 1;
fi;

source ~/utils/text.sh;
ERROR="${TXT_FG_WHITE}${TXT_BG_RED}";
WARNING="${TXT_FG_BLACK}${TXT_BG_YELLOW}";
COMMENT="${TXT_FG_BLUE}";
RESET=$TXT_RESET;

if [[ -f ~/utils/rc/$rc ]]; then
  if [[ -z `grep "/utils/rc/$rc" ~/.$rc;` ]]; then
    echo "Status: Load ~/utils/rc/${rc} into ~/.${rc}…";

    echo '' >> ~/.$rc;
    echo '# https://github.com/adriendupuis/utils' >> ~/.$rc;
    echo "source \$HOME/utils/rc/$rc" >> ~/.$rc;

    echo "${COMMENT}Notice: Utils will be automatically available in next terminals. If Utils is needed in the current one, the following command can be run:";
    echo "source ~/.$rc;${RESET}";
  else
    echo "Info: ~/utils/rc/$rc already loaded from ~/.$rc.";
  fi;
else
  echo "Info: No “rc” file available for this shell."
fi;
