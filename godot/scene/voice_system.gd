extends Node



# 声明信号用于流式接收回复
signal response_received(text: String)
signal request_completed(success: bool, error_msg: String )
signal usage_updated(usage: Dictionary)

# API配置
const API_URL = "https://ark.cn-beijing.volces.com/api/v3/bots/chat/completions"
const MODEL_ID = "bot-20250726145837-m29fz"

var api_key = "a30a9d05-be7a-47e1-8259-28b513b349ee"
var http_request = null


@onready var emoji: AnimatedSprite2D = $"../../../Body/Emoji"
@onready var body: Cat = $"../../../Body"


func _ready():
	# 初始化HTTP请求对象
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)
	
	

func send_chat_message(user_message: String):
	print('开始处理文本:'+user_message)
	if api_key.is_empty():
		emit_signal("request_completed", false, "API密钥未设置")
		return

	
	# 构建请求数据
	var request_data = {
		"model": MODEL_ID,
		"stream":false,
		"stream_options": {"include_usage": false},
		"messages": [
	 		{"role": "system","content":""},
			{"role": "user", "content": user_message}
		]
	}
	
	# 设置请求头
	var headers = [
		"Authorization: Bearer " + api_key,
		"Content-Type: application/json"
	]
	
	# 发送请求
	var error = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(request_data))
	if error != OK:
		emit_signal("request_completed", false, "请求发送失败，错误码: " + str(error))
		return
	
	# 连接HTTP请求完成信号
	print("send")


func _on_http_request_completed(result, response_code, headers, body):
	print("request")
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("request_completed", false, "HTTP请求失败，结果码: " + str(result))
		return
	
	if response_code != 200:
		emit_signal("request_completed", false, "API返回错误，状态码: " + str(response_code))
		return
	
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	var response_message= response.choices[0].message.content;


	var action = response_message.split(' ')
	

	var _movement = action[0]
	var emoji = action[1]
	var sound = action[2]
	changeEmoji(emoji)
	changeMovement(_movement)

	print(response_message)
	








func changeEmoji(index):
	print("match",index)
	match index:
		"20":
			emoji.visible = true;
			emoji.play("NoHobby")
			pass
		"21":
			emoji.visible = true;
			emoji.play("Happy")
			pass
		"22":
			emoji.visible = true;
			emoji.play("Sad")
			pass
		
	if emoji.visible:
		await get_tree().create_timer(2.5).timeout
		emoji.visible = false;
		pass
	
	
func changeMovement(index):
	print("match",index)
	match index:
		"10":
		
			pass
		"11":
			body.ToMove(body.food.global_position)
			pass
		"12":
			body.ToMove(body.mao_wo.global_position)
			pass
		"13":
			body.ToMove(body.mao_sha.global_position)
			pass
		"14":
			body.ToIdle()
			pass
		"15":
			body.ToIdle()
			pass		
		"16":
			body.ToMove(body.close.global_position)
			pass			
			

			
			
# 设置API密钥的方法
func set_api_key(key: String):
	api_key = key    
