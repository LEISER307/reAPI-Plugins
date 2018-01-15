//-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+//
//							Плагин: System free VIP									//
//								Автор: Aki_Lucky									//
//----------------------------------------------------------------------------------//
//	При копировании материала указать ссылку на эту группу https://vk.com/amxx_plug	//
//				Поддержка плагина осуществляется только в этой группе				//
//																					//
//-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+//
//					Заказ плагинов https://vk.com/vacuum000							//
//-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+//

#include <amxmodx>
#include <amxmisc>

#define PLUGIN "System free VIP"
#define VERSION "1.2 Alpha"
#define AUTHOR "Aki_Lucky"

#define VIP_FLAG ADMIN_LEVEL_H	// указать флаг для VIP

//-+-+-+-+-+-+-+-+-+-+-+-+-+-+ВЫБИРИТЕ РЕЖИМЫ-+-+-+-+-+-+-+-+-+-+-+--+-+-+-+-++-+-++//
// Выбранные режим необходимо раскоментировать	остальное настраивается кварами		//
//																					//
//#define VIP_BY_TIME			// выдача вип по заданному времени					//
//#define VIP_BY_DAY 			// выдача вип по заданным дням						//
//#define VIP_BY_HOLIDAYS 		// выдача вип по праздникам							//
//#define VIP_BY_ONLINE 		// выдача вип при низком онлайне					//
//#define VIP_MENU 				// меню выдачи вип игроку на карту					//
//#define VIP_BAY_CMD 			// для активации вип на 1 раунд за деньги			//
//																					//
//#define HUD_INFORM 			// HUD информер справа от радара с информацией		//
//																					//
//-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+//

#if defined VIP_BAY_CMD
	#include <hamsandwich>
	#include <cstrike>
	new bool:bay_vip[33] = false;
	new hud_text_cmd[100]
	new Round = 0;
#endif

#if defined HUD_INFORM
	new hud_text[512]
#endif

#if defined VIP_BY_TIME
	new hour, minute, second
	new bool:bay_vip_time[33] = false;
	new hud_text_time[100]
#endif

#if defined VIP_BY_DAY
	new string[8];
	new day_w[2];
	new bool:VIPDAYS = false;
	new day_name[][] = {"Сегодня", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"}
	new hud_text_day[100]
#endif

#if defined VIP_BY_HOLIDAYS
	new text_s[128],len
	new text1[3]
	new text2[3]
	new text3[64]
	new day[3], month[3]
	new bool:HOLIDAYS = false;
	new hud_text_holiday[100]
#endif

#if defined VIP_BY_ONLINE
	new bool:bay_vip_onl[33] = false;
	new hud_text_onl[100]
#endif

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_cvar("amx_vip1_start", "0")
	register_cvar("amx_vip1_stop", "8")
	register_cvar("amx_vip2_day", "67")
	register_cvar("amx_vip4_start", "12")
	register_cvar("amx_vip7_money", "16000")
	
	register_clcmd("say /bayvip", "bayvip")
	register_clcmd("say /menuvip", "vips_menu", ADMIN_BAN);
	
	register_logevent("round_start",2,"1=Round_Start")
	#if defined VIP_BY_ONLINE
		register_event("TextMsg", "round_restart", "a", "2=#Game_will_restart_in","2=#Game_Commencing");
	#endif
}

