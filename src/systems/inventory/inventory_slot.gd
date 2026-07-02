extends RefCounted
class_name InventorySlot
## Un hueco del inventario: un ItemData y la cantidad apilada.

var item: ItemData = null
var amount: int = 0


func is_empty() -> bool:
	return item == null or amount <= 0


func can_accept(other: ItemData) -> bool:
	if is_empty():
		return true
	return item == other and amount < item.max_stack


## Añade cuanto quepa y devuelve el sobrante que no entró.
func add(other: ItemData, count: int) -> int:
	if is_empty():
		item = other
		var space: int = other.max_stack
		var added: int = min(count, space)
		amount = added
		return count - added
	if item != other:
		return count
	var space: int = item.max_stack - amount
	var added: int = min(count, space)
	amount += added
	return count - added


func clear() -> void:
	item = null
	amount = 0
