Class {
	#name : #IMAPClient,
	#superclass : #TelnetProtocolClient,
	#instVars : [
		'pretag',
		'tagseq',
		'thistag',
		'state',
		'folders',
		'selectedBox',
		'fetchResults',
		'searchResults'
	],
	#category : #'IMAP-Client-Core'
}

{ #category : #'as yet unclassified' }
IMAPClient class >> defaultPortNumber [
	^ 143
]

{ #category : #commands }
IMAPClient >> append: aMailMessageOrString [
	| msg response |
	msg := (aMailMessageOrString isKindOf: String)
		ifTrue: [aMailMessageOrString]
		ifFalse: [aMailMessageOrString text].
	(msg includes: Character lf)
		ifFalse: [msg := (msg split: String cr) merge: String crlf].

	response := self sendCommandNoWait: 'append "Sent Messages" {', msg size asString, '}'.
	(Delay forMilliseconds: 100) wait.
"	response = 'OK' ifFalse: [self error: 'appending message failed (maybe mailbox doesn''t exist)']."
	response := self sendCommandNoBeginTag: msg.
	response = 'OK' ifFalse: [self error: 'appending message failed']
]

{ #category : #commands }
IMAPClient >> capability [
	^ self sendCommand: 'capability'
]

{ #category : #commands }
IMAPClient >> expunge [
	self sendCommand: 'expunge'.
	^ nil
]

{ #category : #commands }
IMAPClient >> fetch: aStringNumberOrCollection [
	| msgnums response index |
"	(aStringNumberOrCollection size = 1 and: [aStringNumberOrCollection first = 0])
		ifTrue: [^ OrderedCollection new].
"
	aStringNumberOrCollection ifEmpty: [^ OrderedCollection new].
	msgnums := ((aStringNumberOrCollection isKindOf: Collection)
				and: [(aStringNumberOrCollection isKindOf: String) not])
		ifTrue: [self msgNumsFromCollection: aStringNumberOrCollection]
		ifFalse: [aStringNumberOrCollection asString].
	response := self sendCommand: 'fetch ', msgnums, ' body[]'.
	response = 'OK' ifFalse: [self error: 'Fetch failed'].
	fetchResults := fetchResults collect:
		[:ea |
		index := ea indexOf: $}.
		ea copyFrom: index+1 to: ea size].
	^ fetchResults collect: [:ea | MailMessage from: ea]
]

{ #category : #commands }
IMAPClient >> forMessages: aStringNumberOrCollection addFlags: aCollection [
	| msgnums response |
	(aStringNumberOrCollection size = 1 and: [aStringNumberOrCollection first = 0])
		ifTrue: [^ OrderedCollection new].
	aStringNumberOrCollection ifEmpty: [^ OrderedCollection new].
	(aStringNumberOrCollection size > 100 and: [(aStringNumberOrCollection isKindOf: String) not]) ifTrue:
		[(self makeSetsOf100: aStringNumberOrCollection) do:
			[:set | self forMessages: set addFlags: aCollection].
		^ nil].
	msgnums := ((aStringNumberOrCollection isKindOf: Collection)
				and: [(aStringNumberOrCollection isKindOf: String) not])
		ifTrue: [self msgNumsFromCollection: aStringNumberOrCollection]
		ifFalse: [aStringNumberOrCollection asString].
	response := self sendCommand: 'store ', msgnums, ' +FLAGS (',(aCollection merge: ' '), ')'.
	response = 'OK' ifFalse: [self error: 'adding flag failed']
]

{ #category : #'initialize - release' }
IMAPClient >> initialize [
	pretag := 'EMAIL'.
	tagseq := 0.
	self port: self class defaultPortNumber.
	folders := Dictionary new
]

{ #category : #commands }
IMAPClient >> login [
	self show: 'IMAPClient>>login is not implemented'
]

{ #category : #commands }
IMAPClient >> login: hostString user: userString password: passwdString [
	| serverIP |
	serverIP := (hostString at: 1) isDigit
		ifTrue: [MyIP stringToBytes: hostString]
		ifFalse: [NetNameResolver addressForName: hostString timeout: 20].

	self openOnHost: serverIP port: self port.
	^ self sendCommand: 'login ', userString, ' ', passwdString
]

{ #category : #commands }
IMAPClient >> logout [
	^ self sendCommand: 'logout'
]

{ #category : #'send command' }
IMAPClient >> makeSetsOf100: aCollection [
	"
		change maxsetsize to 5
	IMAPClient new makeSetsOf100: #(1 2 3 4 5 6 7 8 9 10 11 12 13)
	"
	| sets origset maxsetsize |
	maxsetsize := 100.
	sets := OrderedCollection new.
	origset := aCollection.
	[origset notEmpty] whileTrue:
		[sets add: (origset copyFrom: 1 to: (maxsetsize min: origset size)).
		origset := origset size > maxsetsize
			ifTrue: [origset copyFrom: maxsetsize + 1 to: origset size]
			ifFalse: [OrderedCollection new]].
	^ sets
]

{ #category : #'send command' }
IMAPClient >> msgNumsFromCollection: aCollection [
	^ (aCollection collect: [:ea | ea asString]) merge: ','
]

{ #category : #'send command' }
IMAPClient >> nextTag [
	tagseq := tagseq + 1.
	thistag := pretag, tagseq asString, ' '.
	^ thistag
]

{ #category : #commands }
IMAPClient >> noop [
	^ self sendCommand: 'noop'
]

{ #category : #'process response' }
IMAPClient >> processFetch: aString [
	| index length result |
	index := aString indexOf: ${.
	index ~= 0
		ifFalse:
			[result := '']
		ifTrue:
			[length := (aString copyFrom: index + 1 to: aString size - 1) asNumber.
			result := self stream next: length.
"self show: '<<<<<<<<',result,'>>>>>>>>>'."
			self stream nextLine  "should be the ')' line"].
	fetchResults add: aString, result
]

{ #category : #'process response' }
IMAPClient >> processFlagsLine: aString [
	selectedBox flags: (aString findBetweenSubstrings: ' ')
]

{ #category : #'process response' }
IMAPClient >> processLogout [
	self show: 'Logged out'.
	state := #loggedOut
]

{ #category : #'process response' }
IMAPClient >> processNonTaggedLine: aString [
	| front low items |
	aString size < 4 ifTrue: [self error: 'string too small']. 
	" Transcript show: 'string too small <', aString, '>'; cr. ^ nil]."
	Transcript show: aString; cr.
	low := aString asLowercase.
	front := low copyFrom: 1 to: 4.
	front = '* ok' ifTrue: [^ self processOkLine: (aString copyFrom: 7 to: aString size - 1)].
	front = '* fl' ifTrue: [^ self processFlagsLine: (aString copyFrom: 10 to: aString size - 1)].
	front = '* by' ifTrue: [^ self processLogout].
	(low includesSubstring: 'expunge') ifTrue: [^ 'expunge'].
	front = '* se' ifTrue: [^ self processSearch:
		(aString size > 9
			ifTrue: [(aString copyFrom: 10 to: aString size)]
			ifFalse: [''])].
	items := low findBetweenSubstrings: ' '.
	(items last = 'exists') ifTrue: [^ selectedBox numMsgs: (items at: items size - 1) asNumber].
	(items last = 'recent') ifTrue: [^ selectedBox numRecent: (items at: items size - 1) asNumber].
	(items third = 'fetch') ifTrue: [^ self processFetch: aString].
	self unknown: 'unknown imap command' line: aString
]

{ #category : #'process response' }
IMAPClient >> processOkLine: aString [
	| low front |
	low := aString asLowercase.
	front := low copyFrom: 1 to: 4.
	front = 'perm' ifTrue: [^ selectedBox permFlags: ((aString copyFrom: 16 to: aString size -1) findBetweenSubstrings: ' ')].
	front = 'unse' ifTrue: [^ selectedBox numUnseen: (aString copyFrom: 8 to: aString size) asNumber].
	front = 'uidv' ifTrue: [^ selectedBox uidValidity: (aString copyFrom: 13 to: aString size) asNumber].
	front = 'uidn' ifTrue: [^ selectedBox uidNext: (aString copyFrom: 9 to: aString size) asNumber].
	self unknown: 'unknown imap ok command' line: aString
]

{ #category : #'process response' }
IMAPClient >> processSearch: aString [
	searchResults := aString size = 0
		ifFalse: [(aString split: ' ') collect: [:ea | ea asNumber]]
		ifTrue: [OrderedCollection new]
]

{ #category : #'process response' }
IMAPClient >> processTaggedLine: aString [
	| items |
	lastResponse := aString.
	self show: '**** ', lastResponse.
	items := lastResponse findBetweenSubstrings: ' '.
	(items size = 4 and: [items third ~= 'LOGIN']) ifTrue: [selectedBox permissions: (items at: 3)].
	^ items at: 2
]

{ #category : #internal }
IMAPClient >> readResponse [
	| line |
	[true] whileTrue:
		[line := self stream nextLine.
		line := line trimmed.
		(line indexOfSubCollection: thistag) = 1
			ifTrue: [^ self processTaggedLine: line]
			ifFalse: [self processNonTaggedLine: line]]
]

{ #category : #commands }
IMAPClient >> remove: aStringNumberOrCollection [
	^ self forMessages: aStringNumberOrCollection addFlags: #('\Deleted')
]

{ #category : #commands }
IMAPClient >> search: aString [
	searchResults := nil.
	self sendCommand: 'search ', aString.
	^ searchResults
]

{ #category : #commands }
IMAPClient >> select: aString [
	| quotedboxname boxname |
	quotedboxname := (aString at: 1) = $"
		ifTrue: [aString]
		ifFalse: ['"', aString, '"'].
	boxname := quotedboxname copyFrom: 2 to: quotedboxname size - 1.
	selectedBox := folders at: boxname ifAbsentPut: [IMAPFolder new name: boxname].
	^ self sendCommand: 'select ', quotedboxname
]

{ #category : #acccessing }
IMAPClient >> selectedBox [
	^ selectedBox
]

{ #category : #'send command' }
IMAPClient >> sendCommand: aString [
	"could raise ConnectionTimedOut error"
	self sendSuperCommand: (self nextTag, aString).
	fetchResults := OrderedCollection new.
	^ self readResponse
]

{ #category : #'send command' }
IMAPClient >> sendCommandNoBeginTag: aString [
	"could raise ConnectionTimedOut error"
	self sendSuperCommand: aString.
	fetchResults := OrderedCollection new.
	^ self readResponse
]

{ #category : #'send command' }
IMAPClient >> sendCommandNoWait: aString [
	"could raise ConnectionTimedOut error"
	self sendSuperCommand: (self nextTag, aString).
	fetchResults := OrderedCollection new
]

{ #category : #'send command' }
IMAPClient >> sendNoWait: aString [
	"could raise ConnectionTimedOut error"
	self sendSuperCommand: aString.
	fetchResults := OrderedCollection new
]

{ #category : #'send command' }
IMAPClient >> sendSuperCommand: aString [
	Transcript show: aString asString; cr.
	super sendCommand: aString
]

{ #category : #internal }
IMAPClient >> show: aString [
	Transcript show: aString asString; cr
]

{ #category : #'process response' }
IMAPClient >> unknown: infoString line: lineString [
	self show: '^^^^^^^   ', infoString, ': <', lineString, '>'
]
