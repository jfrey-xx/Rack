ifndef RACK_DIR
$(error RACK_DIR is not defined)
endif

ifndef VERSION
$(error VERSION is not defined)
endif

include $(RACK_DIR)/arch.mk

FLAGS += -DVERSION=$(VERSION)
# Generate dependency files alongside the object files
FLAGS += -MMD -MP
FLAGS += -g
# Optimization
FLAGS += -O3 -march=nocona -ffast-math -fno-finite-math-only
FLAGS += -Wall -Wextra -Wno-unused-parameter

ifneq ($(ARCH), mac)
	CXXFLAGS += -Wsuggest-override
endif
CXXFLAGS += -std=c++11


ifdef ARCH_LIN
	FLAGS += -DARCH_LIN
endif
ifdef ARCH_MAC
	FLAGS += -DARCH_MAC
	CXXFLAGS += -stdlib=libc++
	LDFLAGS += -stdlib=libc++
	MAC_SDK_FLAGS = -mmacosx-version-min=10.7
	FLAGS += $(MAC_SDK_FLAGS)
	LDFLAGS += $(MAC_SDK_FLAGS)
endif
ifdef ARCH_WIN
	FLAGS += -DARCH_WIN
	FLAGS += -D_USE_MATH_DEFINES
endif

CFLAGS += $(FLAGS)
CXXFLAGS += $(FLAGS)


# Derive object files from sources and place them before user-defined objects
OBJECTS := $(patsubst %, build/%.o, $(SOURCES)) $(OBJECTS)
DEPENDENCIES := $(patsubst %, build/%.d, $(SOURCES))

# Final targets

$(TARGET): $(OBJECTS)
	$(CXX) -o $@ $^ $(LDFLAGS)

-include $(DEPENDENCIES)

build/%.c.o: %.c | dep
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $<

build/%.cpp.o: %.cpp | dep
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

build/%.cc.o: %.cc | dep
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

build/%.m.o: %.m | dep
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $<

# Dummy target
dep:

.PHONY: dep
