# Free Stuff

* [Brew](https://brew.sh/)
```shell script
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
``` 

* [bash](https://www.gnu.org/software/bash/)
```shell script
brew install bash
sudo -s
echo /usr/local/bin/bash >> /etc/shells
exit
chsh -s /usr/local/bin/bash
```

* [Chrome](https://www.google.com/chrome/)

* [Emacs](https://formulae.brew.sh/formula/emacs)
```shell script
brew install emacs
```

* [Java](https://www.oracle.com/technetwork/java/javase/downloads/index.html)

* [Intellij Idea IDE](https://www.jetbrains.com/idea/download/#section=mac)

* [Consolas Font](https://freefontsdownload.net/free-consolas-font-33098.htm)

* [Fira Code Font](https://github.com/tonsky/FiraCode/tree/master/distr/ttf)
  * Download all ttf files
  * Select all, open in font book and click on install 

* [iTerm2](https://iterm2.com/downloads.html)
  * `Preferences > Profile > Text` : Choose the best font

* [Visual Studio Code](https://code.visualstudio.com/Download) 
You might need to play with `System Preferences > Security and Privacy` settings
to make it work 

* [Maven Apache](https://maven.apache.org/)
```shell script
brew install maven
```

* [Git](https://git-scm.com/)
```shell script
xcode-select --install
```

* [MySQL](https://www.mysql.com/)
```shell script
brew install mysql
mysql.server start
mysql_secure_installation
mysql -u root -p
mysql.server stop
```

* [tmux](https://github.com/tmux/tmux)
```shell script
brew install tmux
```

* [php-mode](https://github.com/emacs-php/php-mode)
```shell script
git clone https://github.com/emacs-php/php-mode.git
cd php-mode
cp *.el ~/.env/ext/emacs/modules
cd ..
\rm -fr php-mode
```

# Paid Stuff
* [Office](https://www.office.com/)

* [1Password](https://1password.com/)

* [Adobe Creative Cloud Photography](https://www.adobe.com/creativecloud.html)

# Customizations
* Change fonts to Consolas or Fire Coda and set a comfortable font size for eachd developer application
* `System Preferences > Mission Control > Hot Corners`: 
  * Up Left: Start Screen Saver
  * Up Right: Mission Control
  * Down Left: Desktop
  * Down Right: Launchpad

* `System Preferences > Dock > Position on screen`: Right
* `System Preferences > Dock > Automatically hide and show the Dock`: Check
* `System Preferences > Security & Privacy > Require Password`: 5 seconds
* `System Preferences > Security & Privacy > Firewall`: Turn on the firewall
* `Finder Preferences > Advanced > When performaing a search > Search the Current Folder`

* [Apache](https://httpd.apache.org/)
```shell script
# starts apache server
apachectl start
cd /etc/apache2/
# restart after editing httpd.conf file
# apachectl restart
# stops apache server
apachectl stop
```




