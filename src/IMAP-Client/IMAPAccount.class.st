Class {
	#name : #IMAPAccount,
	#superclass : #Object,
	#instVars : [
		'client',
		'server',
		'port',
		'emailAddr',
		'username',
		'password',
		'lastFetchedNum'
	],
	#category : #'IMAP-Client-Core'
}

{ #category : #'instance creation' }
IMAPAccount class >> server: serverString emailAddr: emailString username: userString password: passwordString [
	^ self new
		server: serverString;
		emailAddr: emailString;
		username: userString;
		password: passwordString
]

{ #category : #'instance creation' }
IMAPAccount class >> server: serverString port: portInteger emailAddr: emailString username: userString password: passwordString [
	^ self new
		server: serverString;
		port: portInteger;
		emailAddr: emailString;
		username: userString;
		password: passwordString
]

{ #category : #'instance creation' }
IMAPAccount class >> server: serverString username: userString password: passwordString [
	^ self new
		server: serverString;
		username: userString;
		password: passwordString
]

{ #category : #'as yet unclassified' }
IMAPAccount >> alarmOnNewMessageIterations: iterationInteger withSecondDelay: secondDelay [
	self alarmOnNewMessageIterations: iterationInteger withSecondDelay: secondDelay then: []
]

{ #category : #'as yet unclassified' }
IMAPAccount >> alarmOnNewMessageIterations: iterationInteger withSecondDelay: secondDelay then: aBlock [
	"
	self alarmOnNewMessageIterations: 10 withSecondDelay: 90
	IMAPAccount macLocal alarmOnNewMessageIterations: 10 withSecondDelay: 90 then:
		[:e | e close]
	"
	| nummsgs newnummsgs |
	nummsgs := self client selectedBox numMsgs.
	[1 to: iterationInteger do:
		[:n |
		self client noop.
		newnummsgs := client selectedBox numMsgs.
		nummsgs ~= client selectedBox numMsgs ifTrue:
			[AbstractSound busySignal: 3.
			Transcript cr; show: '************** new message in ', emailAddr asString; cr.
			nummsgs := newnummsgs].
		(Delay forSeconds: secondDelay) wait]] forkNamed: emailAddr asString, ' alarm'.
	aBlock value: self
]

{ #category : #'as yet unclassified' }
IMAPAccount >> append: aMailMessageOrString [
	self client append: aMailMessageOrString
]

{ #category : #accessing }
IMAPAccount >> client [
	(client isNil or: [client isConnected not]) ifTrue:
		[client := IMAPClient new.
		self login].
	^ client
]

{ #category : #accessing }
IMAPAccount >> client: anObject [
	"Set the value of client"

	client _ anObject
]

{ #category : #'as yet unclassified' }
IMAPAccount >> close [
	client ifNotNil: [client close]
]

{ #category : #'initialize-release' }
IMAPAccount >> defaultPort [
	^ 143
]

{ #category : #accessing }
IMAPAccount >> emailAddr [
	"Answer the value of emailAddr"

	^ emailAddr
]

{ #category : #accessing }
IMAPAccount >> emailAddr: anObject [
	"Set the value of emailAddr"

	emailAddr := anObject
]

{ #category : #fetching }
IMAPAccount >> expunge [
	^ self client expunge
]

{ #category : #fetching }
IMAPAccount >> fetchNew [
	| numMsgs msgs |
	self client noop.
	lastFetchedNum ifNil: [lastFetchedNum := client selectedBox numMsgs].
	numMsgs := client selectedBox numMsgs.
	lastFetchedNum < numMsgs ifFalse: [^ OrderedCollection new].
	msgs := client fetch: (lastFetchedNum + 1) asString , ':' , numMsgs asString.
	lastFetchedNum := numMsgs.
	^ msgs
]

{ #category : #'initialize-release' }
IMAPAccount >> initialize [
	super initialize.
	port := self defaultPort
]

{ #category : #accessing }
IMAPAccount >> login [
	| response |
	client ifNil: [^ self client].
	client port: port.
	response := client login: server user: username password: password.
	response = 'OK' ifFalse: [self error: 'Unable to log into IMAP'].
	self select: 'inbox'
]

{ #category : #accessing }
IMAPAccount >> logout [
	| response |
	client ifNil: [ ^ self client ].
	response := client logout.
	response = 'OK'
		ifFalse: [ self error: 'Unable to log out of IMAP' ]
]

{ #category : #accessing }
IMAPAccount >> password [
	"Answer the value of password"

	^ password
]

{ #category : #accessing }
IMAPAccount >> password: anObject [
	"Set the value of password"

	password := anObject
]

{ #category : #accessing }
IMAPAccount >> port [
	"Answer the value of port"

	^ port
]

{ #category : #accessing }
IMAPAccount >> port: anObject [
	"Set the value of port"

	port _ anObject
]

{ #category : #accessing }
IMAPAccount >> search: aString [
	^ self client search: aString
]

{ #category : #accessing }
IMAPAccount >> searchAndFetch: aString [
	^ self client fetch: (client search: aString)
]

{ #category : #accessing }
IMAPAccount >> searchAndFetchExample [
	"
	IMAPAccount eastBmd searchAndFetchExample
	"
	| imap selected |
	imap := IMAPAccount eastBmd.
	selected := imap searchAndFetch: 'subject "[bbb exer 1.1x, iter 1]" from "watch.officer"'.
	imap close.
	^ selected
]

{ #category : #accessing }
IMAPAccount >> searchAndRemove: aString [
	^ self client remove: (client search: aString)
]

{ #category : #fetching }
IMAPAccount >> select: aString [
	| answer |
	answer := self client select: aString.
	lastFetchedNum := client selectedBox numMsgs.
	^ answer
]

{ #category : #accessing }
IMAPAccount >> server [
	"Answer the value of server"

	^ server
]

{ #category : #accessing }
IMAPAccount >> server: anObject [
	"Set the value of server"

	server := anObject
]

{ #category : #'as yet unclassified' }
IMAPAccount >> serverString [
	^ server, ':', port asString
]

{ #category : #accessing }
IMAPAccount >> username [
	"Answer the value of username"

	^ username
]

{ #category : #accessing }
IMAPAccount >> username: anObject [
	"Set the value of username"

	username := anObject
]
