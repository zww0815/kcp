@echo off
set cur_dir="%cd%"
set build_dir="%cd%\cmake_build\KCP_VS2017"

if not exist %build_dir% (
	echo "Create %build_dir%"
	md %build_dir%
)

echo %build_dir%
echo %cur_dir%

pushd %build_dir%
    cmake %cur_dir%/ -T v141_xp -DENABLE_BUILD_KCP_MT=ON -DENABLE_TESTS=ON
popd

pause