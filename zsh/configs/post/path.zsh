# prefer gnu tools
if (( $+commands[brew] )); then
  path=($(brew --prefix)/opt/{{coreutils,gawk,gnu-indent,gnu-sed,gnu-tar,grep,make}/libexec/gnubin,curl/bin} $path)
fi

path=(~/{bin,.bin,.local/bin,go/bin} /usr/local/{sbin,bin} $path)