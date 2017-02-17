@echo off
set QT_VERSION_MAJOR=5
SET QT_VERSION_MINOR=%QT_VERSION_MAJOR%.6
SET QT_VERSION_PATCH=%QT_VERSION_MINOR%.2
SET QT_VERSION_STR=5_6_2

::call:logInfo "Unpacking qt %QT_VERSION_STR%"
::7z x -o.\qt%QT_VERSION_STR% .\qt%QT_VERSION_STR%\qtbase.7z

::call:logInfo "Removing extracted qt archive"
::del .\qt%QT_VERSION_STR%\qtbase.7z

call:getQtSource

GOTO:EOF

:: FUNCTIONS
:logInfo
    echo [INFO] %~1
GOTO:EOF

:getQtSource
	rmdir qt%QT_VERSION_STR% /s /q
    call:logInfo "Downloading qt source"

	git clone git://code.qt.io/qt/qt%QT_VERSION_MAJOR%.git qt%QT_VERSION_STR%
	cd qt%QT_VERSION_STR%	
    git checkout %QT_VERSION_MINOR%
    perl init-repository --module-subset=qtbase,qtimageformats
    git checkout v%QT_VERSION_PATCH%
    cd qtbase && git checkout v%QT_VERSION_PATCH% && cd ..
    cd qtimageformats && git checkout v%QT_VERSION_PATCH% && cd ..

	call:logInfo "Applying the patch and configure"
	cd qtbase && git apply ../../../tdesktop/Telegram/Patches/qtbase_%QT_VERSION_STR%.diff && cd ..
	call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86
	call configure -debug-and-release -force-debug-info -opensource -confirm-license -static -I "C:\TBuild\Libraries\openssl\Release\include" -L "C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Lib" -l Gdi32 -no-opengl -openssl-linked OPENSSL_LIBS_DEBUG="C:\TBuild\Libraries\openssl_debug\Debug\lib\ssleay32.lib C:\TBuild\Libraries\openssl_debug\Debug\lib\libeay32.lib" OPENSSL_LIBS_RELEASE="C:\TBuild\Libraries\openssl\Release\lib\ssleay32.lib C:\TBuild\Libraries\openssl\Release\lib\libeay32.lib" -mp -nomake examples -nomake tests -platform win32-msvc2015
	nmake
	nmake install
	
	::call:logInfo "Copying header files to our compiled qt"
	::xcopy *.h ..\qt%QT_VERSION_STR%\ /sy

	cd ..
	::rmdir tmp /s /q
GOTO:EOF
