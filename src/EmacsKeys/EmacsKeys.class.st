"
I provide support for some Emacs like keys in text editing.

"
Class {
	#name : #EmacsKeys,
	#superclass : #Object,
	#category : #EmacsKeys
}

{ #category : #actions }
EmacsKeys class >> install [
	"Install Emacs keys"
	| installKey |
	installKey := [ :key :action :description |
		((KMBuilder keymap: #all) shortcut: action)
  			category: RubSmalltalkEditor name 
  			default: key 
			do: [ :target :morph :event | 
				 self perform: action withArguments: (Array with: target editor with: event) ]
			description: description
			].
			 
  installKey value: $a ctrl value: #moveBeginningOfLine:event: value: 'ctrl-a for beginning of line'.
  installKey value: $e ctrl value: #moveEndOfLine:event: value: 'ctrl-e for end of line'.
  installKey value: $k ctrl value: #killLine:event: value: 'ctrl-k to kill line'.
  installKey value: Character space meta value: #justOneSpace:event: value: 'meta-space to replace extra spaces'.


]

{ #category : #testing }
EmacsKeys class >> isWhitespaceCharacter: aCharacter [
	"check if character is whitespace but not cr"
	^ (aCharacter = Character space) | (aCharacter = Character tab)
]

{ #category : #editing }
EmacsKeys class >> justOneSpace: editor event: event [
	"Delete all spaces and tabs around caret, leaving only one space."
	| str c |
	str := editor string.
	c := editor caret.
	(self isWhitespaceCharacter: (str at: c-1)) |
	 (self isWhitespaceCharacter: (str at: c)) 
	ifFalse: [ editor addString: ' ' ]
	ifTrue: [ 
		| pos1 pos2 |
		pos1 := c-1.
		[ self isWhitespaceCharacter: (str at: pos1) ] whileTrue: [ pos1 := pos1 - 1 ].
		pos2 := c.
		[ self isWhitespaceCharacter: (str at: pos2) ] whileTrue: [ pos2 := pos2 + 1 ].
		 editor replaceTextFrom: pos1+1 to: pos2  with: ' '
	].

	editor unselect
]

{ #category : #editing }
EmacsKeys class >> killLine: editor event: event [
	"Kill the rest of the current line. If only whitespace, kills through newline."
	| str pos1 pos2 eol |
	str := editor string.
	pos1 := editor caret.
	pos2 := str indexOf: Character cr 
	            startingAt: pos1
					ifAbsent: str size.
	eol := str copyFrom: pos1 to: pos2.
	
	"if text to kill is only whitespace, kill through to next line"
	(eol reject: [ :c | ((c = Character space) | (c = Character tab)) not ]) isEmpty 
	ifTrue: [ pos2 := pos2 + 1 ]. 
	
   editor replaceTextFrom: pos1 to: pos2 with: ''. 
]

{ #category : #moving }
EmacsKeys class >> moveBeginningOfLine: editor event: event [
	| str |
	str := editor string.
	editor moveCursor: [:pos | 
		(str lastIndexOf: Character cr 
		     startingAt: (editor caret - 1)
		     ifAbsent: [ 0 ]) + 1 ]
	  forward: false 
	  specialBlock: [ :pos | pos ]
	  event: event. 
]

{ #category : #moving }
EmacsKeys class >> moveEndOfLine: editor event: event [
	| str |
	str := editor string.
	(editor caret < str size) ifTrue: [  
		(str at: editor caret) ~= Character cr ifTrue:[ 
			editor moveCursor: [:pos | 
			(str indexOf: Character cr 
		 	    startingAt: (editor caret + 1)
		  	   ifAbsent: [ str size + 1 ]) ]
	  		forward: true 
	  		specialBlock: [ :pos | pos ]
	  		event: event. 
	]]
]
