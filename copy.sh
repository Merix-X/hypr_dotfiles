mkdir -p ~/.config

cp -rf hypr ~/.config/
cp -rf waybar ~/.config/
cp -rf dunst ~/.config/
cp -rf kitty ~/.config/
cp -rf gtk ~/.config/
cp -rf rofi ~/.config/
cp -rf starship ~/.config/

cp -f zshrc ~/.zshrc

sudo mkdir -p /usr/share/sddm/themes/sugar-candy/
sudo cp -f sddm/sugar-candy-theme.conf /usr/share/sddm/themes/sugar-candy/theme.conf
