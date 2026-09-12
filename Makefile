.SILENT:
all: frontend/cities.json

cities500.zip:
	curl -o $@ https://download.geonames.org/export/dump/cities500.zip

allCountries.zip:
	curl -o $@ https://download.geonames.org/export/dump/allCountries.zip

CS.zip:
	curl -o $@ https://download.geonames.org/export/dump/CS.zip


frontend/cities.json: cities500.zip
	echo "[" > $@
	unzip -p $<  \
		| cut -f2,5,6 \
		| sed -e 's/"/\\"/g' \
		| sed -E 's/^([^\t]+)\t+([^\t]+)\t+([^\t]+)/["\1",\2,\3],/' \
		| head -c-2>> $@
	echo "]" >> $@

cities.json: cities500.zip
	echo "[" > $@
	unzip -p $<  \
		| cut -f2,5,6 \
		| sed -e 's/"/\\"/g' \
		| sed -E 's/^([^\t]+)\t+([^\t]+)\t+([^\t]+)/["\1",\2,\3],/' \
		| head -c-2>> $@
	echo "]" >> $@

allCountries.json: allCountries.zip
	echo "[" > $@
	unzip -p $<  \
		| cut -f2,5,6 \
		| sed -e 's/"/\\"/g' \
		| sed -E 's/^([^\t]+)\t+([^\t]+)\t+([^\t]+)/["\1",\2,\3],/' \
		| head -c-2>> $@
	echo "]" >> $@

cs.json: CS.zip
	echo "[" > $@
	unzip -p $< CS.txt \
		| cut -f2,5,6 \
		| sed -e 's/"/\\"/g' \
		| sed -E 's/^([^\t]+)\t+([^\t]+)\t+([^\t]+)/["\1",\2,\3],/' \
		| head -c-2>> $@
	echo "]" >> $@

CZ: allCountries.zip
	zcat $< | egrep "([^\t]*\t){8}CZ" > $@

CZ_cities.json: CZ
	echo "[" > $@
	< $< \
		egrep "([^\t]*\t){6}P\t" \
		| cut -f2,5,6 \
		| sed -e 's/"/\\"/g' \
		| sed -E 's/^([^\t]+)\t+([^\t]+)\t+([^\t]+)/["\1",\2,\3],/' \
		| head -c-2>> $@
	echo "]" >> $@



# Tohle jsem vzdal - nepodařilo se mi zprovoznit žádné rozumné řešení :-(
# idk.sentinel:
# 	cd frontent \
# 	&& npm pack deck.gl@9.3.10 maplibre-gl \
# 	&& mkdir -p deck.gl && tar -xzf deck.gl-*.tgz -C deck.gl --strip-components=1
# 	&& mkdir -p maplibre-gl && tar -xzf maplibre-gl-*.tgz -C maplibre-gl --strip-components=1
