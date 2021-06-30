SHELL := /bin/bash
GIT_REMOTE := $(shell git config remote.origin.url)
GH_API := https://api.github.com
THESIS := thesis.pdf
PURGE_URL := https://cmbuckley.co.uk/research/

.PHONY: travis clean purge travis_success

default: $(THESIS)

# https://tex.stackexchange.com/q/53235/4878
%.pdf: %.tex
	pdflatex $*
	bibtex $*
	pdflatex $*
	pdflatex $*

travis: $(THESIS)
ifeq ($(TRAVIS_PULL_REQUEST), true)
	@echo 'Travis target not executed for pull requests.'
else
	git config user.name $(GIT_NAME)
	git config user.email $(GIT_EMAIL)
	git add -f $(THESIS)
	git commit -m 'Updated GitHub Pages'
	git push -f "https://$(GIT_TOKEN)@$(word 2,$(subst ://, ,$(GIT_REMOTE)))" HEAD:gh-pages
endif

clean:
	rm -f *.{pdf,aux,bbl,blg,lof,log,toc}

purge:
	curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$(CLOUDFLARE_ZONE)/purge_cache" \
		-H "Authorization: Bearer $(CLOUDFLARE_TOKEN)" \
		-H "Content-Type: application/json" \
		--data '{"files":["$(PURGE_URL)"]}'

travis_success: purge
