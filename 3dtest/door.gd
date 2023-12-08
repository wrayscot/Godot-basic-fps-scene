extends CSGBox3D

@export var startingPos = 0.0
var currentlyOpen = false
var openingRate = .2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if currentlyOpen:
		if position.y <= startingPos + 3:
			position.y = lerp(position.y, startingPos+3, openingRate)
	else:
		if position.y != startingPos:
			position.y = lerp(position.y, startingPos, openingRate)

func open():
	currentlyOpen = true
	print("open")

func close():
	currentlyOpen = false
	print("close")
	
