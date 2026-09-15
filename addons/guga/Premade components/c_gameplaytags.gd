extends ComponentBase
class_name CGamePlayTags

@export_group("Tags")
@export var tagslibrary:GamePlayTagsLibrary

var currenttags:PackedStringArray
var tagindex: Dictionary[String, PackedInt32Array]

#region component methods

func _begin( ) -> void:
	for t in tagslibrary.tags:
		currenttags.push_back( t )
		
	updatetagindex()
	
#endregion

func updatetagindex() -> void:	#indexes tags from the dictionary for easy management
	#get row from currenttags
	if !tagindex.is_empty():
		tagindex.clear()
	for row in currenttags:
		#split that row
		var rowtags:PackedStringArray = row.split( ".", false )
		#run trough all tags
		for tag in rowtags:
			#check if it exists on the index and update if true, create index if not
			if tagindex.get(tag):
				var indexes:PackedInt32Array = tagindex.get(tag)
				indexes.push_back( currenttags.find( row ) )
				tagindex[tag] = indexes
			else:
				tagindex[tag] = [currenttags.find( row )]

#func removetags( tag:String ) -> void:
	#tags.rfind( tag ) )
	#for t in tags:
		#var row:Array = t.split( ".", false )
		#print( row )

func hastag( data:Array ) -> void:
	tagindex.has(data[1])
	MailServer.sendmessage.emit(data[0], "_receivedata", [ tagindex.has( data[1] ) ])

func hasalltags( data:Array ) -> void:
	tagindex.has_all( data[1] )
	MailServer.sendmessage.emit( data[0], "_receivedata", [ tagindex.has_all( data[1]) ])

func hasanytag( data:Array ) -> void:
	var test:bool = false
	for i in data[1]:
		if tagindex.keys().has(i):
			test = true
			MailServer.sendmessage.emit( data[0], "_receivedata", [test] )
			break
	MailServer.sendmessage.emit( data[0], "_receivedata", [test] )

func removetags( data:Array ) -> void:
	var founded:Array
	for i in data[1]:
		founded = tagindex.get( i )
		#print ( founded )
		currenttags.remove_at(founded[0])
		updatetagindex()

func getalltags( data:Array ) -> void:
	MailServer.sendmessage.emit( data[0], "_receivedata", [ tagindex.keys() ])
