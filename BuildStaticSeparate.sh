#!/bin/sh

cd "$BUILT_PRODUCTS_DIR"
mkdir -p Static

static_wrapper_name=Static/"${WRAPPER_NAME}"
rm -rf "${static_wrapper_name}"
cp -a "${WRAPPER_NAME}" "${static_wrapper_name}"
rm Static/"${EXECUTABLE_PATH}"

for arch in $ARCHS; do
  out="${static_wrapper_name}"/arch_${arch}.a
  lfl=LINK_FILE_LIST_${CURRENT_VARIANT}_${arch}
  libtool -static -syslibroot $SDKROOT -L. -filelist "${!lfl}" -o "$out"
done

lipo -create "${static_wrapper_name}"/arch_*.a -output Static/"${EXECUTABLE_PATH}"
rm "${static_wrapper_name}"/arch_*.a
