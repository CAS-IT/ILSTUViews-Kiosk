echo Running CDW Build script...

set WORKSPACE=%HOMEPATH%\desktop2\CDWBuild\lp-cdw\air_projects

"C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.6\FlashBuilderC.exe" ^
	--launcher.suppressErrors ^
	-noSplash ^
	-application org.eclipse.ant.core.antRunner ^
	-data "%WORKSPACE%"
	-file "%WORKSPACE%\cdw_kiosk\build.xml"