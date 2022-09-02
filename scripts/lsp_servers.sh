echo "Installing intelephense (PHP) LSP Server"

npm i intelephense -g


echo "Installing phpactor LSP Server"

if [[ ! -d "$HOME/Code" ]] 
then
  mkdir -p $HOME/Code
fi

cd $HOME/Code
git clone git@github.com:phpactor/phpactor
cd phpactor
$(which php) composer install
echo "\n Create symlink for phpactor"
sudo ln -s $HOME/Code/phpactor/bin/phpactor /usr/local/bin/phpactor


echo "Installing lua-language-server"

cd $HOME/Code
git clone  --depth=1 https://github.com/sumneko/lua-language-server
cd lua-language-server
git submodule update --depth 1 --init --recursive
cd 3rd/luamake
./compile/install.sh
cd ../..
./3rd/luamake/luamake rebuild
