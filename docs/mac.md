# Must Install

* [Brew](https://brew.sh/)
```shell script
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
``` 

In case your shell can not find the brew, especially on M1 macs try this:
```shell
# put the following to ~/.zhrc
eval $(/opt/homebrew/bin/brew shellenv)
```
You need to start a new shell to see that now `brew` is available:
```shell
which brew
/opt/homebrew/bin/brew
```

To remove it later
```shell script
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
```


* [bash](https://www.gnu.org/software/bash/)
```shell script
brew install bash
sudo -s
echo /usr/local/bin/bash >> /etc/shells
exit
chsh -s /usr/local/bin/bash
```
# Free Stuff

* [Chrome](https://www.google.com/chrome/)

* [Emacs](https://formulae.brew.sh/formula/emacs)
```shell script
brew install emacs
```

* [Python](https://www.python.org/)
```shell script
brew install python
# --user is important, otherwise it installs as system wide
pip3 install moduleName --user
```

* [Java](https://www.oracle.com/technetwork/java/javase/downloads/index.html)

* [Intellij Idea IDE](https://www.jetbrains.com/idea/download/#section=mac)

* [Consolas Font](https://freefontsdownload.net/free-consolas-font-33098.htm)

* [Fira Code Font](https://github.com/tonsky/FiraCode/tree/master/distr/ttf)
  * Download all ttf files
  * Select all, open in font book and click on install 

* [iTerm2](https://iterm2.com/downloads.html)
  * `Preferences > Profile > Text` : Choose the best font
  * `Preferences > Profile > Colors > Smart box cursor` : Check

* [Visual Studio Code](https://code.visualstudio.com/Download) 
You might need to play with `System Preferences > Security and Privacy` settings
to make it work 
  * `Preferences > Settings > telemetry`: Uncheck all

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

* [Emacs php-mode](https://github.com/emacs-php/php-mode)
```shell script
git clone https://github.com/emacs-php/php-mode.git
cd php-mode
cp *.el ~/.env/ext/emacs/modules
cd ..
\rm -fr php-mode
```

* [Emacs markdown-mode](https://jblevins.org/projects/markdown-mode/rev-2-3)
```shell script
download https://jblevins.org/projects/markdown-mode/markdown-mode.el
mv markdown-mode.el ~/.env/ext/emacs/modules
```

* [Apache](https://httpd.apache.org/) Already installed on mac
```shell script
# starts apache server
sudo apachectl start
cd /etc/apache2/
# restart after editing httpd.conf file with sudo
# apachectl restart
# stops apache server
sudo apachectl stop
```

# Paid Stuff
* [Office](https://www.office.com/)

* [1Password](https://1password.com/)

* [Adobe Creative Cloud Photography](https://www.adobe.com/creativecloud.html)

## Customizations
* [How to setup an Apple Mac for Software Development](configuring-a-user-accounthttps://www.stuartellis.name/articles/mac-setup/)
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
* `System Preferences > Trackpad > Tap to Click`: Check
* `System Preferences > Accessibility > Pointer Control > Trackpad Options > Enable Dragging`: Check
