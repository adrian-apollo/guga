# GENERATED FILE - DO NOT EDIT.
# Created by the Gameplay Tags plugin every time tags are saved in 'Edit game tags'.
# Usage: GameTags.Character.Team.Alien (a tag with children exposes its own name as .TAG)
class_name GameTags
extends RefCounted

class entity:
	const TAG := "entity"

	class machine:
		const TAG := "entity.machine"

		class spaceship:
			const TAG := "entity.machine.spaceship"
			const alien := "entity.machine.spaceship.alien"
			const human := "entity.machine.spaceship.human"
