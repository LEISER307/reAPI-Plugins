/*
  Официальная поддержка: https://dev-cs.ru/resources/334/
*/
#include <amxmodx>
#include <reapi>

//#define FFA_MODE 			// Поддержка CSDM FFA.
#define HP_BODY 14.0 		// Кол-во hp за убийство.
#define HP_HS 19.0 			// Кол-во hp за убийство в голову.
#define HP_MAX 100.0 		// Максимальное Кол-во hp. (Выше этого значения hp прибавлять не будет)
#define KILL_SOUND 			// Звук при убийстве противника.
#define HUD_MESSAGE 		// HUD Сообщение о прибавке hp. (Если у игрока hp = HP_MAX то сообщения не будет)
//#define SCREEN_FADE 		// Мерцание экрана при убийстве. (Если игрок слепой то мерцать не будет)
//#define FLAG_ACCESS (ADMIN_BAN|ADMIN_LEVEL_H)	// Выдавать только указанным флагам.
//#define BLOCK_MAPS 		// Блокировка вампира на определённых картах. Создайте фаил vampire_block_maps.ini и запишите туда карты.

#if defined SCREEN_FADE
	new g_MsgScreenFade
#endif

#if defined BLOCK_MAPS
	new bool:gBlockMaps
	
	public plugin_precache() {
		if (IsBlockMap()) {
			gBlockMaps = true
			return
		}
	}
#endif

public plugin_init() {
	register_plugin("RE Vampire", "1.0.7-2a", "MakapoH, AcE, REVO, L4D2")
	
	#if defined BLOCK_MAPS
		if (gBlockMaps) {
	#endif
			RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed_Post", true)
	
	#if defined BLOCK_MAPS
		}
	#else
		#if defined SCREEN_FADE
			g_MsgScreenFade = get_user_msgid("ScreenFade")
		#endif
	#endif
}

public CBasePlayer_Killed_Post(const victim, killer, iGib) {
	if (!is_user_connected(killer)) return

	if (victim == killer || get_member(victim, m_bKilledByBomb)) return

	#if !defined FFA_MODE
		if (get_member(victim, m_iTeam) == get_member(killer, m_iTeam)) return
	#endif

	#if defined FLAG_ACCESS
		if (!(get_user_flags(killer) & FLAG_ACCESS)) return
	#endif
	
	static Float:killer_HP, Float:TempHP
	killer_HP = get_entvar(killer, var_health)
	TempHP = get_member(victim, m_bHeadshotKilled) ? HP_HS : HP_BODY
	
	#if defined KILL_SOUND
		if (killer_HP < HP_MAX) client_cmd(killer, "spk spk buttons/bell1")
	#endif
	
	#if defined HUD_MESSAGE
		if (killer_HP < HP_MAX) {
			static SyncHudMsg
			if (!SyncHudMsg) SyncHudMsg = CreateHudSyncObj()
			set_hudmessage(0, 255, 0, 0.52, 0.51, 0, 6.0, 2.0)
			ShowSyncHudMsg(killer, SyncHudMsg, "+%.0f ХП", TempHP)
		}
	#endif
	
	set_entvar(killer, var_health, ((killer_HP += TempHP) > HP_MAX) ? HP_MAX : killer_HP)
	
	#if defined SCREEN_FADE
		if (get_gametime() >= Float:get_member(killer, m_blindStartTime) + Float:get_member(killer, m_blindFadeTime)) {
			message_begin(MSG_ONE, g_MsgScreenFade, .player = killer)
			write_short(1<<10); write_short(1<<10); write_short(0x0000); write_byte(0)
			write_byte(0); write_byte(200); write_byte(75); message_end()
		}
	#endif
}

#if defined BLOCK_MAPS
stock IsBlockMap() {
	new got_line, line_num, len
	new cfgdir[400], cfgpath[400], mapname[40], txt[400]
	get_localinfo("amxx_configsdir", cfgdir, charsmax(cfgdir))
	rh_get_mapname(mapname, 40 -1)
	format(cfgpath, 400, "%s/vampire_block_maps.ini", cfgdir)
	if (file_exists(cfgpath)) {
		got_line = read_file(cfgpath, line_num, txt, 400 -1, len)
		while(got_line > 0) {
			if (!strcmp(txt, mapname)) return 0
			line_num ++
			got_line = read_file(cfgpath, line_num, txt, 400 -1, len)
		}
	}
	return 1
}
#endif
