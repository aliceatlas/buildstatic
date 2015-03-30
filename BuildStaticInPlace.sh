#!/bin/sh

cd "$BUILT_PRODUCTS_DIR"

for arch in $ARCHS; do
  out="${WRAPPER_NAME}"/arch_${arch}.a
  lfl=LINK_FILE_LIST_${CURRENT_VARIANT}_${arch}
  libtool -static -syslibroot $SDKROOT -L. -filelist "${!lfl}" -o "$out"
done

lipo -create "${WRAPPER_NAME}"/arch_*.a -output "${EXECUTABLE_PATH}"
rm "${WRAPPER_NAME}"/arch_*.a
