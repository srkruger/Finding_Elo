
svg_files = $(wildcard *.svg)
png_files = $(svg_files:.svg=.png)
pdf_files = $(svg_files:.svg=.pdf)

%.png : %.svg
	inkscape --export-png=$@ $< --export-width=600

%.pdf : %.svg
	inkscape --export-pdf=$@ $<

all : $(png_files)
	echo "done"

clean :
	-rm -f $(png_files)
	-rm -f $(pdf_files)

