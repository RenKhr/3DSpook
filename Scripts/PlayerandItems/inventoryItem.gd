extends Item


func set_data(_name:String, _color:Color, _mesh:MeshInstance3D):
    self.item_name = _name
    self.color = _color
    self.mesh = _mesh