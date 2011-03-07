#!/usr/local/bin/stsh
#pdfbundle := NSBundle bundleWithPath:'/Library/Frameworks/#MPWPDFInterpreter.framework'
#pdfbundle load
filename := args objectAtIndex:1
stdout print: 'pdfdump of: '
stdout println: filename

data := NSData dataWithContentsOfMappedFile: filename
pdf := (MPWPDFFile alloc initWithPdfData:data ) autorelease
pdf parseXrefTables
stdout println:'hello'.

min := pdf minObjectNo.
max := pdf maxObjectNo.
max := max-1.
max:= 27.
stdout print:'min: '. stdout println:min.
stdout print:'max: '. stdout println:max.
objs := pdf collect pdfObjectForNumber: (min to:max ) each.
stdout do println:objs each.

