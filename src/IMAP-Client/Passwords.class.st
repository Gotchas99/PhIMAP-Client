Class {
	#name : #Passwords,
	#superclass : #Object,
	#instVars : [
		'dict'
	],
	#classVars : [
		'Current'
	],
	#category : #'IMAP-Client-Util'
}

{ #category : #'as yet unclassified' }
Passwords class >> clearPasswordFor: aString [
	^ self current clearPasswordFor: aString
]

{ #category : #'as yet unclassified' }
Passwords class >> current [
	Current ifNil: [Current := self new].
	^ Current
]

{ #category : #'as yet unclassified' }
Passwords class >> example [
	"
	Passwords example
	"
	| passwd |
	passwd := Passwords new.
	passwd for: 'test'.
	"shouldn't be asked this time"
	^ passwd for: 'test'
]

{ #category : #'as yet unclassified' }
Passwords class >> exists: aString [
	"
	Passwords exists: 'this is a test'
	"
	^ self current exists: aString
]

{ #category : #'as yet unclassified' }
Passwords class >> for: aString [
	"
	Passwords for: 'this is a test'
	"
	^ self current for: aString
]

{ #category : #'as yet unclassified' }
Passwords class >> for: aString ifNone: aBlock [
	"
	Passwords for: 'this is a test'
	"
	^ (self current exists: aString)
		ifTrue: [self current for: aString]
		ifFalse: [aBlock value]
]

{ #category : #'as yet unclassified' }
Passwords class >> shutDown [
	"Forget all cached passwords, so they won't stay in the image"

	self allSubInstancesDo: [:each | each dict: nil].
]

{ #category : #'as yet unclassified' }
Passwords >> clearPasswordFor: aString [
	^ self dict removeKey: aString
]

{ #category : #accessing }
Passwords >> dict [
	"Answer the value of dict"

	^ dict ifNil: [dict := Dictionary new]
]

{ #category : #accessing }
Passwords >> dict: anObject [
	"Set the value of dict"

	dict _ anObject
]

{ #category : #'as yet unclassified' }
Passwords >> exists: aString [
	^ (self dict at: aString ifAbsentPut: [#notThereAnywhere]) ~= #notThereAnywhere
]

{ #category : #'as yet unclassified' }
Passwords >> for: aString [
	^ self dict at: aString ifAbsentPut: [(FillInTheBlank request: 'Enter the password for ', aString)]
]
