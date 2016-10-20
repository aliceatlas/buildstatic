#!/bin/sh

cd "$BUILT_PRODUCTS_DIR"

static_wrapper_name="Static/$WRAPPER_NAME"
rm -rf "$static_wrapper_name"
ditto "$WRAPPER_NAME" "$static_wrapper_name"

archs=( $ARCHS ) lfls=()
for v in "${archs[@]/#/LINK_FILE_LIST_${CURRENT_VARIANT}_}"; do
  lfls+=( -filelist "${!v}" )
done

libtool -static -syslibroot "$SDKROOT" -L. "${lfls[@]}" -o "Static/$EXECUTABLE_PATH"
