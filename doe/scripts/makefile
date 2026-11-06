# --------
# rebuild examples and site index for search; to run:
#   > make
# --------
all:
	bash make-webchugl-examples.sh
	pushd ../..; python3 doe/scripts/update_site.py; popd

#=====
# TODO need to run relink_examples.py (which currently is not working
# on some machines), but is needed if new examples are added to or removed
# from the ignore list
#=====
