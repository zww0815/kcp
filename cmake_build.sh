#!/bin/bash

cur_dir=$(pwd)
build_dir="${cur_dir}/cmake_build/KCP"

[ ! -d ${build_dir} ]                  \
&& echo "Create ${build_dir}"          \
&& mkdir -p ${build_dir}               \
&& echo "Create ${build_dir} success." \
	
echo "cur_dir  : ${cur_dir}"
echo "build_dir: ${build_dir}"

pushd ${build_dir}
	[ -n ${build_dir} ] && rm -r  ${build_dir}/*
    cmake ${cur_dir} -DENABLE_TESTS=ON -DCMAKE_BUILD_TYPE=Release
	make
	make install
popd

