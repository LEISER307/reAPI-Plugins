/*
  Источник: https://neugomon.ru/threads/124/
  Официальная поддержка: 
  GitHub: https://github.com/LEISER307/reAPI-Plugins/blob/master/reVampire.sma
  
  Original autor by MakapoH . AcE
  Thanks for wopox1337
  Autor edit: L4D2 aka LEISER
  
  Settings:
	Для блокировки на опр. картах, создайте в папке: configs/vampire_block_maps.ini и запишите туда карты.
*/

#include <amxmodx>
#include <reapi>

/******** НАСТРОЙКИ ********/

//#define FFA_MODE 			// Поддержка CSDM FFA.	(Default: off)
#define MSGHUD "+%.0f ХП"	// Показ сообщения прибовления ХП (Default: Добавлено: +%.0f ХП)
#define HUD_Y	0.52		// HUD сообщения смещение по Y
#define HUD_X	0.51		// HUD сообщения смещение по X
#define HP_BODY	14.0 		// Кол-во hp за убийство.	(Default: 10.0)
#define HP_HS	19.0 		// Кол-во hp за убийство в голову.	(Default: 15.0)
#define HP_MAX	100.0 		// Максимальное Кол-во hp. (Выше этого значения hp прибавлять не будет) (Default: 100.0)
#define KILL_SOUND 			// Звук при убийстве противника.
#define HUD_MESSAGE 		// HUD Сообщение о прибавке hp. (Если у игрока hp = HP_MAX то сообщения не будет)
//#define FLAG_ACCESS (ADMIN_BAN|ADMIN_LEVEL_H)	// Выдавать только указанным флагам.	(Default: off)
//#define BLOCK_MAPS 		// Блокировка вампира на определённых картах.	(Default: off)

/******** КОНЕЦ ********/

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
	register_plugin("RE Vampire", "1.0.7-2b", "MakapoH , AcE")
	
	#if defined BLOCK_MAPS
		if (gBlockMaps) {
	#endif
			RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed_Post", true)
	
	#if defined BLOCK_MAPS
		}
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
	
	if(!(killer_HP < HP_MAX)) return;
	
	#if defined KILL_SOUND
		client_cmd(killer, "spk spk buttons/bell1")
	#endif
	
	#if defined HUD_MESSAGE
		static SyncHudMsg
		if (!SyncHudMsg) SyncHudMsg = CreateHudSyncObj()
		set_hudmessage(0, 255, 0, HUD_Y, HUD_X, 0, 6.0, 2.0)
		ShowSyncHudMsg(killer, SyncHudMsg, MSGHUD, TempHP)
	#endif
	
	set_entvar(killer, var_health, ((killer_HP += TempHP) > HP_MAX) ? HP_MAX : killer_HP)
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
