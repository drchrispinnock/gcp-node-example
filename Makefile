SOURCES=$(wildcard *.md)
OBJECTS=$(patsubst %.md, %.pdf, $(SOURCES))

PDFENGINE=/Library/TeX/texbin/pdflatex

all:	$(OBJECTS)

clean:
	@rm -rf $(OBJECTS)

%.pdf:	%.md
	@echo "=> Building $@"
	@pandoc --pdf-engine=${PDFENGINE} --from markdown+pipe_tables --template templates/eisvogel-cp.tex -N --toc --output=$@ --listings --no-highlight -f markdown+implicit_figures $<



