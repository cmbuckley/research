SHELL=/bin/bash
GIT_REMOTE := $(shell git config remote.origin.url)
GH_API := https://api.github.com
THESIS_TEX = thesis.tex

.PHONY: pdf travis clean purge travis_success

default: pdf

# https://tex.stackexchange.com/q/53235/4878
pdf: $(THESIS_TEX)
	pdflatex $(THESIS_TEX)
	bibtex thesis
	pdflatex $(THESIS_TEX)
	pdflatex $(THESIS_TEX)

travis: default
ifeq ($(TRAVIS_PULL_REQUEST), true)
	@echo 'Travis target not executed for pull requests.'
else
	git config user.name $(GIT_NAME)
	git config user.email $(GIT_EMAIL)
	git add -f thesis.pdf
	git commit -m 'Updated GitHub Pages'
	git push -fq "https://$(GIT_TOKEN)@$(word 2,$(subst ://, ,$(GIT_REMOTE)))" HEAD:gh-pages >/dev/null 2>&1
endif

clean:
	rm -f thesis.pdf *.{aux,bbl,blg,lof,log,toc}

purge:
	curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$(CLOUDFLARE_ZONE)/purge_cache" \
		-H "X-Auth-Email: $(CLOUDFLARE_EMAIL)" -H "X-Auth-Key: $(CLOUDFLARE_TOKEN)" \
		-H "Content-Type: application/json" --data '{"purge_everything":true}'

travis_success: purge
