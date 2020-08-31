#!/bin/bash

# devel branch
my-prompt-command() { unset 'PROMPT_COMMAND[0]'; }
PROMPT_COMMAND=(my-prompt-command)

# bash-5.1-alpha
my-prompt-command2() { unset 'PROMPT_COMMANDS[0]'; }
PROMPT_COMMANDS=(my-prompt-command2)
