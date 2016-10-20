#!/bin/sh

cd "$BUILT_PRODUCTS_DIR"

archs=( $ARCHS ) lfls=()
for v in "${archs[@]/#/LINK_FILE_LIST_${CURRENT_VARIANT}_}"; do
  lfls+=( -filelist "${!v}" )
done

libtool -static -syslibroot "$SDKROOT" -L. "${lfls[@]}" -o "$EXECUTABLE_PATH"
