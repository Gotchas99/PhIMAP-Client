Extension { #name : #MailMessage }

{ #category : #'*IMAP-Client-model' }
MailMessage >> atFieldNamed: aString [
	^ (self fieldNamed: aString ifAbsent: [MIMEHeaderValue new]) mainValue
]

{ #category : #'*IMAP-Client-model' }
MailMessage >> atFieldNamed: nameString put: valueString [
	fields at: nameString asLowercase put:
		{(MIMEHeaderValue forField: nameString fromString: valueString)}

]

{ #category : #'*IMAP-Client-model' }
MailMessage >> atFieldsNamed: aString [
	^ (self fieldsNamed: aString ifAbsent: [{MIMEHeaderValue new}]) collect: [:ea | ea mainValue]
]

{ #category : #'*IMAP-Client-model' }
MailMessage >> cleanMessageFromAddr: fromString toAddr: toString [
	((self hasFieldNamed: 'date') not or: [(self atFieldNamed: 'date') size < 15])
		ifTrue: [self atFieldNamed: 'date' put: self dateToday].
	(self hasFieldNamed: 'from')
		ifFalse: [self atFieldNamed: 'from' put: fromString].
	(self hasFieldNamed: 'to')
		ifFalse: [self atFieldNamed: 'to' put: toString].
	(self hasFieldNamed: 'message-id')
		ifFalse: [self atFieldNamed: 'Message-id' put: self nextMessageId].
	(self hasFieldNamed: 'x-thread-id')
		ifFalse: [self atFieldNamed: 'Thread-index' put: self nextMessageId].
	(self hasFieldNamed: 'subject')
		ifFalse: [self atFieldNamed: 'subject' put: 'No subject ', (self atFieldNamed: 'message-id')].
	self regenerateText
]

{ #category : #'*IMAP-Client-model' }
MailMessage >> dateToday [
	"
	MailMessage new dateToday
	"
	^ ((Date today weekday) asString copyFrom: 1 to: 3), ', ', (Date today printFormat: #(1 2 3 $  2 1)), ' ', Time now print24, ' -0400 (EST)'


]

{ #category : #'*IMAP-Client-model' }
MailMessage >> nextMessageId [
	^ '<squeak:', UUID new asString, '>'
]

{ #category : #'*IMAP-Client-model' }
MailMessage >> regenerateTextWithLf [
	"regenerate the full text from the body and headers"
	| encodedBodyText |
	text := String streamContents: [ :str |
		"first put the header"
		fields keysAndValuesDo: [ :fieldName :fieldValues |
			fieldValues do: [ :fieldValue |
				str
					nextPutAll: fieldName capitalized ;
					nextPutAll: ': ';
					nextPutAll: fieldValue asHeaderValue;
					crlf ]. ].
	
		"skip a line between header and body"
		str crlf.

		"put the body, being sure to encode it according to the header"
		encodedBodyText := body content.
		self decoderClass ifNotNil: [
			encodedBodyText := (self decoderClass mimeEncode: (ReadStream on: encodedBodyText)) upToEnd ].
		str nextPutAll: encodedBodyText ].
]
