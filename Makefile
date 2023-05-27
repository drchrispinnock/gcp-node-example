SOURCES=$(wildcard *.md)
OBJECTS=$(patsubst %.md, %.pdf, $(SOURCES))

all:	$(OBJECTS)

clean:
	@rm -rf $(OBJECTS)

%.pdf:	%.md
	@echo "=> Building $@"
	@pandoc --from markdown+pipe_tables --template templates/eisvogel-cp.tex -N --toc --output=$@ --listings --no-highlight -f markdown+implicit_figures $<



