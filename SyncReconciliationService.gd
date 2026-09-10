extends Node

signal sync_state_changed(state: String)
signal sync_envelope_staged(revision: int)
signal sync_envelope_applied(revision: int)

const CONTRACT_VERSION := "sync-reconciliation-v2"
var last_accepted_revision: int = 0
var last_sync_unix: int = 0
var last_remote_fingerprint: String = ""
var staged_envelope: Dictionary = {}

func begin_sync_request() -> Dictionary:
	OnlineSessionState.set_state(OnlineSessionState.SYNCING)
	sync_state_changed.emit("syncing")
	return PlayerSnapshotService.build_sync_request()

func inspect_remote_envelope(envelope: Dictionary) -> Dictionary:
	var validation := PlayerSnapshotService.validate_remote_envelope(envelope)
	if not bool(validation.get("ok",false)):
		return validation
	var remote_snapshot = envelope.get("snapshot",{})
	if typeof(remote_snapshot) != TYPE_DICTIONARY:
		return {"ok":false,"error_code":"MISSING_SNAPSHOT"}
	var normalized := PlayerSnapshotService.normalize_remote_snapshot(remote_snapshot)
	if not bool(normalized.get("ok",false)):
		return normalized
	var remote_revision := int(envelope.get("revision",0))
	var local_revision := OnlineAuthorityService.server_revision
	var relation := "equal" if remote_revision == local_revision else "remote_newer"
	return {
		"ok":true,
		"relation":relation,
		"remote_revision":remote_revision,
		"local_revision":local_revision,
		"pending_intents":OnlineAuthorityService.pending_intents.size(),
		"remote_fingerprint":PlayerSnapshotService.snapshot_fingerprint(remote_snapshot)
	}

func stage_remote_envelope(envelope: Dictionary) -> Dictionary:
	var inspected := inspect_remote_envelope(envelope)
	if not bool(inspected.get("ok",false)):
		OnlineSessionState.set_state(OnlineSessionState.OFFLINE_LIMITED)
		sync_state_changed.emit("rejected")
		return inspected
	staged_envelope = envelope.duplicate(true)
	var revision := int(envelope.get("revision",0))
	OnlineSessionState.set_state(OnlineSessionState.SYNCING)
	sync_state_changed.emit("staged")
	sync_envelope_staged.emit(revision)
	return {"ok":true,"revision":revision,"ready_to_apply":true}

func apply_staged_envelope() -> Dictionary:
	if staged_envelope.is_empty():
		return {"ok":false,"error_code":"NO_STAGED_ENVELOPE"}
	var revision := int(staged_envelope.get("revision",0))
	var server_unix := int(staged_envelope.get("server_unix",0))
	var snapshot: Dictionary = staged_envelope.get("snapshot",{})
	var applied := RemoteStateApplyService.apply_snapshot(snapshot,revision)
	if not bool(applied.get("ok",false)):
		OnlineSessionState.set_state(OnlineSessionState.OFFLINE_LIMITED)
		sync_state_changed.emit("apply_failed")
		return applied

	# Authority metadata advances only after domain state applied successfully.
	OnlineAuthorityService.server_revision = revision
	OnlineAuthorityService.last_server_unix = server_unix
	ServerClockService.sync_server_time(server_unix)
	last_accepted_revision = revision
	last_sync_unix = server_unix
	last_remote_fingerprint = PlayerSnapshotService.snapshot_fingerprint(snapshot)
	staged_envelope.clear()
	OnlineSessionState.set_state(OnlineSessionState.ONLINE)
	SaveGame.save_game()
	sync_state_changed.emit("applied")
	sync_envelope_applied.emit(revision)
	return {"ok":true,"revision":revision}

# Compatibility entry point: stage only, never silently mutates player state.
func accept_remote_metadata(envelope: Dictionary) -> Dictionary:
	return stage_remote_envelope(envelope)

func export_sync_state() -> Dictionary:
	return {
		"contract_version":CONTRACT_VERSION,
		"last_accepted_revision":last_accepted_revision,
		"last_sync_unix":last_sync_unix,
		"last_remote_fingerprint":last_remote_fingerprint
	}

func apply_sync_state(data: Dictionary) -> void:
	last_accepted_revision = maxi(int(data.get("last_accepted_revision",0)),0)
	last_sync_unix = maxi(int(data.get("last_sync_unix",0)),0)
	last_remote_fingerprint = str(data.get("last_remote_fingerprint",""))
	staged_envelope.clear()
