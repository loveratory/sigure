sigure
==========
cyanogenmod build shell helper.

Setup
----------
1. `git clone https://github.com/BindEmotions/sigure ~/sigure/`
2. `mkdir -p ~/bin`
3. `ln -s ~/sigure/sigure.sh ~/bin/sigure`
4. add below to .bashrc
```
if [ -d $HOME/bin ]; then
        export PATH=$HOME/bin:$PATH
fi
```

Usage
----------
ex. `sigure -d thor -s cm13`

Help
----------
`sigure -h`

LICENSE
----------
Public Domain - CC0. See [LICENSE](LICENSE).
