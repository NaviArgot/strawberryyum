extends Node3D

class_name DebugMap


func _init(gamemap) -> void:
	var texture = preload("res://assets/debugtex.png")

	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var divs = 2
	for cell in gamemap.get_used_cells():
		var coord = Vector3(cell.x, 0.0, cell.z)
		var uvori = Vector2(0.0, 0.0) if gamemap.getCellCollision(cell.x, cell.z) == 1 \
			else Vector2 (0.5, 0.0)
		# Lower right triangle
		verts.push_back(Vector3(0.0, 0.0, 0.0) + coord)
		verts.push_back(Vector3(1.0, 0.0, 0.0) + coord)
		verts.push_back(Vector3(1.0, 0.0, 1.0) + coord)
		uvs.push_back(Vector2(0.0, 0.0)/divs + uvori)
		uvs.push_back(Vector2(1.0, 0.0)/divs + uvori)
		uvs.push_back(Vector2(1.0, 1.0)/divs + uvori)
		# Upper left triangle
		verts.push_back(Vector3(0.0, 0.0, 0.0) + coord)
		verts.push_back(Vector3(1.0, 0.0, 1.0) + coord)
		verts.push_back(Vector3(0.0, 0.0, 1.0) + coord)
		uvs.push_back(Vector2(0.0, 1.0)/divs + uvori)
		uvs.push_back(Vector2(1.0, 0.0)/divs + uvori)
		uvs.push_back(Vector2(0.0, 0.0)/divs + uvori)
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_TEX_UV] = uvs

	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var meshInst = MeshInstance3D.new()
	meshInst.mesh = arr_mesh
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	mat.albedo_texture = texture
	meshInst.set_surface_override_material(0, mat)
	add_child(meshInst)
	#set_surface_override_material(0, mat)
	#scale = Vector3(4.0, 4.0, 4.0)
	position = Vector3(-0.5, -0.5, -0.5)
	#rotation.z = PI
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("MIAAAAAAAAAAU")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
