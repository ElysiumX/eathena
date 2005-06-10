CC = g++ -pipe
#CC = gcc -pipe -DGCOLLECT
#CC = gcc -pipe -DDMALLOC -DDMALLOC_FUNC_CHECK
#CC = /usr/local/bin/gcc -fbounds-checking -pipe -DBCHECK

# GCLIB = -lgc
# GCLIB = -ldmalloc

PACKETDEF = -DPACKETVER=6 -DNEW_006b
#PACKETDEF = -DPACKETVER=5 -DNEW_006b
#PACKETDEF = -DPACKETVER=4 -DNEW_006b
#PACKETDEF = -DPACKETVER=3 -DNEW_006b
#PACKETDEF = -DPACKETVER=2 -DNEW_006b
#PACKETDEF = -DPACKETVER=1 -DNEW_006b

OPT = -g -O6 -ffast-math

PLATFORM = $(shell uname)

ifeq ($(findstring Linux,$(PLATFORM)), Linux)
   LIBS += -ldl
endif

ifeq ($(findstring SunOS,$(PLATFORM)), SunOS)
   LIBS += -lsocket -lnsl -ldl
endif

ifeq ($(findstring FreeBSD,$(PLATFORM)), FreeBSD)
   MAKE = gmake
endif

ifeq ($(findstring NetBSD,$(PLATFORM)), NetBSD)
   MAKE = gmake
   OS_TYPE = -D__NETBSD__
endif

ifeq ($(findstring CYGWIN,$(PLATFORM)), CYGWIN)
   OS_TYPE = -DCYGWIN
endif

CFLAGS = $(OPT) -I../common $(OS_TYPE)

# my defaults for mysql libs
MYSQL_INCLUDE = -I../../../mysql/include/ 
MYSQL_LIB     = -L../../../mysql/lib -lmysqlclient -lposix4 -lcrypt -lgen -lnsl -lm

ifdef SQLFLAG
MYSQLFLAG_CONFIG = $(shell which mysql_config)

# 'which' does not work system independend 
# test for gnu-which or use different findstring params

ifeq ($(findstring /mysql_config,$(MYSQLFLAG_CONFIG)), /mysql_config)

MYSQLFLAG_VERSION = $(shell $(MYSQLFLAG_CONFIG) --version | sed s:\\..*::) 

ifeq ($(findstring 4,$(MYSQLFLAG_VERSION)), 4)
MYSQLFLAG_CONFIG_ARGUMENT = --cflags
endif

ifeq ($(findstring 5,$(MYSQLFLAG_VERSION)), 5)
MYSQLFLAG_CONFIG_ARGUMENT = --include
endif

ifndef MYSQLFLAG_CONFIG_ARGUMENT
MYSQLFLAG_CONFIG_ARGUMENT = --cflags
endif

MYSQL_INCLUDE = $(shell $(MYSQLFLAG_CONFIG) $(MYSQLFLAG_CONFIG_ARGUMENT)) 
MYSQL_LIB     = $(shell $(MYSQLFLAG_CONFIG) --libs)
endif

MYLIB = CC="$(CC)" CFLAGS="$(CFLAGS) $(MYSQL_INCLUDE)" LIB_S="$(MYSQL_LIB) $(LIBS) $(GCLIB)"

endif

MKDEF = CC="$(CC)" CFLAGS="$(CFLAGS)" LIB_S="$(LIBS) $(GCLIB)"

all: conf txt

conf:
	cp -r conf-tmpl conf
	rm -rf conf/.svn conf/*/.svn

txt : src/common/GNUmakefile src/login/GNUmakefile src/char/GNUmakefile src/map/GNUmakefile src/ladmin/GNUmakefile conf
	cd src ; cd common ; $(MAKE) $(MKDEF) $@ ; cd .. ; cd ..
	cd src ; cd login ; $(MAKE) $(MKDEF) $@ ; cd .. ; cd ..
	cd src ; cd char ; $(MAKE) $(MKDEF) $@ ; cd .. ; cd ..
	cd src ; cd map ; $(MAKE) $(MKDEF) $@ ; cd .. ; cd ..
	cd src ; cd ladmin ; $(MAKE) $(MKDEF) $@ ; cd .. ; cd ..

ifdef SQLFLAG
sql: src/common/GNUmakefile src/login_sql/GNUmakefile src/char_sql/GNUmakefile src/map/GNUmakefile src/ladmin/GNUmakefile conf
	cd src ; cd common ; $(MAKE) $(MKDEF) $@ ; cd .. ; cd ..
	cd src ; cd login_sql ; $(MAKE) $(MYLIB) $@ ; cd .. ; cd ..
	cd src ; cd char_sql ; $(MAKE) $(MYLIB) $@ ; cd .. ; cd ..
	cd src ; cd map ; $(MAKE) $(MYLIB) $@ ; cd .. ; cd ..
	cd src ; cd ladmin ; $(MAKE) $(MKDEF) $@ ; cd .. ; cd ..
else
sql:
	$(MAKE) CC="$(CC)" OPT="$(OPT)" SQLFLAG=1 $@
endif

clean: src/common/GNUmakefile src/login/GNUmakefile src/char/GNUmakefile src/map/GNUmakefile src/ladmin/GNUmakefile
	cd src ; cd common ; $(MAKE) $(MKDEF) $@ ; cd .. ; cd ..
	cd src ; cd login ; $(MAKE) $(MKDEF) $@ ; cd .. ; cd ..
	cd src ; cd login_sql ; $(MAKE) $(MKLIB) $@ ; cd .. ; cd ..
	cd src ; cd char ; $(MAKE) $(MKDEF) $@ ; cd .. ; cd ..
	cd src ; cd char_sql ; $(MAKE) $(MKLIB) $@ ; cd .. ; cd ..
	cd src ; cd map ; $(MAKE) $(MKLIB) $@ ; cd .. ; cd ..
	cd src ; cd ladmin ; $(MAKE) $(MKDEF) $@ ; cd .. ; cd ..


src/common/GNUmakefile: src/common/Makefile
	sed -e 's/$$>/$$^/' src/common/Makefile > src/common/GNUmakefile
src/login/GNUmakefile: src/login/Makefile
	sed -e 's/$$>/$$^/' src/login/Makefile > src/login/GNUmakefile
src/login_sql/GNUmakefile: src/login_sql/Makefile
	sed -e 's/$$>/$$^/' src/login_sql/Makefile > src/login_sql/GNUmakefile
src/char/GNUmakefile: src/char/Makefile
	sed -e 's/$$>/$$^/' src/char/Makefile > src/char/GNUmakefile
src/char_sql/GNUmakefile: src/char_sql/Makefile
	sed -e 's/$$>/$$^/' src/char_sql/Makefile > src/char_sql/GNUmakefile
src/map/GNUmakefile: src/map/Makefile
	sed -e 's/$$>/$$^/' src/map/Makefile > src/map/GNUmakefile
src/ladmin/GNUmakefile: src/ladmin/Makefile
	sed -e 's/$$>/$$^/' src/ladmin/Makefile > src/ladmin/GNUmakefile
