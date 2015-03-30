#!/bin/sh

cd $BUILT_PRODUCTS_DIR

for arch in $ARCHS; do
  out=${WRAPPER_NAME}/arch_${arch}.a
  libtool -static -syslibroot $SDKROOT -L. -filelist $(eval echo \$LINK_FILE_LIST_${CURRENT_VARIANT}_${arch}) -o $out
done

lipo -create ${WRAPPER_NAME}/arch_*.a -output ${EXECUTABLE_PATH}
rm ${WRAPPER_NAME}/arch_*.a
