@abstract
class_name CPawn
extends ComponentBase

@export_group( "Pawn" )
signal s_possessed( c:Controller )
signal s_unpossessed

var controller:Controller

@abstract func event_possessed( c )

@abstract func event_unpossessed()
