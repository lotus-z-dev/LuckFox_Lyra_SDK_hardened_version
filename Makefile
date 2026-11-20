# ==============================================================================
# Luckfox Lyra Hardened SDK — Root Makefile Wrapper
# Delegates cleanly to device/rockchip/common/Makefile so upstream relative
# SDK_DIR resolution works accurately without fragile root symlinks.
# ==============================================================================

UPSTREAM_MAKEFILE := $(CURDIR)/device/rockchip/common/Makefile

ifeq ($(wildcard $(UPSTREAM_MAKEFILE)),)
.PHONY: default
default:
	@echo "ERROR: Upstream Rockchip Makefile not found at $(UPSTREAM_MAKEFILE)." >&2
	@echo "Please clone/extract the official Luckfox Lyra SDK into this directory," >&2
	@echo "then run ./apply-hardened-patches.sh before running make." >&2
	@exit 1
else
.DEFAULT_GOAL := build

.PHONY: build
build:
	@$(MAKE) --no-print-directory -f "$(UPSTREAM_MAKEFILE)"

%:
	@$(MAKE) --no-print-directory -f "$(UPSTREAM_MAKEFILE)" "$@"
endif
