extends AnimatedSprite2D



class_name Cat

@onready var mao_wo: Node2D = $"../Pos/MaoWo"
@onready var mao_sha: Node2D = $"../Pos/MaoSha"
@onready var water: Node2D = $"../Pos/Water"

@onready var close: Node2D = $"../Pos/Close"
@onready var food: Node2D = $"../Pos/Food"

class StateMachine:
	var nowState;
	func ChangeState(state):
		if nowState !=null:
			nowState.exit();
		
		nowState = state;
		state.enter();
		pass
		
	func Physic_proccess(delta: float):
		if nowState !=null:
			nowState.physic_process(delta);
		pass
		
	func Process(delta: float):
		if nowState !=null:
			nowState.process(delta);
		pass
var stateMachine = StateMachine.new()

class Idle:
	var body;
	func _init(_bo) -> void:
		body = _bo;
		pass
	func enter():
		body.play("idle")
		pass

	func exit():
		pass
		
	func process(delta):
	
		pass
	
	func physic_process(delta):
		pass
	pass
	

class Move:
	var Pos:Vector2;
	var Speed = 30;
	var body:Cat;
	var stateMachin;
	var idle;
	func _init(a) -> void:
		body = a;
		pass
	func enter():
		body.play("move")
		pass

	func exit():
		pass
		
	func process(delta):

		#移动
		
		#插值运动
		
		#判断是否到位置了
		
		
		# 转为待机
		
		
		pass
	
	func physic_process(delta):
		var direction = (Pos - body.global_position).normalized()
		if body.global_position.distance_to(Pos) > 1.0:
			body.global_position += direction * Speed * delta
		else:
			body.global_position = Pos 
			body.ToIdle() # 精确到达目标位置
		pass
	pass

var idle = Idle.new(self);
var move = Move.new(self);
func _ready() -> void:
	pass

func ToIdle():
	stateMachine.ChangeState(idle)
	pass
	
func _physics_process(delta: float) -> void:
	stateMachine.Physic_proccess(delta)
	pass

func _process(delta: float) -> void:
	stateMachine.Process(delta)
	pass
