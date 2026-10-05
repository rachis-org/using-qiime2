.PHONY: lint html clean

lint:
	cd book && jupyter book build \
	  --warningiserror \
	  --nitpick \
	  --keep-going \
	  --all \
	  --verbose

html:
	cd book && Q2DOC_BASE_COMMAND='qiime2' jupyter book build --html

clean:
	cd book && jupyter book clean

serve:
	npx serve book/_build/html/ -p 4000
