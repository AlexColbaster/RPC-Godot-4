extends Node


func _ready():
	if "--server" in OS.get_cmdline_args():
		print('Server started')
		server_init()
	else: client_init()

var multiplayer_peer = ENetMultiplayerPeer.new()
const PORT = 9000 # любой порт
const ADDRESS = "127.0.0.1" # адрес, по которому компьютер может обратиться к самому себе

func server_init():
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer

var time = 0
func client_init():
	multiplayer_peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	$MyID.text = "Player id: "+str(multiplayer.get_unique_id())
	var timer = Timer.new()
	add_child(timer)
	timer.start(0.5)
	# присоединить к таймеру функцию, делающую запрос на пинг
	timer.connect("timeout", 
		func():
			# зафиксировать момент времени, в который отправлен запрос
			time = Time.get_ticks_msec()
			# отправить запрос на сервер 
			# ID сервера всегда = 1
			# ask_ping_server -- моя функция, которую я объявлю ниже
			# multiplayer.get_unique_id() -- аргумент, с которым вызовется ask_ping_server
			rpc_id(1, "ask_ping_server", multiplayer.get_unique_id())
	)

@rpc("any_peer", "unreliable", "call_local")
func ask_ping_server(id_who_asked_ping):
	# отправить ответ клиенту
	rpc_id(id_who_asked_ping, "answer_ping_client")

@rpc("unreliable")
func answer_ping_client():
	# посчитать, сколько времени ушло на запрос туда-обратно
	$Ping.text = "Ping: "+str(Time.get_ticks_msec()-time)

func _process(delta):
	$Players.text = str(multiplayer.get_peers())




