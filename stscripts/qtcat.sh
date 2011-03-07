#!/usr/local/bin/stsh
qtkit := NSBundle bundleWithPath:'/System/Library/Frameworks/QTKit.framework'.
qtkit load.
movieArgs := args subarrayWithRange:(1 to:args count-1).
movieArgs := movieArgs sortedArrayUsingSelector:'numericCompare:'.
movies:=QTMovie collect movieWithFile:movieArgs each error:nil.
firstMovie := movies objectAtIndex:0.
restMovies := movies subarrayWithRange:(1 to:movies count-1).
firstMovie setAttribute:1 forKey:'QTMovieEditableAttribute'.
ranges := restMovies collect movieAttributes collect objectForKey:'QTMovieActiveSegmentAttribute'.
0 to: restMovies count - 1 do: [ :i | (restMovies objectAtIndex:i) setSelection:(ranges objectAtIndex:i) ].
firstMovie do appendSelectionFromMovie:restMovies each.
outName := (movieArgs objectAtIndex:0) stringByDeletingPathExtension.
outName := outName stringByAppendingString:'-full.mov'.
outputAttributes := NSMutableDictionary dictionary.
#outputAttributes setObject:1 forKey:'QTMovieFlatten'.
firstMovie writeToFile:outName withAttributes:outputAttributes.
#NSFileManager defaultManager do removeFileAtPath:movieArgs each handler:nil.
