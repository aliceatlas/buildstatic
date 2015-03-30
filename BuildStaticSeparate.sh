#!/bin/sh

cd $BUILT_PRODUCTS_DIR
mkdir -p Static

static_wrapper_name=Static/${WRAPPER_NAME}
rm -rf ${static_wrapper_name}
cp -a ${WRAPPER_NAME} ${static_wrapper_name}
rm Static/${EXECUTABLE_PATH}

for arch in $ARCHS; do
  out=${static_wrapper_name}/arch_${arch}.a
  libtool -static -syslibroot $SDKROOT -L. -filelist $(eval echo \$LINK_FILE_LIST_${CURRENT_VARIANT}_${arch}) -o $out
done

lipo -create ${static_wrapper_name}/arch_*.a -output Static/${EXECUTABLE_PATH}
rm ${static_wrapper_name}/arch_*.a
