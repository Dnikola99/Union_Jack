extends StateBase

func enter():
	super.enter()
	
	state_machine.get_parent().remove_from_group("Player")
	
	
