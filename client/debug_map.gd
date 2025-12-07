extends MeshInstance3D

class_name DebugMap

func _init(collisionMap_: CollisionMap) -> void:
	var texture = preload("res://assets/debugtex.png")

	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	for i in collisionMap_.height:
		for j in collisionMap_.width:
			# Lower right triangle
			verts.push_back(Vector3(1.0, 0.0, 1.0))
			verts.push_back(Vector3(1.0, 0.0, 0.0))
			verts.push_back(Vector3(0.0, 0.0, 0.0))
			uvs.push_back(Vector2(1.0, 1.0))
			uvs.push_back(Vector2(1.0, 0.0))
			uvs.push_back(Vector2(0.0, 0.0))
			# Upper left triangle
			verts.push_back(Vector3(0.0, 0.0, 1.0))
			verts.push_back(Vector3(1.0, 0.0, 1.0))
			verts.push_back(Vector3(0.0, 0.0, 0.0))
			uvs.push_back(Vector2(0.0, 0.0))
			uvs.push_back(Vector2(0.0, 1.0))
			uvs.push_back(Vector2(1.0, 1.0))
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts

	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh = arr_mesh
	#dvar mat = Material.new()
	#mat.albedo_texture = texture
	#set_surface_override_material(0, mat)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
