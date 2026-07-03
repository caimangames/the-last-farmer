extends RefCounted
class_name InventorySlot
## A single inventory slot: an ItemData and its stacked amount.

var item: ItemData = null
var amount: int = 0


func is_empty() -> bool:
	return item == null or amount <= 0


func can_accept(other: ItemData) -> bool:
	if is_empty():
		return true
	return item == other and amount < item.max_stack


## Adds as much as fits and returns the leftover that didn't.
func add(other: ItemData, count: int) -> int:
	if not is_empty() and item != other:
		return count
	if is_empty():
		item = other
	var available: int = item.max_stack - amount
	var added: int = min(count, available)
	amount += added
	return count - added


func clear() -> void:
	item = null
	amount = 0
