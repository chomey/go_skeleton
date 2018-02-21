package config

type Config struct {
	// Server Config
	Port int `json:"port"`

	//ConfigVariable
	ConfigVariable string `json:"configVariable"`
}
