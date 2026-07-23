extends Node2D

# World used for physics casts
@onready var world: World2D = get_world_2d()

func point_cast(pos: Vector2, collision_mask: int,
exclude: Array, collide_with_areas: bool = true,
collide_with_bodies: bool = true, max_results: int = 32) -> Array[Dictionary]:
	var params: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collide_with_areas = collide_with_areas
	params.collide_with_bodies = collide_with_bodies
	params.collision_mask = collision_mask
	params.exclude = exclude
	
	var result: Array[Dictionary] = world.direct_space_state.intersect_point(params,
			max_results)
	return result

func circle_cast(pos: Vector2, radius: float, collision_mask: int,
exclude: Array, collide_with_areas: bool = true,
collide_with_bodies: bool = true, max_results: int = 32,
custom_world: World2D = world) -> Array[Dictionary]:
	var query_shape: CircleShape2D = CircleShape2D.new()
	query_shape.radius = radius
	
	return shape_cast(pos, 0, query_shape, collision_mask, exclude, collide_with_areas,
			collide_with_bodies, max_results, custom_world)

func box_cast(pos: Vector2, dangle: float, size: Vector2, collision_mask: int,
exclude: Array, collide_with_areas: bool = true,
collide_with_bodies: bool = true, max_results: int = 32) -> Array[Dictionary]:
	var query_shape: RectangleShape2D = RectangleShape2D.new()
	query_shape.size = size
	
	return shape_cast(pos, dangle, query_shape, collision_mask, exclude, collide_with_areas,
			collide_with_bodies, max_results)


func shape_cast(pos: Vector2, dangle: float, query_shape: Shape2D, collision_mask: int,
exclude: Array, collide_with_areas: bool = true,
collide_with_bodies: bool = true, max_results: int = 32,
custom_world: World2D = world) -> Array[Dictionary]:
	var avoidance_query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	avoidance_query.set_shape(query_shape)
	avoidance_query.collide_with_areas = collide_with_areas
	avoidance_query.collide_with_bodies = collide_with_bodies
	avoidance_query.collision_mask = collision_mask
	avoidance_query.transform = Transform2D(deg_to_rad(dangle), pos)
	avoidance_query.exclude = exclude
	
	var result: Array[Dictionary] = custom_world.direct_space_state \
			.intersect_shape(avoidance_query, max_results)
	return result
