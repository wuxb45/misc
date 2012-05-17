Snippet
=======
Copyright 2011,2012 Wu Xingbo <wuxb45@gmail.com>

Some useful scripts & tools.


xit
--------
"Cross it!"

It's a bash script for build cross-compiler tool-chain automatically.
buildroot is too big, and however I need a script. so here comes the
single-file script for a crosstool.
It has been tested with mmix:

    $ ./xit mmix /home/wuxb/program/mmix-crosstools

I recommand use '$HOME/program', because you don't have to be root.
'/usr/local' sucks.


pullall
--------
"pullall repositories"

I clone a lot of git/hg/svn repositories just for read.
I'm tired of typing *git pull* or *svn update* or *hg pull* on them.

*pullall* will execute *git pull* on every "\*-git" dirs;
execute *hg pull* on every "\*-hg" dirs;
execute *svn update* on every "\*-svn" dirs.
give your repositories a proper name, *pullall* will do the job.

I also add pullall to crond:

    0 9,17 * * * cd $HOME/repo && ./pullall >> pullall.history

hfs
--------
"haskell file server"

I use some different documents: ghc+cabal, python, etc..
Serve them through a http server is very interesting.
I write my own server using happstack(Haskell), It's great!

**Build from nothing:
**ArchLinux (others are similar)
    $ pacman -S ghc cabal-install
    $ cabal update
    $ cabal install happstack
    $ ghc --make -threaded hfs.hs
    # optional:
    $ strip -p --strip-unneeded --remove-section=.comment -o hfs.bin hfs
**Windows
    "install haskell-platform from http://hackage.haskell.org/platform/"
    > cabal update
    > cabal install happstack
    > ghc --make -threaded hfs.hs

Droid0 Sans Mono
--------
"Droid-Zero Sans Mono"

Droid Sans Mono font is great, but 0 (Zero) and O (a Capital Charactor)
is hard to identify. I Just add a dot inside 0 (the Zero). make it clear.

**install:
    Copy it to "/usr/share/fonts/TTF/"
    $ fc-cache -fv
    then you can use it as "Droid0 Sans Mono"

Wu Xingbo <wuxb45@gmail.com>