public plugin_cfg(){
	#if defined VIP_BY_DAY
		get_time ("%w", day_w, 1)
		get_cvar_string("amx_vip2_day", string, charsmax(string))
		new symbol[sizeof string][2] 
		new pos = containi(string,day_w)
		if(pos != -1){
			VIPDAYS = true;
			format(hud_text_day, 99, "Ближайший VIP день (%s)", day_name[0])
		}else{
			VIPDAYS = false;
			new sled_day = 7
			new dd = str_to_num(day_w)
			for(new a = 0; a < charsmax(string); a++){
				format(symbol[a], 1, "%s", string[a])		
				new ii = str_to_num(symbol[a])
				if(dd < ii){
					if(sled_day > ii){
						sled_day = ii
						format(hud_text_day, 99, "Ближайший VIP день (%s)", day_name[sled_day])
					}
				}
			}
		}
	#endif

	#if defined VIP_BY_HOLIDAYS
		get_time ("%d", day, 2)
		get_time ("%m", month, 2)
		for(new i = 0;i < file_size("addons/amxmodx/configs/SFV/holidays.ini",1); i++){
			read_file("addons/amxmodx/configs/SFV/holidays.ini", i, text_s, charsmax(text_s), len)
			if(!equali(";", text_s[0])){
				parse(text_s, text1, 2, text2, 2, text3, 63)
				if(equali(month, text1)){
					if(equali(day, text2)){
						HOLIDAYS = true;
						format(hud_text_holiday, 99, "Ближайший праздник (Сегодня)")
						break;
					}else{
						HOLIDAYS = false;
					}
				}
			}
		}
		new sled_holiday = 32;
		new sled_mm = str_to_num(month)
		new dd = str_to_num(day)
		
		
		
		for(new a = 0;a < file_size("addons/amxmodx/configs/SFV/holidays.ini",1); a++){
			for(new i = 0;i < file_size("addons/amxmodx/configs/SFV/holidays.ini",1); i++){
				read_file("addons/amxmodx/configs/SFV/holidays.ini", i, text_s, charsmax(text_s), len)
				if(!equali(";", text_s[0])){
					parse(text_s, text1, 2, text2, 2, text3, 63)
					new mm = str_to_num(text1)
					new ii = str_to_num(text2)
					if(mm == sled_mm){
						if(dd < ii)
							if(sled_holiday > ii){
								sled_holiday = ii
								format(hud_text_holiday, 99, "Ближайший праздник (%s.%d)", text1, sled_holiday)
								break;
							}
					}
				}
			}
			if(sled_holiday != 32)
				break;
			sled_mm++
		}
		
	#endif
	
	#if defined VIP_BAY_CMD
		format(hud_text_cmd, 99, "Купить VIP на раунд /bayvip (%d$)", get_cvar_num("amx_vip7_money"))
	#endif
}

//*****************************************************РАЗЛИЧНЫЕ ФУНКЦИИ****************************************************************************
public client_putinserver(id){
	#if defined VIP_BY_DAY
		if(VIPDAYS == true)
			vidacha_vip(id)
	#endif
	#if defined VIP_BY_ONLINE
		bay_vip_onl[id] = false;
	#endif
	
	#if defined VIP_BY_HOLIDAYS
		if(HOLIDAYS == true)
			vidacha_vip(id)
	#endif
	
	#if defined HUD_INFORM
		hud_informer(id);
	#endif
}

public round_start(){
	#if defined VIP_BY_ONLINE
	Round++;
	new players = get_playersnum()
	if (players <= get_cvar_num("amx_vip4_start") && Round > 2){
		for(new i = 1; i < players; i++){
			if (~get_user_flags(i) & VIP_FLAG){
				bay_vip_onl[i] = true;
				set_user_flags(i,VIP_FLAG)
				format(hud_text_onl, 99, "Низкий онлайн. Всем VIP")
			}
		}
	}else{
		for(new i = 1; i < players; i++){
			if(bay_vip_onl[i] == true){
				remove_user_flags(i,VIP_FLAG)
				bay_vip_onl[i] = false;
				format(hud_text_onl, 99, "")
			}
		}
	}
	#endif
	
	#if defined VIP_BY_TIME
		time(hour, minute, second)
		if (hour >= get_cvar_num("amx_vip1_start") && hour < get_cvar_num("amx_vip1_stop")){
			for(new i = 1; i < players; i++){
				if (~get_user_flags(i) & VIP_FLAG){
					bay_vip_time[i] = true;
					set_user_flags(i,VIP_FLAG)
					format(hud_text_time, 99, "Ночная VIP (Конец в %d:00)", get_cvar_num("amx_vip1_stop"))
				}
			}
		}else{
			format(hud_text_time, 99, "Ночная VIP (Начало в %d:00)", get_cvar_num("amx_vip1_start"))
			for(new i = 1; i < players; i++){
				if(bay_vip_time[i] == true){
					remove_user_flags(i,VIP_FLAG)
					bay_vip_time[i] = false;
				}
			}
		}
	#endif
}
#if defined VIP_BY_ONLINE
	public round_restart(){
		Round = 0;
	}
