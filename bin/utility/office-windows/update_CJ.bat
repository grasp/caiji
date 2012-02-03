d:
cd d:\vob
cd d:\w090\archive\caiji
mkdir %date:~0,10%
cd %date:~0,10%
if exist d:\vob\caiji xcopy /s /y d:\vob\caiji

cd d:\vob
if exist d:\vob\caiji  rm -rf caiji

set http_proxy=wwwgate0-ch.mot.com:1080
git clone http://grasp@github.com/grasp/caiji.git
pause

