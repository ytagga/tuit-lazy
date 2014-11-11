#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([tuit-lazy], [0.01], [tagga@tsuada.ac.jp])
AM_INIT_AUTOMAKE([foreign])

# Checks for programs.
AC_CHECK_PROGS([LUA], [lua wlua lua5.2 lua5.1])
AC_CHECK_PROGS([PROVE], [prove])

LUA_VERSION=`$ac_cv_prog_LUA -e "print(string.match(_VERSION, '([[.%d]]+)'))"`
AC_SUBST([LUA_VERSION])

LUA_MODNAME=`echo $PACKAGE | tr - .`
AC_SUBST(LUA_MODNAME)

LUA_MODPATH=`echo $PACKAGE | tr - /`
AC_SUBST(LUA_MODPATH)

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile tuit/Makefile tuit/array/Makefile])
AC_OUTPUT