#endif
//*****************************************************МЕНЮ ВЫДАЧИ ВИП*******************************************************************************
#if defined VIP_MENU
	public vips_menu(id, level) {
		if(~get_user_flags(id) & level){
			client_print(id, print_notify, "* У Вас недостаточно прав для использования этой команды");
			return PLUGIN_HANDLED;
		}
		new i_Menu = menu_create("Меню выдачи VIP by Aki_Lucky", "menu_vips")
		
		new players[32], pnum, tempid
		new szName[32], szTempid[10]
 
		get_players(players, pnum)
		for(new i; i<pnum; i++){
			tempid = players[i]
			get_user_name(tempid, szName, 31)
			num_to_str(tempid, szTempid, 9)
			new text_menu[64]
			if(tempid == id){
				format(text_menu, 63, "%s \w[\rВЫ\w]", szName)
				menu_additem(i_Menu, text_menu, szTempid, ADMIN_RCON)
			}
			else if(get_user_flags(tempid) & VIP_FLAG){
				format(text_menu, 63, "%s \w[\yVIP\w]", szName)
				menu_additem(i_Menu, text_menu, szTempid, ADMIN_RCON)
			}
			else if(get_user_flags(tempid) & ADMIN_BAN){
				format(text_menu, 63, "%s \w[\rАдмин\w]", szName)
				menu_additem(i_Menu, text_menu, szTempid, ADMIN_RCON)
			}else{
				menu_additem(i_Menu, szName, szTempid, 0)
			}
		}
		menu_setprop(i_Menu, MPROP_NEXTNAME, "Далее");
		menu_setprop(i_Menu, MPROP_BACKNAME, "Назад");
		menu_setprop(i_Menu, MPROP_EXITNAME, "Выход");
		menu_display(id, i_Menu, 0)
		return PLUGIN_HANDLED;
	}

	public menu_vips(id, menu, item){
		if(item == MENU_EXIT){
			menu_destroy(menu)
			return PLUGIN_HANDLED
		}
	 
		new data[6], iName[64]
		new access, callback
		menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)

		new tempid = str_to_num(data)
		
		vidacha_vip(tempid);
	 
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

#endif

#if defined VIP_BAY_CMD
	public bayvip(id){
		if(cs_get_user_money(id) >= get_cvar_num("amx_vip7_money")){
			if(~get_user_flags(id) & VIP_FLAG){
				cs_set_user_money(id,cs_get_user_money(id) - get_cvar_num("amx_vip7_money"))
				set_user_flags(id,VIP_FLAG)
				bay_vip[id] = true;
			}
		}else{
			client_print(id, print_notify, "* У вас недостаточно денег");
		}
	}
	
	public Spawn_cmd(id){
		if(bay_vip[id])
			remove_user_flags(id,VIP_FLAG)
	}
#endif

public vidacha_vip(id){
	if(~get_user_flags(id) & VIP_FLAG)
		set_user_flags(id,VIP_FLAG)
}
#if defined HUD_INFORM
	public hud_informer(id){
		if(is_user_connected(id)){
			format(hud_text, 511, "")
			set_hudmessage(225, 255, 0, 0.15, 0.01, 0, 0.0, 1.0)
			#if defined VIP_BY_TIME
				format(hud_text, 511, "%s^n", hud_text_time)
			#endif

			#if defined VIP_BY_DAY
				format(hud_text, 511, "%s%s^n", hud_text, hud_text_day)
			#endif

			#if defined VIP_BY_HOLIDAYS
				format(hud_text, 511, "%s%s^n", hud_text, hud_text_holiday)
			#endif

			#if defined VIP_BY_ONLINE
				new players = get_playersnum()
				if (players <= get_cvar_num("amx_vip4_start")){
					format(hud_text, 511, "%s%s^n", hud_text, hud_text_onl)
				}
			#endif

			#if defined VIP_BAY_CMD
				format(hud_text, 511, "%s%s^n", hud_text, hud_text_cmd)
			#endif
			show_hudmessage(id, hud_text)
			set_task(1.0, "hud_informer", id);
		}
	}
#endif
