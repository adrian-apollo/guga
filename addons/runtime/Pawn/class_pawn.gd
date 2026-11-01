@abstract
class_name CPawn
extends ComponentBase

var controller

@export_group( "Pawn" )
signal s_possessed( c:Controller )
signal s_unpossessed

@abstract func event_possessed( controller ) -> bool

@abstract func event_unpossessed( controller ) -> bool
