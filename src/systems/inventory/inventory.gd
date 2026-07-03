extends RefCounted
class_name Inventory
## Contenedor de objetos con apilado automático.
##
## No es un nodo: es un objeto de datos que el jugador (u un cofre) posee.
## Emite a través del EventBus para que la UI se refresque sin acoplarse.

var slots: Array[InventorySlot] = []
var size: int = 24


func _init(slot_count: int = 24) -> void:
	size = slot_count
	for i in size:
		slots.append(InventorySlot.new())


## Añade objetos, apilando en slots existentes primero. Devuelve lo que NO cupo.
func add_item(item: ItemData, count: int) -> int:
	var remaining: int = count

	# 1) Rellenar pilas existentes del mismo objeto.
	for slot in slots:
		if remaining <= 0:
			break
		if not slot.is_empty() and slot.item == item:
			remaining = slot.add(item, remaining)

	# 2) Usar slots vacíos.
	for slot in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
			remaining = slot.add(item, remaining)

	if remaining < count:
		var added: int = count - remaining
		EventBus.item_collected.emit(item, added)
		EventBus.inventory_changed.emit()
	return remaining


## Quita objetos repartidos por varios slots. Devuelve true si había suficientes.
func remove_item(item: ItemData, count: int) -> bool:
	if count_of(item) < count:
		return false
	var remaining: int = count
	for slot in slots:
		if remaining <= 0:
			break
		if not slot.is_empty() and slot.item == item:
			var take: int = min(slot.amount, remaining)
			slot.amount -= take
			remaining -= take
			if slot.amount <= 0:
				slot.clear()
	EventBus.item_removed.emit(item, count)
	EventBus.inventory_changed.emit()
	return true


func count_of(item: ItemData) -> int:
	var total: int = 0
	for slot in slots:
		if not slot.is_empty() and slot.item == item:
			total += slot.amount
	return total


func has_item(item: ItemData, count: int = 1) -> bool:
	return count_of(item) >= count


# ---------------------------------------------------------------------------
# Guardado
# ---------------------------------------------------------------------------

func to_dict() -> Dictionary:
	var slot_data: Array = []
	for slot in slots:
		if slot.is_empty():
			slot_data.append(null)
		else:
			slot_data.append({"item_id": str(slot.item.id), "amount": slot.amount})
	return {"slots": slot_data}


func from_dict(data: Dictionary) -> void:
	var slot_data: Array = data.get("slots", [])
	for i in size:
		var slot: InventorySlot = slots[i]
		slot.clear()
		if i >= slot_data.size():
			continue
		var entry: Variant = slot_data[i]
		if entry == null:
			continue
		var item: ItemData = ItemDatabase.get_item(StringName(entry.get("item_id", "")))
		if item != null:
			slot.item = item
			slot.amount = entry.get("amount", 0)
	EventBus.inventory_changed.emit()
