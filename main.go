package main

import (
	"fmt"
	"github.com/op/go-logging"
	"net/http"
	"io/ioutil"
	"encoding/json"
	"github.com/chomey/go_skeleton/config"
	"github.com/gorilla/mux"
	"os"
	"errors"
	"github.com/chomey/go_skeleton/errorUtils"
)

const EnvironmentVariable = "ENVIRONMENT_VARIABLE"

var log = logging.MustGetLogger("go_skeleton")
var variables = make(map[string]string)

func main() {
	Config := loadConfig()
	fmt.Printf("Loading Config: %#v\n", Config)

	loadEnvironmentVariables()
	fmt.Printf("Loading Environment Variables: %#v\n", variables)

	m := setupMuxRouter()
	http.Handle("/", m)
	log.Infof("Now listening on http://localhost:%d\n", Config.Port)
	err := http.ListenAndServe(fmt.Sprintf(":%d", Config.Port), nil)
	errorUtils.Check(err)
}

func HandleRequest(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Hello World!")
}

func setupMuxRouter() *mux.Router {
	m := mux.NewRouter()
	//Register new handlers here
	m.PathPrefix("/").HandlerFunc(HandleRequest)
	return m
}

func loadConfig() config.Config {
	data, err := ioutil.ReadFile("config.json")
	errorUtils.Check(err)

	Config := new(config.Config)
	err = json.Unmarshal(data, &Config)
	errorUtils.Check(err)
	return *Config
}

func loadEnvironmentVariables() {
	checkIfSet(EnvironmentVariable)
}

func checkIfSet(environmentVariable string) {
	ev := os.Getenv(environmentVariable)
	if ev == "" {
		errorUtils.Check(errors.New(fmt.Sprintf("Environment variable '%s' is requried", environmentVariable)))
	}
	variables[environmentVariable] = ev
}
