extends Item

func use_item(target):
	if get_tree().get_nodes_in_group("reader").has(target):
		target.readkeycard(self)
