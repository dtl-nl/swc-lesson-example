#!/bin/bash
#
# All in one.
#
# Need to be run from the root of the lesson.

DIR=_all_in_one
TMP=tmp.html  # We use this to generate all the others files
HTML=aio.html  # This will be process by Jekyll
EPUB=aio.epub  # This requires Pandoc
TEX=aio.tex  # To debug
PDF=aio.pdf  # This requires LaTeX and Pandoc

# Create directory
mkdir -p $DIR

# Need the HTML lesson
make site

# Create $TMP
for file in _site/index.html _site/??-*/index.html
do
    xmllint \
        --html \
        --xpath '//article/*' \
        $file >> $DIR/$TMP
done

# Need to convert SVG to PNG
# because LaTeX doesn't support SVG.
for i in fig/*.svg
do
    inkscape -f $i -e ${i/svg/png}
done

# Need to change directoty otherwise figures will be missing.
cd $DIR

# Create $EPUB
pandoc \
    -f html \
    -t epub3 \
    -o $EPUB \
    $TMP

# Create $PDF
pandoc \
    -f html \
    -t latex \
    --standalone \
    -V papersize=A4 \
    -V fontsize=12pt \
    -V documentclass=book \
    -V toc \
    -o $TEX \
    $TMP
# Workaround for http://tex.stackexchange.com/questions/327777/weird-somethings-wrong-perhaps-a-missing-item-when-using-itemize-inside-qu
sed -i 's/begin{quote}/begin{minipage}[c]{0.8\\textwidth}/g' $TEX
sed -i 's/end{quote}/end{minipage}/g' $TEX
# Workaround for lack of support to SVG
sed -i 's/svg/png/g' $TEX
# Workaround for the lack of latexmk
for i in 1 2 3;
do
pdflatex \
    -interaction nonstopmode \
    -output-format pdf \
    $TEX
done

# Create $HTML

echo "---
---" > $HTML
cat $TMP >> $HTML
rm $TMP
