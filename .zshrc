# modify the prompt to contain git branch name if applicable
git_prompt_info() {
  current_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  if [[ -n $current_branch ]]; then
    echo " %{$fg_bold[green]%}$current_branch%{$reset_color%}"
  fi
}

cleanup_codespaces() {
	gh cs delete --all --days 4 --force
}

brew-shell() {
	set -eo pipefail

	if [ $# -eq 0 ]; then
	    echo "Must pass at least one argument."
	    exit 1
	fi

	programs=( "$@" )

	function cleanup {
		for program in "${programs[@]}"; do
			brew uninstall "$program"
		done
		brew autoremove
	}

	trap cleanup EXIT

	for program in "${programs[@]}"; do
		brew install "$program"
	done

	$SHELL
}

dev-shell() {
	set -eo pipefail

	if [ $# -eq 0 ]; then
	    echo "Must pass at least one argument."
	    exit 1
	fi

	repo=$1
	clonedpath=$(pwd)/$repo

	function cleanup {
		rm -rIf $clonedpath
		cd ~
	}

	trap cleanup EXIT

	git clone git@github.com:github/$repo.git
	cd $repo
	$SHELL
}

current_kubernetes_cluster() {
    current_cluster=$(cat ~/.kube/config | grep current-context |  cut -d \: -f 2)
    echo "%{$fg_bold[red]%}$current_cluster%{$reset_color%}"
}

current_aws_profile() {
	echo $AWS_PROFILE
}

utc_date_and_time() {
	echo "%D{%m/%f/%y}|%D{%L:%M:%S} ${ret_status}%{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}${NEWLINE}$"
}

production() {
	export AWS_PROFILE=production
	kubectl config use-context production
}

testing() {
	export AWS_PROFILE=testing
	kubectl config use-context testing
}

default() {
	export AWS_PROFILE=default
}

merged() {
	default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
	git checkout $default_branch && git pull
}

setopt promptsubst
export PS1='${"%{$fg_bold[green]%}%n@%m:"}%{$fg_bold[blue]%}%c%{$reset_color%}$(git_prompt_info)% %# '

# completion
autoload -U compinit
compinit

# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc
export CLICOLOR=1

# history settings
setopt hist_ignore_all_dups inc_append_history
HISTFILE=~/.zhistory
HISTSIZE=4096
SAVEHIST=4096

# awesome cd movements from zshkit
setopt autocd autopushd pushdminus pushdsilent pushdtohome cdablevars
DIRSTACKSIZE=5

setopt extendedglob

# Allow [ or ] whereever you want
unsetopt nomatch

# handy keybindings
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^K" kill-line
bindkey "^R" history-incremental-search-backward
bindkey "^P" history-search-backward
bindkey "^N" insert-last-word

if [[ -z "$CODESPACES" ]]; then
	export GOPATH=/Users/raffo/go

	if [[ "Linux" == "$(uname)" ]]; then
		export GOPATH=/home/raffo/go
	fi

	export PATH=~/bin:$GOROOT/bin:$GOPATH/bin:~/bin/google-cloud-sdk/bin/:$HOME/.cargo/bin:/:$PATH
	
fi


if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

ZSH_THEME="agnoster"

HOMEBREW_NO_ANALYTICS=1

# Unix
alias ll="ls -al"
alias ln="ln -v"
alias mkdir="mkdir -p"

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

# Git
alias gs="git status"
alias gd="git diff"
alias gp="git pull"
alias ga="git add"
alias gc="git commit"

# VS code
alias vscode="open -a Visual\ Studio\ Code.app ."

# Kubernetes
alias kap='kubectl get pods --all-namespaces'
alias k='kubectl'
alias watch='watch '
# $source <(kubectl completion zsh)
alias pods='k get pods'
alias spods='k get pods -n kube-system'
alias deployments='k get deployments'
alias sdeployments='k get deployments -n kube-system'
alias ds='k get ds'
alias sds='k get ds -n kube-system'
alias logs='k logs'
alias slogs='k logs -n kube-system'
alias nodes='k get nodes -o wide'
alias kall='k get nodes,svc,endpoints,ingress,pods -n kube-system -o wide'
alias check-dmg-sum='openssl dgst -sha256'
alias prune-branches="git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -D"


# Setup fzf
# ---------
#
if [ -f "$HOME/.vim/bundle/fzf/shell/key-bindings.zsh" ]; then
  source "$HOME/.vim/bundle/fzf/shell/key-bindings.zsh"
elif [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]] && [[ -z "$CODESPACES" ]] ; then
  export PATH="$PATH:/usr/local/opt/fzf/bin"
  source "/usr/local/opt/fzf/shell/key-bindings.zsh"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null


export LC_ALL=en_US.UTF-8

export EDITOR="nvim"

if [[ ! -z "$CODESPACES" ]]; then
        source /home/codespace/.nix-profile/etc/profile.d/nix.sh
fi


if [[ "$OSTYPE" == "linux-gnu" ]]; then
	export LOCALE_ARCHIVE="$(nix-env --installed --no-name --out-path --query glibc-locales)/lib/locale/locale-archive"
	eval "$(ssh-agent)"
fi
if [ -e /home/raffo/.nix-profile/etc/profile.d/nix.sh ]; then . /home/raffo/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
