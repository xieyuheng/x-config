set -x N_PREFIX $HOME/.n
set PATH $PATH $N_PREFIX/bin

set -gx PNPM_HOME '/home/xyh/.local/share/pnpm'
if test "$PATH[1]" != "$PNPM_HOME/bin"
  set -gx PATH "$PNPM_HOME/bin" $PATH
end

set PATH $PATH $HOME/.bun/bin
