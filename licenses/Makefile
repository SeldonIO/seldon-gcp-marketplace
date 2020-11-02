SHELL=/bin/bash

VERSION=1.4.0

seldon-core:
	git clone -b v${VERSION}  https://github.com/SeldonIO/seldon-core.git


executor.csv: seldon-core
	cut -d, -f 1,2,3 seldon-core/executor/licenses/license_info.csv | sed 's/$$/,,YES/'  > executor.csv

operator.csv: seldon-core
	cut -d, -f 1,2,3 seldon-core/operator/licenses/license_info.csv | sed 's/$$/,,YES/'  > operator.csv

engine.txt: seldon-core
	cd seldon-core/engine && mvn verify && cp target/generated-sources/license/LICENSES_THIRD_PARTY ../../engine.txt

engine2.txt:
	cat engine.txt | sed 's/^.*\*.*\((.*:.* - .*)\)/\*\1/' > engine2.txt

engine.csv: engine2.txt
	python create_engine_csv.py > engine.csv


show_operator_licenses:
	./show_license_layer.sh  seldonio/seldon-core-operator:${VERSION}

show_executor_licenses:
	./show_license_layer.sh  seldonio/seldon-core-executor:${VERSION}

show_engine_licenses:
	docker run -it --rm --entrypoint find seldonio/engine:${VERSION} /licenses


clean:
	rm -f engine2.txt
	rm -rf seldon-core
