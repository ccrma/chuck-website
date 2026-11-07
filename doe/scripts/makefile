# --------
# rebuild examples and site index for search; to run:
#   > make
# --------
all:
	@echo ===========================================
	@echo generating HTML pages for ChuGL examples...
	@echo ===========================================
	bash make-webchugl-examples.sh
	@echo ====================================
	@echo updating example and site indices...
	@echo ====================================
	pushd ../..; python3 doe/scripts/update_site.py; popd
	@echo ==========================
	@echo reformatting JSON files...
	@echo ==========================
	pushd ../../search/; python3 -m json.tool site.json > tmp.json && yes | mv tmp.json site.json; popd
	pushd ../../search/; python3 -m json.tool examples.json > tmp.json && yes | mv tmp.json examples.json; popd
	
#=====
# TODO need to run relink_examples.py (which currently is not working
# on some machines), but is needed if new examples are added to or removed
# from the ignore list
#=====
