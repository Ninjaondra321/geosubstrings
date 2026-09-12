.SILENT:
all: frontend/cities.json

EUROPE_COUNTRIES := AD, AL, AM, AT, AX, AZ, BA, BE, BG, BY, CH, CY, CZ, DE, DK, EE, ES, FI, FO, FR, GB, GE, GG, GI, GR, HR, HU, IE, IM, IS, IT, JE, KZ, LI, LT, LU, LV, MC, MD, ME, MK, MT, NL, NO, PL, PT, RO, RS, RU, SE, SI, SJ, SK, SM, TR, UA, VA, XK
ALL_COUNTRIES := AD, AE, AF, AG, AI, AL, AM, AN, AO, AQ, AR, AS, AT, AU, AW, AX, AZ, BA, BB, BD, BE, BF, BG, BH, BI, BJ, BL, BM, BN, BO, BQ, BR, BS, BT, BV, BW, BY, BZ, CA, CC, CD, CF, CG, CH, CI, CK, CL, CM, CN, CO, CR, CS, CU, CV, CW, CX, CY, CZ, DE, DJ, DK, DM, DO, DZ, EC, EE, EG, EH, ER, ES, ET, FI, FJ, FK, FM, FO, FR, GA, GB, GD, GE, GF, GG, GH, GI, GL, GM, GN, GP, GQ, GR, GS, GT, GU, GW, GY, HK, HM, HN, HR, HT, HU, ID, IE, IL, IM, IN, IO, IQ, IR, IS, IT, JE, JM, JO, JP, KE, KG, KH, KI, KM, KN, KP, KR, KW, KY, KZ, LA, LB, LC, LI, LK, LR, LS, LT, LU, LV, LY, MA, MC, MD, ME, MF, MG, MH, MK, ML, MM, MN, MO, MP, MQ, MR, MS, MT, MU, MV, MW, MX, MY, MZ, NA, NC, NE, NF, NG, NI, NL, NO, NP, NR, NU, NZ, OM, PA, PE, PF, PG, PH, PK, PL, PM, PN, PR, PS, PT, PW, PY, QA, RE, RO, RS, RU, RW, SA, SB, SC, SD, SE, SG, SH, SI, SJ, SK, SL, SM, SN, SO, SR, SS, ST, SV, SX, SY, SZ, TC, TD, TF, TG, TH, TJ, TK, TL, TM, TN, TO, TR, TT, TV, TW, TZ, UA, UG, UM, US, UY, UZ, VA, VC, VE, VG, VI, VN, VU, WF, WS, XK, YE, YT, YU, ZA, ZM, ZW 
COUNTRY_LIST := $(subst $(comma),,$(EUROPE_COUNTRIES))
TARGETS := $(patsnode report_%, $(COUNTRY_LIST))

cities500.zip:
	curl -o $@ https://download.geonames.org/export/dump/cities500.zip

allCountries.zip:
	curl -o $@ https://download.geonames.org/export/dump/allCountries.zip

CS.zip:
	curl -o $@ https://download.geonames.org/export/dump/CS.zip


frontend/datasets/cities500.json: cities500.zip
	echo "[" > $@
	unzip -p $<  \
		| cut -f2,5,6 \
		| sed -e 's/"/\\"/g' \
		| sed -E 's/^([^\t]+)\t+([^\t]+)\t+([^\t]+)/["\1",\2,\3],/' \
		| head -c-2 >> $@
	echo "]" >> $@

# TODO: Něco s tím udělej!
allCountries.json: allCountries.zip
	echo "[" > $@
	unzip -p $<  \
		| cut -f2,5,6 \
		| sed -e 's/"/\\"/g' \
		| sed -E 's/^([^\t]+)\t+([^\t]+)\t+([^\t]+)/["\1",\2,\3],/' \
		| head -c-2>> $@
	echo "]" >> $@


UNPACK = zcat
CONVERT_AND_SAVE_AS_JSON = cut -f2,5,6 | sed -e 's/\\/\\\\/' | sed -e 's/"/\\"/g' | sed -E 's/^([^\t]+)\t+([^\t]+)\t+([^\t]+)/["\1",\2,\3],/' | head -c-2 > $@ && sed -i '1i [' $@ && echo "]" >> $@

GET_ONLY_CITIES = awk -F'\t' '$$7 == "P"'
ONLY_SPECIFIED_COUNTRY = awk -F'\t' '$$9 == "$*"'


data/updated_countries.json: cities500.zip
	$(UNPACK) $< | $(CONVERT_AND_SAVE_AS_JSON)



frontend/datasets/%_cities.json: allCountries.zip
	$(UNPACK) $< | $(GET_ONLY_CITIES) | $(ONLY_SPECIFIED_COUNTRY)  | $(CONVERT_AND_SAVE_AS_JSON)


frontend/datasets/debug.json: allCountries.zip
	$(UNPACK) $< | grep "\tZlín\t" > $@


frontend/datasets.json:
	./scripts/generate_dataset_list.sh $@


# Tohle jsem vzdal - nepodařilo se mi zprovoznit žádné rozumné řešení :-(
# idk.sentinel:
# 	cd frontent \
# 	&& npm pack deck.gl@9.3.10 maplibre-gl \
# 	&& mkdir -p deck.gl && tar -xzf deck.gl-*.tgz -C deck.gl --strip-components=1
# 	&& mkdir -p maplibre-gl && tar -xzf maplibre-gl-*.tgz -C maplibre-gl --strip-components=1
