BUILDLIB:=MANZAN
MANZAN_TEMPLIB:=MANZANBLD
BUILDVERSION:="Development build \(built with Make\)"

.PHONY: ile camel test

ile:
	gmake -C ile

camel:
	gmake -C camel

test:
	gmake -C test

all: ile camel

install:
	gmake -C config install
	gmake -C ile
	gmake -C camel install

uninstall:
	gmake -C ile uninstall
	gmake -C config uninstall

/QOpenSys/pkgs/bin/zip:
	/QOpenSys/pkgs/bin/yum install zip

/QOpenSys/pkgs/bin/wget:
	/QOpenSys/pkgs/bin/yum install wget

appinstall.jar: /QOpenSys/pkgs/bin/wget
	/QOpenSys/pkgs/bin/wget -O appinstall.jar https://github.com/ThePrez/AppInstall-IBMi/releases/download/v0.0.3/appinstall-v0.0.3.jar

manzan-installer-v%.jar: /QOpenSys/pkgs/bin/zip appinstall.jar
	echo "Building version $*"
	system "clrlib ${MANZAN_TEMPLIB}" || system "crtlib ${MANZAN_TEMPLIB}"
	system "dltlib ${BUILDLIB}" || echo "could not delete"
	system "crtlib ${BUILDLIB}"
	system "dltlib ${BUILDLIB}"
	rm -fr /QOpenSys/etc/manzan
	gmake -C config BUILDVERSION="$*" install
	gmake -C ile BUILDVERSION="$*"
	gmake -C camel BUILDVERSION="$*" clean install
	/QOpenSys/QIBM/ProdData/JavaVM/jdk80/64bit/bin/java -jar appinstall.jar --qsys manzan --dir /QOpenSys/etc/manzan --file /opt/manzan -o $@
