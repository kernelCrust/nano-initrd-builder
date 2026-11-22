export
-include .ENV

WORKDIR=./work-dir
ROOTFS=$(WORKDIR)/rootfs
INIT_SCRIPT=$(ROOTFS)/init
INITRD_IMG=$(PWD)/$(WORKDIR)/initrd.img
MODULES_ROOT=$(ROOTFS)/lib/modules/
MODULES=$(PWD)/$(MODULES_ROOT)/$(KERNEL_VER)/kernel/
SOURCE_MODULES=/lib/modules/$(KERNEL_VER)/kernel/
MODULES_LIST=$(shell cat assets/modules.list)

# # # # # # # # # # # # # # # # # # # # # # # #
dev:
	@vim Makefile
# # # # # # # # # # # # # # # # # # # # # # # #
all: $(INITRD_IMG)
	@echo '<-- ($@)'

$(INITRD_IMG): initrd-content
	@cd $(ROOTFS) && find . | cpio -o -V -H newc --owner=0:0 | gzip -9 > $(INITRD_IMG)
	@echo '<-- ($@)'

initrd-content: init-scripts reinstall-busybox reinstall-modules
	@echo '<-- ($@)'

reinstall-busybox: $(ROOTFS) $(BUSYBOX)
	@mkdir -pv $(ROOTFS)/bin
	@rm -vf $(ROOTFS)/bin/*
	@cp -v $(BUSYBOX) $(ROOTFS)/bin/busybox.main
	@echo '--> ($@) install..'
	@cd $(ROOTFS)/bin/ && for app in $$(./busybox.main --list); do ln -sf busybox.main $$app; done
	@echo '<-- ($@)'

reinstall-modules: $(ROOTFS) reinstall-busybox
	@rm -vrf $(MODULES_ROOT)
	@mkdir -pv $(MODULES)
	@echo '--> ($@) install..'
	@cd $(SOURCE_MODULES) && cp -v --parents -t $(MODULES) $(MODULES_LIST)
	@cd $(ROOTFS)/ && ./bin/depmod -b . $(KERNEL_VER)
	@echo '<-- ($@)'

init-scripts: $(ROOTFS)
	@cp -v assets/init $(ROOTFS)
	@chmod +x $(ROOTFS)/init
	@mkdir -pv $(ROOTFS)/init-scripts
	@cp -v assets/init-scripts/* $(ROOTFS)/init-scripts/
	@chmod +x $(ROOTFS)/init-scripts/*
	@echo '<-- ($@)'

$(ROOTFS):
	@mkdir -pv $(ROOTFS)
	@echo '<-- ($@)'

clean: #ram.umount
	@rm -vr $(WORKDIR)
	@echo '<-- ($@)'
ram.umount:
	@sudo umount $(ROOTFS) || true

kvm kvm.shell kvm.ttyS0 kvm.nvme kvm.ahci kvm.normal kvm.alt_live kvm.label kvm.normal.label kvm.normal.uuid:
	@scripts/kvm-runner.sh $@

# # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # #
CHECK_GIT_STATUS = git status -s | sed 's/"/|/g'
sync: commitall pull push
pull:
	@git pull
push:
	@echo '--> PUSH to GitHub..'
	@git push
commitall: addall
	@echo '--> COMMIT if STATUS allows..'
	@if [ -n "$(shell $(CHECK_GIT_STATUS))" ]; \
		then \
			git commit -m 'saving'; \
		else \
			echo '--- nothing to commit'; \
	fi
addall:
	@echo '--> ADD-ALL..'
	@git add .
