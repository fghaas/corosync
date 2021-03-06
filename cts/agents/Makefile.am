#
# Copyright (c) 2010 Red Hat, Inc.
#
# Authors: Angus Salkeld (asalkeld@redhat.com)
#
# This software licensed under BSD license, the text of which follows:
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# - Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# - Neither the name of the MontaVista Software, Inc. nor the names of its
#   contributors may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.

MAINTAINERCLEANFILES = Makefile.in
INCLUDES = -I$(top_builddir)/include -I$(top_srcdir)/include \
		-I$(top_builddir)/include/corosync

SOURCES =
TEST_AGENTS = cpg_test_agent confdb_test_agent sam_test_agent votequorum_test_agent

EXTRA_DIST		= syncv2.c

if INSTALL_TESTAGENTS
agentdir = $(datadir)/$(PACKAGE)/tests
bin_PROGRAMS = $(TEST_AGENTS)
dist_agent_SCRIPTS = mem_leak_test.sh net_breaker.sh confdb-dispatch-deadlock.sh

AM_CFLAGS		= -fPIC
SERVICE_LCRSO		= syncv2
SOURCES			+= $(SERVICE_LCRSO:%=%.c)
LCRSO			= $(SERVICE_LCRSO:%=service_%.lcrso)
LCRSO_OBJS		= $(SOURCES:%.c=%.o)
else
noinst_PROGRAMS = $(TEST_AGENTS)
noinst_SCRIPTS = mem_leak_test.sh net_breaker.sh confdb-dispatch-deadlock.sh
LCRSO =
LCRSO_OBJS =
endif

noinst_HEADERS          = common_test_agent.h

cpg_test_agent_SOURCES = cpg_test_agent.c common_test_agent.c
cpg_test_agent_LDADD =  -lcpg -lcfg -lcoroipcc ../../exec/coropoll.o ../../exec/crypto.o
cpg_test_agent_LDFLAGS =  -L../../lib -L.

confdb_test_agent_SOURCES = confdb_test_agent.c common_test_agent.c
confdb_test_agent_LDADD =  -lconfdb -lcoroipcc ../../exec/coropoll.o
confdb_test_agent_LDFLAGS =  -L../../lib 

sam_test_agent_SOURCES = sam_test_agent.c common_test_agent.c
sam_test_agent_LDADD =  -lsam -lquorum -lcoroipcc  -lconfdb ../../exec/coropoll.o
sam_test_agent_LDFLAGS =  -L../../lib 

votequorum_test_agent_SOURCES = votequorum_test_agent.c common_test_agent.c
votequorum_test_agent_LDADD =  -lvotequorum -lquorum -lcoroipcc ../../exec/coropoll.o
votequorum_test_agent_LDFLAGS =  -L../../lib 

if BUILD_DARWIN

service_%.lcrso: %.o
	$(CC) $(LDFLAGS) $(CFLAGS) -L$(top_builddir)/exec -llogsys -bundle -bundle_loader $(top_builddir)/exec/corosync $^ -o $@

else
if BUILD_SOLARIS

service_%.lcrso: %.o
	$(LD) $(LDFLAGS) -G $^ -o $@

else

service_%.lcrso: %.o
	$(CC) $(LDFLAGS) $(CFLAGS) $(COVERAGE_LCRSO_EXTRA_LDFLAGS) -shared -Wl,-soname=$@ $^ -o $@
endif
endif



if INSTALL_TESTAGENTS
syncv2.o: syncv2.c
	$(CC) $(AM_CFLAGS) $(CFLAGS) $(CPPFLAGS) $(INCLUDES) -c -o $@ $<

all-local: $(LCRSO_OBJS) $(LCRSO)
	@echo Built Service Engines

install-exec-local:
	$(INSTALL) -d $(DESTDIR)/$(LCRSODIR)
	$(INSTALL) -m 755 $(LCRSO) $(DESTDIR)/$(LCRSODIR)

uninstall-local:
	cd $(DESTDIR)/$(LCRSODIR) && \
		rm -f $(LCRSO)

endif

clean-local:
	rm -f *.o *.a *.so* *.da *.bb *.bbg *.lcrso

lint:
	-splint $(LINT_FLAGS) $(CFLAGS) *.c

