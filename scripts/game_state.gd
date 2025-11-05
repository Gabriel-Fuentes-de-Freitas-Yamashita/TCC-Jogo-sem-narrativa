extends Node

# Dicionário para armazenar o estado das portas.
# Chave: ID Único da porta (String, ex: "level1_door_a")
# Valor: Estado da porta (bool, true para aberta)
var door_states = {}

# Função para registrar que uma porta foi aberta
func open_door(door_id: String):
	door_states[door_id] = true
	print("Porta registrada como aberta globalmente: " + door_id)

# Função para verificar se uma porta deve estar aberta
func is_door_open(door_id: String) -> bool:
	# Retorna true se a chave existir E o valor for true. Senão, retorna false (o padrão).
	return door_states.get(door_id, false)
