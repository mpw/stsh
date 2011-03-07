#!/usr/local/bin/stsh
#-<void>pdfpagedump:filename page:<int>pageNo
context loadFramework:'EGOS'.
#pdfbundle load
stdout print: 'pdfdump of: '
stdout println: filename

data := NSData dataWithContentsOfMappedFile: filename
pdf := (MPWPDFFile alloc initWithPdfData:data ) autorelease

pages := pdf pages.
stdout do println:pages each.

page := pages objectAtIndex:pageNo.
content := page contentStreams objectAtIndex:0.

resources := page resources.
stdout println:resources.

stdout do println:content.

#stdout do println:pdf fonts each.
