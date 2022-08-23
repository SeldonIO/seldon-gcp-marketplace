SHELL=/bin/bash

VERSION=1.14.1

seldon-core:
	git clone -b v${VERSION}  https://github.com/SeldonIO/seldon-core.git


executor.csv: seldon-core
	cut -d, -f 1,2,3 seldon-core/executor/licenses/license_info.csv | sed 's/$$/,,YES/'  > executor.csv

operator.csv: seldon-core
	cut -d, -f 1,2,3 seldon-core/operator/licenses/license_info.csv | sed 's/$$/,,YES/'  > operator.csv

show_operator_licenses:
	./show_license_layer.sh  seldonio/seldon-core-operator:${VERSION}

show_executor_licenses:
	./show_license_layer.sh  seldonio/seldon-core-executor:${VERSION}

.PHONY: update_all
update_all: clean operator.csv executor.csv

clean:
	rm -f operator.csv
	rm -f executor.csv
	rm -rf seldon-core
