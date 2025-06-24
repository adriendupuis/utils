#!/usr/bin/env bash

source text.sh;

echo -e "${TXT_BLINK}${TXT_UNDERLINE}${TXT_FG_GREEN}gr${TXT_REVERSE}e${TXT_REVERSE_RESET}en${TXT_RESET}!";

ERROR="${TXT_FG_WHITE}${TXT_BG_RED}";
WARNING="${TXT_FG_BLACK}${TXT_BG_YELLOW}";
COMMENT="${TXT_FG_BLUE}";
RESET=$TXT_RESET;

echo -e "${ERROR}Error${RESET}"
echo -e "${WARNING}Warning${RESET}"
echo -e "${COMMENT}Comment${RESET}"
