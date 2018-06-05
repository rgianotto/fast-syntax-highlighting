# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# Copyright (c) 2018 Sebastian Gniazdowski
#
# Chroma function for command `git'. It colorizes the part of command
# line that holds `git' invocation.
#

(( next_word = 2 | 8192 ))

local __first_call="$1" __wrd="$2" __start_pos="$3" __end_pos="$4"
local __style
integer __idx
local -a __lines_list

(( __first_call )) && {
    FAST_HIGHLIGHT[chroma-git-counter]=1
    FAST_HIGHLIGHT[chroma-git-got-subcommand]=0
    FAST_HIGHLIGHT[chroma-git-subcommand]=""
    __style=${FAST_THEME_NAME}command
    (( __start=__start_pos-${#PREBUFFER}, __end=__end_pos-${#PREBUFFER}, __start >= 0 )) && reply+=("$__start $__end ${FAST_HIGHLIGHT_STYLES[$__style]}")
} || {
    if [[ "$__wrd" = --* ]]; then
        __style=${FAST_THEME_NAME}double-hyphen-option
        (( __start=__start_pos-${#PREBUFFER}, __end=__end_pos-${#PREBUFFER}, __start >= 0 )) && reply+=("$__start $__end ${FAST_HIGHLIGHT_STYLES[$__style]}")
    elif [[ "$__wrd" = -* ]]; then
        __style=${FAST_THEME_NAME}single-hyphen-option
        (( __start=__start_pos-${#PREBUFFER}, __end=__end_pos-${#PREBUFFER}, __start >= 0 )) && reply+=("$__start $__end ${FAST_HIGHLIGHT_STYLES[$__style]}")
    else
        # Increase position counter, save it in handy parameter __idx
        (( FAST_HIGHLIGHT[chroma-git-counter] += 1, __idx = FAST_HIGHLIGHT[chroma-git-counter] ))

        if (( FAST_HIGHLIGHT[chroma-git-got-subcommand] == 0 )); then
            FAST_HIGHLIGHT[chroma-git-got-subcommand]=1
            FAST_HIGHLIGHT[chroma-git-subcommand]="$__wrd"
            __style=${FAST_THEME_NAME}reserved-word
            (( __start=__start_pos-${#PREBUFFER}, __end=__end_pos-${#PREBUFFER}, __start >= 0 )) && reply+=("$__start $__end ${FAST_HIGHLIGHT_STYLES[$__style]}")
        else
            __wrd="${${(Q)__wrd}#[\"\']}"
            if [[ "${FAST_HIGHLIGHT[chroma-git-subcommand]}" = "push" ]]; then
                if (( __idx == 3 )); then
                    -fast-run-git-command "git remote" "chroma-git-remotes" ""
                    [[ -z ${__lines_list[(r)$__wrd]} ]] && __style=${FAST_THEME_NAME}unknown-token || __style=${FAST_THEME_NAME}reserved-word
                    (( __start=__start_pos-${#PREBUFFER}, __end=__end_pos-${#PREBUFFER}, __start >= 0 )) && reply+=("$__start $__end ${FAST_HIGHLIGHT_STYLES[$__style]}")
                elif (( __idx == 4 )); then
                    -fast-run-git-command "git for-each-ref --format='%(refname:short)' refs/heads" \
                            "chroma-git-branches" \
                            "refs/heads"
                    [[ -z ${__lines_list[(r)$__wrd]} ]] && __style=${FAST_THEME_NAME}unknown-token || __style=${FAST_THEME_NAME}reserved-word
                    (( __start=__start_pos-${#PREBUFFER}, __end=__end_pos-${#PREBUFFER}, __start >= 0 )) && reply+=("$__start $__end ${FAST_HIGHLIGHT_STYLES[$__style]}")
                fi
            fi
        fi
    fi
}

# We aren't passing-through, do obligatory things ourselves
(( this_word = next_word ))
_start_pos=$_end_pos

return 0

# vim:ft=zsh:et:sw=4