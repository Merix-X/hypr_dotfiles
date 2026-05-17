# Ujistíme se, že složka .config existuje
mkdir -p ~/.config

# Vytvoříme odkazy na stažené dotfiles
ln -s ~/dotfiles/hypr ~/.config/hypr
ln -s ~/dotfiles/waybar ~/.config/waybar
ln -s ~/dotfiles/dunst ~/.config/dunst
ln -s ~/dotfiles/.zshrc ~/.zshrc
