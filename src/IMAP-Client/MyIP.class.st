Class {
	#name : #MyIP,
	#superclass : #Object,
	#classVars : [
		'IpAddr'
	],
	#category : #'IMAP-Client-Util'
}

{ #category : #'as yet unclassified' }
MyIP class >> announce: aString [
	^ Announcer new internalInform: aString
]

{ #category : #'as yet unclassified' }
MyIP class >> bytesToString: anArray [
	"
	MyIP bytesToString: #(192 168 0 1)
		=> '192.168.0.1'
	"
	| out |
	out := WriteStream on: String new.
	(anArray asArray collect: [:n | n asString]) do: [:ea | out nextPutAll: ea] separatedBy: [out nextPutAll: '.'].
	^ out contents
]

{ #category : #'as yet unclassified' }
MyIP class >> defaultUrl [
	^ 'http://whatsmyip.net/'
"http://whatsmyip.smokingmedia.com/"
]

{ #category : #'as yet unclassified' }
MyIP class >> getMyIPAsString [
	"
	MyIP getMyIPAsString
	"
	| content start end |
	[content := self defaultUrl asUrl retrieveContents contents.
	start := content indexOfSubCollection: 'Your IP'.
	end := content indexOfSubCollection: '</TITLE>'.
	^ (start = 0 or: [end = 0])
		ifTrue: [nil]
		ifFalse: [content copyFrom: start + 9 to: end - 1]]

	on: Exception
	do: [^ 'could not retrieve ip address']
]

{ #category : #'as yet unclassified' }
MyIP class >> ipHasChanged [
	"
	MyIP ipHasChanged
	"
	self announce: 'ip address has changed to ', IpAddr asString
]

{ #category : #'as yet unclassified' }
MyIP class >> isIpAddrChanged [
	"
	MyIP isIpAddrChanged
	"
	| newipaddr |
	newipaddr := self getMyIPAsString.
	^ (IpAddr = newipaddr)
		ifTrue: [false]
		ifFalse: [IpAddr := newipaddr. true]
]

{ #category : #'as yet unclassified' }
MyIP class >> start [
	"
	MyIP start
	"
	(MyScheduler instance)
		removeTasksNamed: 'myip checker';
		add: (MyScheduleTask
			name: 'myip checker'
			block: [self isIpAddrChanged ifTrue: [self ipHasChanged]]
			frequency: 5 minutes)
]

{ #category : #'as yet unclassified' }
MyIP class >> stringToBytes: aString [
	"
	MyIP stringToBytes: '192.168.0.1'
	"
	^ ((aString findTokens: $.) collect: [:n | n asInteger]) asByteArray
]
