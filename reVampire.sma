/*
  Источник: https://neugomon.ru/threads/124/
  Официальная поддержка: 
  GitHub: https://github.com/LEISER307/reAPI-Plugins/reVampire.sma
  
  Original autor by MakapoH , AcE
  Thanks for wopox1337
  Modification Author: L4D2 aka LEISER
  
  Settings:
	Для блокировки на опр. картах, создайте в папке: configs/vampire_block_maps.ini и запишите туда карты.
	
  Changelog:
	[*] Версия 1.0.4
		- Переписана часть кода
		- Исправлена выдача хп игроку,когда он мёртв.
		- Исправлена работа плагина с несколькими флагами
		- Если у игрока hp = HP_MAX ,то сообщение не будет выводится.
	
	[*] Версия 1.0.5
		- Мелкие правки по коду.
		- Добавлена поддержка CSDM FFA
		- Добавлена проверка на бомбу - Теперь игроку не дает HP за взрыв бомбы
		
	[*] Версия 1.0.6
		- Мерцание экрана при убийстве. (SCREEN_FADE)
		
	[*] Версия 1.0.7
		- Блокировка карт
		
	[*] Версия 1.0.7-2b
		- Убран SCREEN_FADE
		- Добавлены новые настройки: MSGHUD, HUD_Y, HUD_X
		- Если у игрока hp = HP_MAX то сообщений + звука не 
	
	[*] Версия 1.0.8q
		- Изменен алгоритм блокировки карт
*/

#include <amxmodx>
#include <reapi>

/******** НАСТРОЙКИ ********/
#define BLOCK_MAPS 			// Блокировка вампира на определённых картах.	(Default: off)
//#define FLAG_ACCESS (ADMIN_BAN|ADMIN_LEVEL_H)	// Выдавать только указанным флагам.	(Default: off)

//#define FFA_MODE 			// Поддержка CSDM FFA.	(Default: off)
#define HP_BODY	14.0 		// Кол-во hp за убийство.	(Default: 10.0)
#define HP_HS	19.0 		// Кол-во hp за убийство в голову.	(Default: 15.0)
#define HP_MAX	100.0 		// Максимальное Кол-во hp. (Выше этого значения hp прибавлять не будет).	(Default: 100.0)
#define KILL_SOUND 			// Звук при убийстве противника.
#define HUD_MESSAGE 		// HUD Сообщение о прибавке hp.

// Настройки HUD
#define MSGHUD "+%.0f ХП"	// Текст Hud сообщения о прибавление ХП (Default: Добавлено: +%.0f ХП)
#define HUD_Y	0.52		// HUD сообщения, координаты по Y
#define HUD_X	0.51		// HUD сообщения, координаты по X

public plugin_init() {
	#if defined BLOCK_MAPS
		load_block_maps();
	#endif
	
	register_plugin("RE Vampire", "1.0.8q", "MakapoH , AcE");
	RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed_Post", true);
}

load_block_maps() {
	new curmap[64]; get_mapname(curmap, charsmax(curmap));
	new path[64]; get_localinfo("amxx_configsdir", path, charsmax(path));
	
	format(path, charsmax(path), "%s/vampire_block_maps.ini", path);
	new bool:stop, file = fopen(path, "rt");
	
	if (!file_exists(path)) {
		new error[100];
		formatex(error, charsmax(error), "Cannot load customization file %s!", path);
		set_fail_state(error);
		return;
	}
	
	if(file) {
		new i, sizes, buffer[64]; i = -1; sizes = file_size(path, 1);

		while(++i < sizes) {
			fgets(file, buffer, charsmax(buffer)); trim(buffer);
			if(!buffer[0] || buffer[0] == ';' || buffer[0] == '/') continue;
			if(!equali(buffer, curmap)) continue;
			stop = true;
			fclose(file);
			break;
		}
		fclose(file);
	}
	if(stop) pause("ad"); return;
}

public CBasePlayer_Killed_Post(const victim, killer, iGib) {
	if (!is_user_connected(killer)) return;

	if (victim == killer || get_member(victim, m_bKilledByBomb)) return;

	#if !defined FFA_MODE
		if (get_member(victim, m_iTeam) == get_member(killer, m_iTeam)) return;
	#endif

	#if defined FLAG_ACCESS
		if (!(get_user_flags(killer) & FLAG_ACCESS)) return;
	#endif
	
	static Float:killer_HP, Float:TempHP;
	killer_HP = get_entvar(killer, var_health);
	TempHP = get_member(victim, m_bHeadshotKilled) ? HP_HS : HP_BODY;
	
	if(!(killer_HP < HP_MAX)) return;
	
	#if defined KILL_SOUND
		client_cmd(killer, "spk spk buttons/bell1");
	#endif
	
	#if defined HUD_MESSAGE
		static SyncHudMsg;
		if (!SyncHudMsg) SyncHudMsg = CreateHudSyncObj();
		set_hudmessage(0, 255, 0, HUD_Y, HUD_X, 0, 6.0, 2.0);
		ShowSyncHudMsg(killer, SyncHudMsg, MSGHUD, TempHP);
	#endif
	
	set_entvar(killer, var_health, ((killer_HP += TempHP) > HP_MAX) ? HP_MAX : killer_HP);
}
