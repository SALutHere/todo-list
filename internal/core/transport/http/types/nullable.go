package core_http_types

import (
	"encoding/json"

	"github.com/SALutHere/todo-list/internal/core/domain"
)

type Nullable[T any] struct {
	domain.Nullable[T]
}

func (n *Nullable[T]) UnmarshalJSON(b []byte) error {
	n.Set = true

	if string(b) == "null" {
		n.Value = nil

		return nil
	}

	var value T
	if err := json.Unmarshal(b, &value); err != nil {
		return err
	}

	n.Value = &value

	return nil
}

func (n *Nullable[T]) ToDomain() domain.Nullable[T] {
	return domain.Nullable[T]{
		Value: n.Value,
		Set:   n.Set,
	}
}

/*
-------------------

JSON: {}
Nullable[string]:
	- Value: *nil
	- Set: false

-------------------

JSON: {
	"phone_number": "+79998887766"
}
Nullable[string]:
	- Value: *"+79998887766"
	- Set: true

-------------------

JSON: {
	"phone_number": null
}
Nullable[string]:
	- Value: *nil
	- Set: true

-------------------
*/
