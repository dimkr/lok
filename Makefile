#	$OpenBSD: Makefile,v 1.16 2017/07/10 21:30:37 espie Exp $

PROG=	awk
SRCS=	ytab.c lex.c b.c main.c parse.c proctab.c tran.c lib.c run.c reallocarray.c strlcpy.c strlcat.c
PKG_CONFIG?=	pkg-config
LDADD=	-lm
DPADD=	${LIBM}
CLEANFILES+=proctab.c maketab ytab.c ytab.h
CURDIR=	$(shell pwd)
CC?=	cc
HOSTCC?=	$(CC)
CFLAGS+=-I. -I${CURDIR} -DHAS_ISBLANK -DNDEBUG
HOSTCFLAGS+=-I. -I${CURDIR} -DHAS_ISBLANK -DNDEBUG
DESTDIR?=
PREFIX?=/usr
BINDIR=$(PREFIX)/bin
MANDIR=$(PREFIX)/man

all: $(PROG)

$(PROG): proctab.c
	$(CC) $(CFLAGS) $(SRCS) $(LDFLAGS) $(LDADD) -o $(PROG)

ytab.c ytab.h: awkgram.y
	${YACC} -o ytab.c -d ${CURDIR}/awkgram.y

BUILDFIRST = ytab.h

proctab.c: ytab.h maketab.c
	${HOSTCC} ${HOSTCFLAGS} ${CURDIR}/maketab.c -o maketab
	./maketab >proctab.c

install: $(PROG)
	install -D -m 755 $(PROG) $(DESTDIR)/$(BINDIR)/$(PROG)
	install -D -m 644 $(PROG).1 $(DESTDIR)/$(MANDIR)/man1/$(PROG).1
