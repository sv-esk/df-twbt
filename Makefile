DFHACKVER ?= 0.40.24-r4

DFVERNUM = `echo $(DFHACKVER) | sed -e s/-r.*// -e s/\\\\.//g`

TWBT_VER ?= "5.xx"

DF ?= /Users/vit/Downloads/df_40_24_osx
DH ?= /Users/vit/Downloads/buildagent-2/workspace/root/dfhack/master

SRC = twbt.cpp
DEP = renderer.hpp config.hpp dungeonmode.hpp dwarfmode.hpp renderer_twbt.h commands.hpp plugin.hpp tileupdate_text.hpp tileupdate_map.hpp patches.hpp zoomfix.hpp Makefile legacy/renderer_legacy.hpp legacy/twbt_legacy.hpp

ifeq ($(shell uname -s), Darwin)
	ifneq (,$(findstring 0.34,$(DFHACKVER)))
		EXT = so
	else
		EXT = dylib
	endif
else
	EXT = so
endif
OUT = dist/$(DFHACKVER)/twbt.plug.$(EXT)

INC = -I"$(DH)/library/include" -I"$(DH)/library/proto" -I"$(DH)/depends/protobuf" -I"$(DH)/depends/lua/include"
LIB = -L"$(DH)/build/library" -ldfhack -ldfhack-version

CXX ?= c++
CFLAGS = $(INC) -m32 -DLINUX_BUILD -O3
LDFLAGS = $(LIB) -shared 

ifeq ($(shell uname -s), Darwin)
	export MACOSX_DEPLOYMENT_TARGET=10.6
	CXX = g++-4.5
	CFLAGS += -std=gnu++0x #-stdlib=libstdc++
	CFLAGS += -Wno-tautological-compare
	LDFLAGS += -framework OpenGL -mmacosx-version-min=10.6 -undefined dynamic_lookup
else
	CFLAGS += -std=c++0x
endif


all: $(OUT)

$(OUT): $(SRC) $(DEP)
	-@mkdir -p `dirname $(OUT)`
	$(CXX) $(SRC) -o $(OUT) -DDFHACK_VERSION=\"$(DFHACKVER)\" -DDF_$(DFVERNUM) -DTWBT_VER=\"$(TWBT_VER)\" $(CFLAGS) $(LDFLAGS)

inst: $(OUT)
	cp $(OUT) "$(DF)/hack/plugins/"

inst_all:
	make inst
	cd plugins && DFHACKVER=$(DFHACKVER) DF=$(DF) DH=$(DH) PLUGIN=mousequery make inst
	cd plugins && DFHACKVER=$(DFHACKVER) DF=$(DF) DH=$(DH) PLUGIN=resume make inst
	cd plugins && DFHACKVER=$(DFHACKVER) DF=$(DF) DH=$(DH) PLUGIN=automaterial make inst

clean:
	-rm $(OUT)