using BinaryBuilder

name = "FEAST"
version = v"4.0.0"
sources = [
    GitSource("https://github.com/spacedome/feast_julia", "11ae84f7df5cc120d4a34918dd1066a67f205e8f")
]

script = raw"""
cd ${WORKSPACE}/srcdir/feast_j/src
OPENBLAS=(-lopenblas)
FFLAGS=()
CFLAGS=()
if [[ ${nbits} == 64 ]] && [[ ${target} != aarch64* ]]; then
  OPENBLAS=(-lopenblas64_)
  if [[ "${target}" == powerpc64le-linux-gnu ]]; then
    OPENBLAS+=(-lgomp)
  fi
  syms=(DGEMM IDAMAX ISAMAX SNRM2 XERBLA ccopy cgemm cgemv cgeru cher clarfg cscal cswap ctrsm ctrsv cungqr cunmqr dcopy dgemm dgemv dger dlamch dlarfg dorgqr dormqr dnrm2 dscal dswap dtrsm dtrsv dznrm2 idamax isamax ilaenv scnrm2 scopy sgemm sgemv sger slamch slarfg sorgqr sormqr snrm2 sscal sswap strsm strsv xerbla zcopy zgemm zgemv zgeru zlarfg zscal zswap ztrsm ztrsv zungqr zunmqr)
  for sym in "${syms[@]}"; do
    FFLAGS+=("-D${sym}=${sym}_64")
    CFLAGS+=("-D${sym}=${sym}_64")
  done
fi
FLAG="${FFLAGS[*]}"
make feast BLAS=$OPENBLAS F90=$FC MAKE_FLAGS="${FLAG}"
mv libfeast.so ${WORKSPACE}/destdir/lib/
"""

# Not sure why compile fails on windowsand powerpc
platforms = expand_gfortran_versions(filter!(p -> !isa(p, Windows) && !isa(p, MacOS) && arch(p) != :powerpc64le, supported_platforms()))
products = [
    LibraryProduct("libfeast", :libfeast),
]

dependencies = [
    Dependency("OpenBLAS_jll"),
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)