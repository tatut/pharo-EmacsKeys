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
		((KMBuilder keymap: #all) shortcut: #emacs)
  			category: RubSmalltalkEditor name 
  			default: key 
			do: [ :target :morph :event | 
				 self perform: action withArguments: (Array with: target editor with: event) ]
			description: description
			].
			 
  installKey value: $a ctrl value: #moveBeginningOfLine:event: value: 'ctrl-a for beginning of line'.
  installKey value: $e ctrl value: #moveEndOfLine:event: value: 'ctrl-e for end of line'.

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
	(str at: editor caret) ~= Character cr ifTrue:[ 
	editor moveCursor: [:pos | 
		(str indexOf: Character cr 
		     startingAt: (editor caret + 1)
		     ifAbsent: [ str size ]) ]
	  forward: true 
	  specialBlock: [ :pos | pos ]
	  event: event. 
	]
]
