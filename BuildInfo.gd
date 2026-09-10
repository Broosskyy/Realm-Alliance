extends Node

const SOURCE_VERSION := "2.00"
const MASTER_CONCEPT := "V2.2"
const BUILD_CHANNEL := "prototype-test"
const BUILD_NUMBER := 200

func label() -> String:
	return "%s · Master %s · #%d" % [SOURCE_VERSION, MASTER_CONCEPT, BUILD_NUMBER]
