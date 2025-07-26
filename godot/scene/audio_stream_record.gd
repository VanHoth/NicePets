extends Control


var effect
var recording
var http_request = null
@onready var record_button: TextureButton = $RecordButton
@onready var text_edit: TextEdit = $TextEdit


func _ready():
		# 初始化HTTP请求对象
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)
	
	text_edit.text_changed.connect(_on_text_set)
	
	# We get the index of the "Record" bus.
	var idx = AudioServer.get_bus_index("Record")
	# And use it to retrieve its first effect, which has been defined
	# as an "AudioEffectRecord" resource.
	effect = AudioServer.get_bus_effect(idx, 0)
	record_button.button_down.connect(_on_record_button_pressed)
	record_button.button_up.connect(_on_record_button_pressed)

func _on_text_set():
	var inputText = text_edit.text;
	if inputText.contains("\n") :
		print("print: " + text_edit.text.replace("\n", ""))
		time = Time.get_ticks_msec();
		$VoiceSystem.send_chat_message(text_edit.text.replace("\n", ""))
		text_edit.text =""
		
	
	
	pass;
	
func _on_record_button_pressed():
	if effect.is_recording_active():
		recording = effect.get_recording()
		effect.set_recording_active(false)
		$Status.visible = false;
		_on_save_button_pressed();
		#_on_play_button_pressed();
	else:
		effect.set_recording_active(true)
		$Status.visible = true;



func _on_play_button_pressed():
	print(recording)
	print(recording.format)
	print(recording.mix_rate)
	print(recording.stereo)
	var data = recording.get_data()
	print(data.size())
	$AudioStreamPlayer.stream =recording
	$AudioStreamPlayer.play()
	
func read_wav_to_base64(file_path: String) -> String:
	# 打开文件（二进制只读模式）
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		# 打开失败，打印错误信息
		print("文件打开失败: ", FileAccess.get_open_error())
		return "";
	
	# 读取全部二进制数据（返回PoolByteArray）

	var base_64_data = Marshalls.raw_to_base64(file.get_buffer(file.get_length()))
	# 转换为Base64字符串
	return base_64_data

var time = 0;
func _on_save_button_pressed():
	time = Time.get_ticks_msec()
	var save_path = "user://voice.wav"


	recording.save_to_wav(save_path)

	
	
	
	# 填入控制台获取的app id和access token
	var appid = "4227257185"
	var token = "ZPVe6eOaTp6i_XlbM2sPE90MTsmd9Bh_"
	
	var headers = [
		"X-Api-App-Key:"+ appid,
		"X-Api-Access-Key:"+ token,
		"X-Api-Resource-Id:volc.bigasr.auc_turbo",
		"X-Api-Request-Id:"+"67ee89ba-7050-4c04-a3d7-ac61a63499b3",
		"X-Api-Sequence: -1"
	]
	
	var request_data = {
		"user": {
			"uid": appid
		},
		
		#"audio": {"url": "https://file.uhsea.com/2507/ff2392692d6361433e1930a5b95dc1e4ZB.wav"},
		"audio":{
			"data":read_wav_to_base64("user://voice.wav"),
			"format":"wav",
			},
		"request": {
			"model_name": "bigmodel",
			# "enable_itn": True,
			# "enable_punc": True,
			# "enable_ddc": True,
			# "enable_speaker_info": False,

		},
	}
	var API_URL = "https://openspeech.bytedance.com/api/v3/auc/bigmodel/recognize/flash";

	var error = http_request.request(API_URL, headers, HTTPClient.METHOD_POST,  JSON.stringify(request_data))
	if error != OK:
		emit_signal("request_completed", false, "请求发送失败，错误码: " + str(error))
		return
	
	# 连接HTTP请求完成信号
	print("send")
	

	
	#recording.save_to_wav(save_path)
	


func _on_http_request_completed(result, response_code, headers, body):
	print("get response")
	if result != HTTPRequest.RESULT_SUCCESS:
		print("HTTP请求失败，结果码: " + str(result))
		return
	
	if response_code != 200:
		print("API返回错误，状态码: " + str(response_code),body)
		return
	
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()


	#print(response)
	var text = response.result.text
	STTTime = Time.get_ticks_msec() - time
	print('---语音转文字处理成功--- :',STTTime)
	print(text)
	$VoiceSystem.send_chat_message(text)
	
var STTTime = 0;
func Finish(text: String):
	var Alltime = Time.get_ticks_msec() - time;
	var SpeckTime = Alltime - STTTime;
	print("AllTime:",Alltime,"|TextTime:",SpeckTime)
	pass
	
