d:
cd d:\vob
cd d:\w090\archive\caiji
mkdir %date:~0,10%
cd %date:~0,10%
xcopy /s /y d:\vob\caiji
cd d:\vob
rm -rf caiji
git clone http://grasp:improvew090#@github.com/grasp/caiji.git
pause

