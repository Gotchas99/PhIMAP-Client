Class {
	#name : #IMAPFolder,
	#superclass : #Object,
	#instVars : [
		'name',
		'permissions',
		'numMsgs',
		'numRecent',
		'numUnseen',
		'uidValidity',
		'uidNext',
		'flags',
		'permFlags'
	],
	#category : #'IMAP-Client-Core'
}

{ #category : #accessing }
IMAPFolder >> flags [
	^flags
]

{ #category : #accessing }
IMAPFolder >> flags: anObject [
	flags := anObject
]

{ #category : #accessing }
IMAPFolder >> name [
	^name
]

{ #category : #accessing }
IMAPFolder >> name: anObject [
	name := anObject
]

{ #category : #accessing }
IMAPFolder >> numMsgs [
	^numMsgs
]

{ #category : #accessing }
IMAPFolder >> numMsgs: anObject [
	numMsgs := anObject
]

{ #category : #accessing }
IMAPFolder >> numRecent [
	^numRecent
]

{ #category : #accessing }
IMAPFolder >> numRecent: anObject [
	numRecent := anObject
]

{ #category : #accessing }
IMAPFolder >> numUnseen [
	^numUnseen
]

{ #category : #accessing }
IMAPFolder >> numUnseen: anObject [
	numUnseen := anObject
]

{ #category : #accessing }
IMAPFolder >> permFlags [
	^permFlags
]

{ #category : #accessing }
IMAPFolder >> permFlags: anObject [
	permFlags := anObject
]

{ #category : #accessing }
IMAPFolder >> permissions [
	^permissions
]

{ #category : #accessing }
IMAPFolder >> permissions: anObject [
	permissions := anObject
]

{ #category : #accessing }
IMAPFolder >> uidNext [
	^ uidNext
]

{ #category : #accessing }
IMAPFolder >> uidNext: anObject [
	uidNext := anObject
]

{ #category : #accessing }
IMAPFolder >> uidValidity [
	^uidValidity
]

{ #category : #accessing }
IMAPFolder >> uidValidity: anObject [
	uidValidity := anObject
]
