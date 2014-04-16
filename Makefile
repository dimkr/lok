#	$OpenBSD: Makefile,v 1.13 2013/07/28 18:10:16 miod Exp $

PROG=	awk
SRCS=	ytab.c lex.c b.c main.c parse.c proctab.c tran.c lib.c run.c
PKG_CONFIG?=	pkg-config
LDADD=	-lm $(shell $(PKG_CONFIG) --libs lobsder)
DPADD=	${LIBM}
CLEANFILES+=proctab.c maketab ytab.c ytab.h
CURDIR=	$(shell pwd)
CC?=	cc
HOSTCC?=	$(CC)
CFLAGS+=-I. -I${CURDIR} -DHAS_ISBLANK -DNDEBUG $(shell $(PKG_CONFIG) --cflags lobsder)
HOSTCFLAGS+=-I. -I${CURDIR} -DHAS_ISBLANK -DNDEBUG
DESTDIR?=
PREFIX?=/usr
BINDIR=$(PREFIX)/bin
MANDIR=$(PREFIX)/man

all: $(PROG)

$(PROG): proctab.c
	$(CC) $(CFLAGS) $(SRCS) $(LDFLAGS) $(LDADD) -o $(PROG)

ytab.c ytab.h: awkgram.y
	${YACC} -d ${CURDIR}/awkgram.y
	mv y.tab.c ytab.c
	mv y.tab.h ytab.h

proctab.c: ytab.h maketab.c
	${HOSTCC} ${HOSTCFLAGS} ${CURDIR}/maketab.c -o $@
	./maketab >proctab.c

install: $(PROG)
	install -D -m 755 $(PROG) $(DESTDIR)/$(BINDIR)/$(PROG)
	install -D -m 644 $(PROG).1 $(DESTDIR)/$(MANDIR)/man1/$(PROG).1
