all: clean package

clean:
	rm -rf .build .test

package:
	bash package.sh

install:
	install -d $(DESTDIR)$(prefix)/usr/bin
	install -m 755 src/main/script/krun.sh $(DESTDIR)$(prefix)/usr/bin/krun
	bash install-deps.sh
	bash install.sh

test:
	bash test.sh
