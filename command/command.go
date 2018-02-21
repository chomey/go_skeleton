package command

import "net/http"

type Command func(w http.ResponseWriter, r *http.Request)

