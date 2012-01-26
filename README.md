Snippet
=======

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

