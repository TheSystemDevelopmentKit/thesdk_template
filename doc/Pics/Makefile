#For good documentation, check
#http://www.chemie.fu-berlin.de/chemnet/use/info/make/make_10.html#SEC94
##http://stackoverflow.com/questions/7815400/how-do-i-make-makefile-to-recompile-only-changed-files

DENSITY=300
WD= $(shell pwd)
BITMAPDIR= $(WD)/bitmaps
#vpath %.eps ./Cartesian

SRC= $(wildcard $(WD)/*.eps)


TARG=$(SRC:$(WD)/%.eps=$(BITMAPDIR)/%.png)

CONV=convert -density $(DENSITY)x$(DENSITY)
.PHONY: clean all
#All these dofiles provide eps figure, so they can be used as a target
#Another alternative target is the logfile

all : $(TARG)

##All the .eps files are provided by .m files, so m-files are given as 
#sources. $< is the first dependency argument on the right side of the colon
#Rules for the epsfiles

$(BITMAPDIR)/%.png: $(WD)/%.eps 
	$(CONV) $< $@

clean:
	rm -f $(TARG) 

