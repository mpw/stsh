#!/usr/bin/env stsh
pdfbundle := NSBundle bundleWithPath:'/Library/Frameworks/EGOS.framework'
pdfbundle load
args
filename := args objectAtIndex:0
stdout print: 'pdfdump of: '
stdout println: filename

data := NSData dataWithContentsOfMappedFile: filename
pdf := (MPWPDFFile alloc initWithPdfData:data ) autorelease
pdf parseXrefTables
pages := pdf pages
stdout writeObject: pages count
stdout println: ' pages'

stdout writeObject:pages

contentStreams := pages collect contentStreams
#allStreams := NSMutableArray array
#allStreams do addObjectsFromArray: contentStreams each
allStreams := contentStreams collect lastObject
allContent := allStreams collect stringValue
stdout writeObject: 'got allContent'
stdout writeNewline
stdout writeObject:allContent
