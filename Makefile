ECHO=/bin/echo
ECHO_N=/bin/echo -n

PAGES=R-intro R-lang R-exts R-data R-admin R-ints

all: build

clean:
	@rm -f *.html

fetch:
	@for p in $(PAGES); do echo "Fetching $${p}.html..."; curl --progress-bar "http://cran.r-project.org/doc/manuals/$${p}.html" -o "$${p}.html.in"; done

upload: build upload_timestamp

build:
	@$(MAKE) `ls -1 *.html.in | sort | sed 's/\.in$$//'` || exit 1

%.html: %.html.in build.rb
	@$(ECHO_N) "Building $@... "
	@./build.rb $< >$@ || ( rm -f $@; exit 1 )
	@$(ECHO) "done"

upload_timestamp: *.html *.css *.js *.png
	@scp $? `cat upload_target` && touch upload_timestamp
