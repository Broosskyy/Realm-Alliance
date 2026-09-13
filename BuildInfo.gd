extends Node



const SOURCE_VERSION := "2.09.2"

const MASTER_CONCEPT := "V2.2"

const BUILD_CHANNEL := "prototype-test"

const BUILD_NUMBER := 2092



func label() -> String:

	return "%s · Master %s · #%d" % [SOURCE_VERSION, MASTER_CONCEPT, BUILD_NUMBER]
