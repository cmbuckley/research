SHELL=/bin/bash
GIT_REMOTE := $(shell git config remote.origin.url)
GH_API := https://api.github.com
SRC = _src
OUT = -output-directory $(SRC)

.PHONY: pdf travis clean purge travis_success

default: $(SRC)/thesis.pdf

# https://tex.stackexchange.com/q/53235/4878
%.pdf:
	TEXINPUTS=$(SRC):: pdflatex $(OUT) $(*F)
	BIBINPUTS=$(SRC):: bibtex $*
	TEXINPUTS=$(SRC):: pdflatex $(OUT) $(*F)
	TEXINPUTS=$(SRC):: pdflatex $(OUT) $(*F)

travis: default
ifeq ($(TRAVIS_PULL_REQUEST), true)
	@echo 'Travis target not executed for pull requests.'
else
	git config user.name $(GIT_NAME)
	git config user.email $(GIT_EMAIL)
	git add -f thesis.pdf
	git commit -m 'Updated GitHub Pages'
	git push -f "https://$(GIT_TOKEN)@$(word 2,$(subst ://, ,$(GIT_REMOTE)))" HEAD:gh-pages
endif

clean:
	rm -f $(SRC)/*.{pdf,aux,bbl,blg,lof,log,toc}

purge:
	curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$(CLOUDFLARE_ZONE)/purge_cache" \
		-H "X-Auth-Email: $(CLOUDFLARE_EMAIL)" -H "X-Auth-Key: $(CLOUDFLARE_TOKEN)" \
		-H "Content-Type: application/json" --data '{"purge_everything":true}'

travis_success: purge
