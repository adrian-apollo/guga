class_name RRayData extends Resource

var raydata:Dictionary[String, Variant] = {
	"collider":null,
	"colliderid":null,
	"normal":null,
	"position":null,
	"rid":null,
	"shape":null,
	}

func update(data:Dictionary):
	raydata.collider = data.get( "collider" )
	raydata.colliderid = data.get( "collider_id")
	raydata.normal = data.get("normal")
	raydata.position = data.get("position")
	raydata.rid = data.get("rid")
	raydata.shape = data.get("shape")
