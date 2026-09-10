extends Node

signal response_routed(route: String, request_id: String, handled: bool)
signal response_rejected(route: String, request_id: String, error_code: String)

const CONTRACT_VERSION := "response-router-v1"

func _ready() -> void:
	if not OnlineTransportService.request_completed.is_connected(_on_transport_response):
		OnlineTransportService.request_completed.connect(_on_transport_response)


func _route_path(key: String, default_path: String) -> String:
	return str(OnlineAuthorityService.config.get("routes", {}).get(key, default_path))

func _on_transport_response(request_id: String, response: Dictionary) -> void:
	var route := str(response.get("route",""))
	if not bool(response.get("ok",false)):
		_handle_transport_failure(route,request_id,response)
		return
	var body = response.get("body",{})
	if typeof(body) != TYPE_DICTIONARY:
		_reject(route,request_id,"MISSING_RESPONSE_BODY")
		return

	var handled := false
	if route == _route_path("session_guest", "/v1/session/guest"):
			handled = _route_session(body)
	if route == _route_path("session_refresh", "/v1/session/refresh"):
			handled = _route_session(body)
	if route == _route_path("player_sync", "/v1/player/sync"):
			handled = _route_sync(body)
	if route == _route_path("authority_intent", "/v1/game/intent"):
			handled = _route_authority(body)
	if route == _route_path("chat_snapshot", "/v1/chat/snapshot"):
			handled = OnlineChatService.accept_snapshot_envelope(body)
	if route == _route_path("chat_send", "/v1/chat/send"):
			handled = OnlineChatService.accept_action_envelope(body)
	if route == _route_path("chat_delete", "/v1/chat/delete"):
			handled = OnlineChatService.accept_action_envelope(body)
	if route == _route_path("presence_snapshot", "/v1/presence/snapshot"):
			handled = PresenceService.accept_snapshot_envelope(body)
	if route == _route_path("presence_update", "/v1/presence/update"):
			handled = PresenceService.accept_update_envelope(body)
	if route == _route_path("party_snapshot", "/v1/party/snapshot"):
			handled = PartyLobbyService.accept_party_envelope(body)
	if route == _route_path("party_create", "/v1/party/create"):
			handled = PartyLobbyService.accept_party_envelope(body)
	if route == _route_path("party_invite", "/v1/party/invite"):
			handled = PartyLobbyService.accept_party_envelope(body)
	if route == _route_path("party_join", "/v1/party/join"):
			handled = PartyLobbyService.accept_party_envelope(body)
	if route == _route_path("party_leave", "/v1/party/leave"):
			handled = PartyLobbyService.accept_leave_envelope(body)
	if route == _route_path("party_ready", "/v1/party/ready"):
			handled = PartyLobbyService.accept_party_envelope(body)
	if route == _route_path("server_inbox", "/v1/inbox"):
			handled = ServerInboxService.accept_inbox_envelope(body)
	if route == _route_path("server_inbox_read", "/v1/inbox/read"):
			handled = ServerInboxService.accept_action_envelope(body)
	if route == _route_path("server_inbox_ack", "/v1/inbox/ack"):
			handled = ServerInboxService.accept_action_envelope(body)
	if route == _route_path("deeplink_resolve", "/v1/deeplink/resolve"):
			handled = InviteDeepLinkService.accept_resolve_envelope(body)
	if route == _route_path("notification_sync", "/v1/notifications/sync"):
			handled = PushNotificationService.accept_sync_envelope(body)
	if route == _route_path("guild_search", "/v1/guild/search"):
			handled = GuildDiscoveryService.accept_search_envelope(body)
	if route == _route_path("guild_applications", "/v1/guild/applications"):
			handled = GuildDiscoveryService.accept_applications_envelope(body)
	if route == _route_path("guild_apply", "/v1/guild/apply"):
			handled = GuildDiscoveryService.accept_action_envelope(body)
	if route == _route_path("guild_application_action", "/v1/guild/application-action"):
			handled = GuildDiscoveryService.accept_action_envelope(body)
	if route == _route_path("guild_invites", "/v1/guild/invites"):
			handled = GuildDiscoveryService.accept_invites_envelope(body)
	if route == _route_path("guild_invite_send", "/v1/guild/invite"):
			handled = GuildDiscoveryService.accept_action_envelope(body)
	if route == _route_path("guild_invite_action", "/v1/guild/invite-action"):
			handled = GuildDiscoveryService.accept_action_envelope(body)
	if route == _route_path("social_block_list", "/v1/moderation/blocks"):
			handled = SocialModerationService.accept_block_list_envelope(body)
	if route == _route_path("social_block", "/v1/moderation/block"):
			handled = SocialModerationService.accept_action_envelope(body)
	if route == _route_path("social_unblock", "/v1/moderation/unblock"):
			handled = SocialModerationService.accept_action_envelope(body)
	if route == _route_path("social_report", "/v1/moderation/report"):
			handled = SocialModerationService.accept_action_envelope(body)
	if route == _route_path("push_register", "/v1/push/register"):
			handled = PushNotificationService.accept_registration_envelope(body)
	if route == _route_path("push_unregister", "/v1/push/unregister"):
			handled = PushNotificationService.accept_unregistration_envelope(body)
	if route == _route_path("push_preferences", "/v1/push/preferences"):
			handled = PushNotificationService.accept_preferences_envelope(body)
	if route == _route_path("season_reset_snapshot", "/v1/pvp/season/reset"):
			handled = SeasonResetService.accept_snapshot_envelope(body)
	if route == _route_path("season_reset_ack", "/v1/pvp/season/reset/ack"):
			handled = SeasonResetService.accept_ack_envelope(body)
	if route == _route_path("guild_donation_receipt", "/v1/guild/donation/receipt"):
			handled = GuildTaskService.accept_donation_receipt(body)
	if route == _route_path("guild_governance_snapshot", "/v1/guild/governance"):
			handled = GuildGovernanceService.accept_snapshot(body)
	if route == _route_path("guild_role_update", "/v1/guild/role-update"):
			handled = GuildGovernanceService.accept_role_update(body)
	if route == _route_path("guild_member_action", "/v1/guild/member-action"):
			handled = GuildGovernanceService.accept_member_action(body)
	if route == _route_path("guild_tasks_snapshot", "/v1/guild/tasks"):
			handled = GuildTaskService.accept_snapshot(body)
	if route == _route_path("guild_task_contribute", "/v1/guild/tasks/contribute"):
			handled = GuildTaskService.accept_contribution(body)
	if route == _route_path("guild_donation", "/v1/guild/donation"):
			handled = GuildTaskService.accept_donation(body)
	if route == _route_path("activity_feed", "/v1/activity/feed"):
			handled = OnlineActivityService.accept_activity_envelope(body)
	if route == _route_path("notifications_snapshot", "/v1/notifications"):
			handled = OnlineActivityService.accept_notifications_envelope(body)
	if route == _route_path("notification_mark_read", "/v1/notifications/read"):
			handled = OnlineActivityService.accept_mark_read_envelope(body)
	if route == _route_path("pvp_season_settlement", "/v1/pvp/season/settlement"):
			handled = SeasonSettlementService.accept_settlement(body)
	if route == _route_path("pvp_season_claim", "/v1/pvp/season/claim"):
			handled = SeasonSettlementService.accept_claim(body)
	if route == _route_path("reward_ledger_snapshot", "/v1/rewards/ledger"):
			handled = RewardLedgerService.accept_ledger_envelope(body)
	if route == _route_path("reward_claim", "/v1/rewards/claim"):
			handled = RewardLedgerService.accept_claim_envelope(body)
	if route == _route_path("pvp_defense_team_get", "/v1/pvp/defense-team"):
			handled = DefenseTeamService.accept_envelope(body)
	if route == _route_path("pvp_defense_team_publish", "/v1/pvp/defense-team/publish"):
			handled = DefenseTeamService.accept_envelope(body)
	if route == _route_path("inventory_snapshot", "/v1/inventory/snapshot"):
			handled = InventoryEntitlementService.accept_inventory_envelope(body)
	if route == _route_path("entitlements_snapshot", "/v1/entitlements/snapshot"):
			handled = InventoryEntitlementService.accept_entitlements_envelope(body)
	if route == _route_path("purchase_validate", "/v1/store/validate"):
			handled = InventoryEntitlementService.accept_purchase_validation_envelope(body)
	if route == _route_path("loadout_snapshot", "/v1/loadout/snapshot"):
			handled = LoadoutSnapshotService.accept_loadout_envelope(body)
	if route == _route_path("loadout_publish", "/v1/loadout/publish"):
			handled = LoadoutSnapshotService.accept_loadout_envelope(body)
	if route == _route_path("pvp_league_snapshot", "/v1/pvp/league"):
			handled = AsyncPvpService.accept_league_envelope(body)
	if route == _route_path("pvp_season_progress", "/v1/pvp/season/progress"):
			handled = AsyncPvpService.accept_season_progress_envelope(body)
	if route == _route_path("pvp_matchmaking", "/v1/pvp/matchmaking"):
			handled = AsyncPvpService.accept_matchmaking_envelope(body)
	if route == _route_path("pvp_defense_snapshot", "/v1/pvp/defense-snapshot"):
			handled = AsyncPvpService.accept_defense_snapshot_envelope(body)
	if route == _route_path("pvp_season_snapshot", "/v1/pvp/season"):
			handled = AsyncPvpService.accept_season_envelope(body)
	if route == _route_path("remote_spin", "/v1/game/spin"):
			handled = RemoteGameplayService.accept_spin_envelope(body)
	if route == _route_path("remote_combat_defeat", "/v1/game/combat/defeat"):
			handled = RemoteGameplayService.accept_combat_envelope(body)
	if route == _route_path("guild_boss_phase", "/v1/guild/boss/phase"):
			handled = GuildBossService.accept_phase_envelope(body)
	if route == _route_path("guild_boss_contribution", "/v1/guild/boss/contribution"):
			handled = GuildBossService.accept_contribution_envelope(body)
	if route == _route_path("guild_boss_reward_tiers", "/v1/guild/boss/reward-tiers"):
			handled = GuildBossService.accept_reward_tiers_envelope(body)
	if route == _route_path("guild_boss_snapshot", "/v1/guild/boss/snapshot"):
			handled = GuildBossService.accept_snapshot_envelope(body)
	if route == _route_path("guild_boss_attack", "/v1/guild/boss/attack"):
			handled = GuildBossService.accept_attack_envelope(body)
	if route == _route_path("guild_boss_claim", "/v1/guild/boss/claim"):
			handled = GuildBossService.accept_claim_envelope(body)
	if route == _route_path("pvp_opponents", "/v1/pvp/opponents"):
			handled = AsyncPvpService.accept_opponents_envelope(body)
	if route == _route_path("pvp_attack", "/v1/pvp/attack"):
			handled = AsyncPvpService.accept_battle_envelope(body)
	if route == _route_path("pvp_history", "/v1/pvp/history"):
			handled = AsyncPvpService.accept_history_envelope(body)
	if route == _route_path("pvp_claim", "/v1/pvp/claim"):
			handled = AsyncPvpService.accept_claim_envelope(body)
	if route == _route_path("friends_list", "/v1/social/friends"):
			handled = OnlineSocialService.accept_friends_envelope(body)
	if route == _route_path("friend_request", "/v1/social/friend-request"):
			handled = OnlineSocialService.accept_social_mutation_envelope(body)
	if route == _route_path("friend_accept", "/v1/social/friend-accept"):
			handled = OnlineSocialService.accept_social_mutation_envelope(body)
	if route == _route_path("guild_snapshot", "/v1/guild/snapshot"):
			handled = GuildService.accept_guild_envelope(body)
	if route == _route_path("guild_create", "/v1/guild/create"):
			handled = GuildService.accept_guild_envelope(body)
	if route == _route_path("guild_join", "/v1/guild/join"):
			handled = GuildService.accept_guild_envelope(body)
	if route == _route_path("guild_leave", "/v1/guild/leave"):
			handled = GuildService.accept_guild_envelope(body)
	if route == _route_path("ranking_snapshot", "/v1/rankings/snapshot"):
			handled = RankingOnlineService.accept_ranking_envelope(body)
	if route == _route_path("ranking_claim", "/v1/rankings/claim"):
			handled = RankingOnlineService.accept_claim_envelope(body)
	if handled:
		response_routed.emit(route,request_id,true)
	else:
		_reject(route,request_id,"UNHANDLED_OR_INVALID_RESPONSE")

