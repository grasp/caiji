d:
cd d:\vob
cd d:\w090\archive\g00
mkdir %date:~0,10%
cd %date:~0,10%
if exist d:\vob\g00  xcopy /s /y d:\vob\g00
cd d:\vob
if exist d:\vob\g00 rm -rf g00
set http_proxy=wwwgate0-ch.mot.com:1080
git clone http://grasp:@github.com/grasp/g00.git
pause

