#!/bin/bash

#
# Copyright (C) 2022 GeoPD <geoemmanuelpd2001@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Sorting final zip
compiled_zip() {
	ZIP=$(find $(pwd)/rom/out/target/product/${T_DEVICE}/ -maxdepth 1 -name "*${T_DEVICE}*.zip" | perl -e 'print sort { length($b) <=> length($a) } <>' | head -n 1)
	ZIPNAME=$(basename ${ZIP})
}

# Final ccache upload
ccache_upload_final () {
	time tar "-I zstd -1 -T16" -cf $1.tar.zst $1
	rclone copy --drive-chunk-size 256M --stats 1s $1.tar.zst brrbrr:$1/$NAME -P
}

# CI run time
ci_time() {
	CIDIFF=$(cat ${CIRRUS_WORKING_DIR}/ci_time)
	export CI_MINUTES=$((115-$((CIDIFF / 60))))
}

# Let session sleep on error for debug
sleep_on_error() {
	if [ -f $(pwd)/rom/out/target/product/${T_DEVICE}/${ZIPNAME} ]; then
		ccache_upload_final ccache
		sleep ${CI_MINUTES}m
	else
		ccache_upload_final ccache
		sleep 2h
	fi
}

cd /tmp
compiled_zip
ci_time
sleep_on_error
