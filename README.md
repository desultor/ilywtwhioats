ilywtwhioats
====================================================================

Purpose
-----
Given a string of letters, construct an acrostic of bird names!


Caveats
---
No single-word bird names start with the letters "q", "u", or "x". I have added "Quetzal", "Xenornis", and "Upupa" so that we can provide an acrostic for any string of letters.

Super ridiculously verbose output! Removing some of the extra single-letter matches from the taxonomy might help contain this a little bit. The included file **tax_common_cut.txt** is a stripped-down version which should give less crazy results.

Usage
---
Create a file of results using
```
perl sonnet.pl > results.txt
```

This file will easily be 100 GB in size, with 

You can remove rows which contain duplicate names using something like 

```
cat results.txt | perl -lne '%present = (); my @foo = split ", ", $_; foreach $entry (@foo) {unless ($present{$entry}) {print} $present{$entry}++}' > de_duplicated.txt
```
(or just insert that perl command into a pipeline right after running sonnet.pl) but this won't necessarily save you too much space. Maybe something on the order of 1/500 of the results seem to have duplicates in my test case.
