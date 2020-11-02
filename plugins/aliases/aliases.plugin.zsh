################################################################################
# meta
################################################################################

# edit this file
alias aliases="$EDITOR $(echo $0:A) && source $(echo $0:A)"

################################################################################
# system
################################################################################
alias sudo='sudo ' # allow aliases to be used with sudo
alias :q="exit"

################################################################################
# filesystem
################################################################################
alias l='ls -lFh'     #size,show type,human readable
alias la='ls -lAFh'   #long list,show almost all,show type,human readable
alias lt='ls -ltFh'   #long list,sorted by date,show type,human readable
alias ldot='ls -ld .*'
alias lS='ls -1FSsh'
alias lart='ls -1Fcart'
alias lrt='ls -1Fcrt'
alias ltree='tree -a'

alias grep='grep --color'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS} '

alias t='tail -f'
alias g='$(brew --prefix)/bin/gw' # && compdef g='gradle'

# Command line head / tail shortcuts
alias -g H='--help'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g M="| most"
alias -g LL="2>&1 | less"
alias -g CA="2>&1 | cat -A"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"
alias -g P="2>&1| pygmentize -l pytb"

alias dud='du -d 1 -h'
alias duf='du -sh *'

alias h='history'
alias hgrep="fc -El 0 | grep"
alias help='man'
alias p='ps -f'
alias sortnr='sort -n -r'

# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# zsh is able to auto-do some kungfoo
# depends on the SUFFIX :)
autoload -Uz is-at-least
if is-at-least 4.2.0; then
  # open browser on urls
  if [[ -n "$BROWSER" ]]; then
    _browser_fts=(htm html de org net com at cx nl se dk)
    for ft in $_browser_fts; do alias -s $ft=$BROWSER; done
  fi

  _editor_fts=(cpp cxx cc c hh h inl asc txt TXT tex toml yaml yml)
  for ft in $_editor_fts; do alias -s $ft=$EDITOR; done

  if [[ -n "$XIVIEWER" ]]; then
    _image_fts=(jpg jpeg png gif mng tiff tif xpm)
    for ft in $_image_fts; do alias -s $ft=$XIVIEWER; done
  fi

  _media_fts=(ape avi flv m4a mkv mov mp3 mpeg mpg ogg ogm rm wav webm)
  for ft in $_media_fts; do alias -s $ft=mplayer; done

  # read documents
  alias -s pdf=acroread
  alias -s ps=gv
  alias -s dvi=xdvi
  alias -s chm=xchm
  alias -s djvu=djview
  alias -s json="python -m json.tool"
  alias -s md=bat

  # list whats inside packed file
  alias -s zip="unzip -l"
  alias -s rar="unrar l"
  alias -s tar="tar tf"
  alias -s tar.gz="echo "
  alias -s ace="unace l"
fi

# @doc Bulk search & replace with ag (the_silver_searcher)
function agr {
	ag -0 -l "$1" | AGR_FROM="$1" AGR_TO="$2" xargs -0 perl -pi -e 's/$ENV{AGR_FROM}/$ENV{AGR_TO}/g'
} 

alias agh="ag --hidden"

################################################################################
# zsh
################################################################################


# @description edit zshrc and prompt reload session
function zshrc() {
  # start vim w/ NERDTree opened, but not focused
  vim -f -o "${ZDOTDIR:-$HOME}/.zshrc" "$functions_source[zshrc]" -c "NERDTreeCWD" -c "wincmd l"
  if (( $? != 0 )); then
    return
  fi

  # reload if zsh_reload plugin is installed
  if (( $+commands[src] )); then
    read -n1 "?Reload zsh session? [Yn] "
    if [[ ${REPLY:-y} =~ ^[Yy]$ ]]; then
      echo "${fg[cyan]}Reloading zsh session...${reset_color}"
      src
    fi
  fi
}

# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

################################################################################
# emacs
################################################################################

alias emacs='emacs -nw'

################################################################################
# git
################################################################################

# alias gl='git pull --prune'
alias glr='git pull --rebase'
alias gp='git push -u'
alias glrp='glr && gp'
alias gd='git diff --color'
alias gdc='gd --cached'
alias gs='git status -sb'
alias gw="git show"
alias gsp="git stash pop"
alias gsw="git stash show -p"
alias gcob="git checkout -b"

# @description checkout branch if given, otherwise choose interactively from recent branches
# @arg $1 string branch
# @arg $@ any git-checkout args
function gco() {
  if [ $# -eq 0 ]; then
    local branches branch
    branches="$(git branch --sort=-committerdate)" &&
      branch="$(echo "$branches" | fzf-tmux -d 15 +m)"
    if [ $? -eq 0 ]; then
      git checkout "$(echo "$branch" | sed "s/.* //")"
    fi
  else
    git checkout -B "$@"
  fi
}

################################################################################
# tmux
################################################################################

# direnv & tmux: wrap tmux to avoid issues with environment loading
# (source: https://git.io/Jfmfu)
if (( $+commands[direnv] )); then
  alias tmux='direnv exec / tmux'
fi

# @description attaches or creates tmux session; detaches other clients.
function tma() {
  tmux new-session -ADs "${1:-main}"
}

################################################################################
# anaconda
################################################################################

# @decription setup current shell to use anaconda
conda-shell() {
  __pyenv_version=$(pyenv whence conda)
  __conda_home="$HOME/.pyenv/versions/$__pyenv_version"
  __conda_setup="$("$__conda_home/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"

  pyenv shell "$__pyenv_version"

  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "$__conda_home/etc/profile.d/conda.sh" ]; then
          source "$__conda_home/etc/profile.d/conda.sh"
      else
          export PATH="$__conda_home/bin:$PATH"
      fi
  fi
  unset __conda_setup
  unset __conda_home
  unset __pyenv_version
}

################################################################################
# aws-okta
################################################################################

function aws-env() {
  emulate -L zsh
  set +e
  local profile="$1"
  if [[ -z "$profile" ]]; then
    profile="$(aws-okta list | fzf --tac | cut -f1)"
  fi
  eval "$(aws-okta env "$profile")"
}

function aws-login() {
  emulate -L zsh
  set +e
  local profile="$1"
  if [[ -z "$profile" ]]; then
    profile="$(aws-okta list | fzf --tac | cut -f1)"
  fi
  eval "$(aws-okta login "$profile")"
}

################################################################################
# bazel
################################################################################

alias bzb="bazel build"
alias bzt="bazel test"
alias bzr="bazel run"
alias bzq="bazel query"
alias bzba="bazel build //..."
alias bzta="bazel test //..."
alias bfmt="buildifier -lint=warn -r ."

################################################################################
# docker
################################################################################

alias d-c="docker-compose"

################################################################################
# applications
################################################################################
if (( ! $+commands[typora] )); then
  alias typora="open -a typora"
fi