func _route_session(body: Dictionary) -> bool:
	return bool(AuthSessionService.accept_session_envelope(body).get("ok",false))

func _route_sync(body: Dictionary) -> bool:
	var staged := SyncReconciliationService.stage_remote_envelope(body)
	if not bool(staged.get("ok",false)):
		return false
	return bool(SyncReconciliationService.apply_staged_envelope().get("ok",false))

func _route_authority(body: Dictionary) -> bool:
	var request_id := str(body.get("request_id",""))
	var revision := int(body.get("revision",-1))
	if request_id.is_empty() or revision < OnlineAuthorityService.server_revision:
		return false
	OnlineAuthorityService.resolve_pending_intent(request_id)
	OnlineAuthorityService.server_revision = revision
	if body.has("server_unix"):
		var server_unix := int(body.get("server_unix",0))
		OnlineAuthorityService.last_server_unix = server_unix
		ServerClockService.sync_server_time(server_unix)
	OnlineAuthorityService.authority_result.emit(body)
	return true

func _handle_transport_failure(route: String, request_id: String, response: Dictionary) -> void:
	var status := int(response.get("http_status",0))
	if status == 401:
		AuthSessionService.require_refresh()
	if NetworkResilienceService.state == NetworkResilienceService.DISCONNECTED:
		OnlineSessionState.set_state(OnlineSessionState.OFFLINE_LIMITED)
	response_rejected.emit(route,request_id,str(response.get("error_code","HTTP_REQUEST_FAILED")))

func _reject(route: String, request_id: String, code: String) -> void:
	response_rejected.emit(route,request_id,code)
	response_routed.emit(route,request_id,false)
