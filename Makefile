SHELL := /bin/bash
THESIS := thesis.pdf

.PHONY: clean

default: $(THESIS)

# https://tex.stackexchange.com/q/53235/4878
%.pdf: %.tex
	pdflatex $*
	bibtex $*
	pdflatex $*
	pdflatex $*

clean:
	rm -f *.{pdf,aux,bbl,blg,lof,log,toc,out}
