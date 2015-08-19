Class {
	#name : #SMTPAccount,
	#superclass : #Object,
	#instVars : [
		'client',
		'server',
		'port',
		'fullname',
		'emailAddr',
		'username',
		'password'
	],
	#category : #'IMAP-Client-SMTP'
}

{ #category : #'instance creation' }
SMTPAccount class >> server: serverString emailAddr: emailAddrString [
	^ self server: serverString fullname: nil emailAddr: emailAddrString username: nil password: nil
]

{ #category : #'instance creation' }
SMTPAccount class >> server: serverString emailAddr: emailAddrString username: usernameString password: passwordString [
	^ self server: serverString fullname: nil emailAddr: emailAddrString username: usernameString password: passwordString
]

{ #category : #'instance creation' }
SMTPAccount class >> server: serverString fullname: nameString emailAddr: emailAddrString username: usernameString password: passwordString [
	^ self new
		server: serverString;
		fullname: nameString;
		emailAddr: emailAddrString;	
		username: usernameString;
		password: passwordString
]

{ #category : #'instance creation' }
SMTPAccount class >> server: serverString port: portInteger emailAddr: emailAddrString username: usernameString password: passwordString [
	^ (self server: serverString fullname: nil emailAddr: emailAddrString username: usernameString password: passwordString) port: portInteger
]

{ #category : #mail }
SMTPAccount >> cleanMail: aMailMessageOrString from: fromString to: toStringOrCollection [
	| msg from to |
	msg := (aMailMessageOrString isKindOf: MailMessage)
		ifTrue: [aMailMessageOrString]
		ifFalse:
			[((aMailMessageOrString includesSubString: String cr, String cr) or: [aMailMessageOrString includesSubString: String crlf, String crlf])
				ifTrue: [MailMessage from: aMailMessageOrString]
				ifFalse: [MailMessage from: String cr, aMailMessageOrString]].
	from := fromString ifNil: [emailAddr ifNil: [msg fieldNamed: 'from' ifAbsent: []]].
	to := toStringOrCollection ifNil: [msg fieldNamed: 'to' ifAbsent: []].
	msg cleanMessageFromAddr: from toAddr: to.
	^ {msg. from. to}
]

{ #category : #mail }
SMTPAccount >> client [
	client ifNil:
		[client := SMTPClient openOnHostNamed: server port: self port.
		username ifNotNil:
			[client
				user: username;
				password: password;
				login]].
	client ensureConnection.
	^ client
]

{ #category : #mail }
SMTPAccount >> close [
	(client notNil and: [client isConnected]) ifTrue:
		[client quit.
		client close].
	client := nil
]

{ #category : #'initialize-release' }
SMTPAccount >> defaultPort [
	^ 25
]

{ #category : #accessing }
SMTPAccount >> emailAddr [
	"Answer the value of emailAddr"

	^ emailAddr
]

{ #category : #accessing }
SMTPAccount >> emailAddr: anObject [
	"Set the value of emailAddr"

	emailAddr _ anObject
]

{ #category : #accessing }
SMTPAccount >> fullname [
	"Answer the value of fullname"

	^ fullname
]

{ #category : #accessing }
SMTPAccount >> fullname: anObject [
	"Set the value of fullname"

	fullname _ anObject
]

{ #category : #'initialize-release' }
SMTPAccount >> initialize [
	port := self defaultPort.
	fullname := nil
]

{ #category : #mail }
SMTPAccount >> mail: aMailMessageOrString [
	^ self mail: aMailMessageOrString to: nil
]

{ #category : #mail }
SMTPAccount >> mail: aMailMessageOrString from: fromString to: toStringOrCollection [
	| answer msg from to |
	answer := self cleanMail: aMailMessageOrString from: fromString to: toStringOrCollection.
	msg := answer first.
	from := answer second.
	to := answer third.
	self client
		mailFrom: from
		to: (self makeRecipientList: to)
		text: msg text "asSendableText".
	^ msg
]

{ #category : #mail }
SMTPAccount >> mail: aMailMessageOrString to: toStringOrCollection [
	^ self mail: aMailMessageOrString from: emailAddr to: toStringOrCollection
]

{ #category : #mail }
SMTPAccount >> makeRecipientList: aStringOrCollection [
	| recipient |
	recipient := aStringOrCollection.
	(recipient isKindOf: MIMEHeaderValue) ifTrue:
		[recipient := recipient mainValue].
	^ (recipient isKindOf: String)
		ifTrue: [(recipient findTokens: $,) collect: [:ea | ea withBlanksTrimmed]]
		ifFalse: [recipient].

]

{ #category : #accessing }
SMTPAccount >> password [
	^password
]

{ #category : #accessing }
SMTPAccount >> password: anObject [
	password := anObject
]

{ #category : #accessing }
SMTPAccount >> port [
	^port
]

{ #category : #accessing }
SMTPAccount >> port: anObject [
	port := anObject
]

{ #category : #accessing }
SMTPAccount >> server [
	^server
]

{ #category : #accessing }
SMTPAccount >> server: anObject [
	server := anObject
]

{ #category : #accessing }
SMTPAccount >> username [
	^username
]

{ #category : #accessing }
SMTPAccount >> username: anObject [
	username := anObject
]
