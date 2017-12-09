/*
  GitHub: https://github.com/LEISER307/reAPI-Plugins/blob/master/admin_vip_online.sma
  
  Author: L4D2 aka LEISER
  
  Changelog:
	[*] Версия 0.4.4
		- Stable version
*/

#include <amxmodx>
#include <amxmisc>

#if AMXX_VERSION_NUM < 183
	#include <colorchat>
#endif

#define ACCES_ADMIN		ADMIN_IMMUNITY	// Флаг для проверки "Админы Онлайн"
#define ACCES_VIP		ADMIN_KICK		// Флаг для проверки "VIP Онлайн"
#define ACCES_GIRL		ADMIN_LEVEL_H	// Флаг для проверки "Девушки Онлайн"

public plugin_init() {
	register_plugin("Admin\VIP\Girl Online", "0.4.4", "Dev-cs.ru Modification L4D2")
	
	register_clcmd("say /online", "show_admins")
	register_clcmd("say_team /online", "show_admins")
}         
  
public show_admins(id) {
	new Admins[16], aCounter = 0
	new VIP[16], vCounter = 0
	new Girl[16], gCounter = 0
	new MaxP[32], pCounter, player

	get_players(MaxP, pCounter, "ch")

	for(new i = 0 ; i < pCounter; i++) {
		player = MaxP[i]
		
		if (access(player, ACCES_ADMIN)) {
			Admins[aCounter] = player
			aCounter++
			continue;
		}
		if (access(player, ACCES_VIP)) {
			VIP[vCounter] = player
			vCounter++
			continue;
		}
		if (access(player, ACCES_GIRL)) {
			Girl[gCounter] = player
			gCounter++
			continue;
		}
	}
	
	if(aCounter == 0) client_print_color(id, print_team_default, "^1[^3Online^1]^3 Админов:^4 Нет в Сети.")
	else {
		new adminonline[200]
		new adminname[32], iAdminID

		for(new z = 0; z < aCounter; z++) {
			iAdminID = Admins[z]
			get_user_name(iAdminID, adminname, 31)
			add(adminonline, charsmax(adminonline), adminname)

			if(z != aCounter-1) add(adminonline, charsmax(adminonline), ", ")
		}
		client_print_color(id, print_team_default, "^1[^3Online^1]^3 Админ:^4 %s", adminonline)
	}

	if(vCounter == 0) client_print_color(id, print_team_default, "^1[^3Online^1]^3 VIP:^4 Нет в Сети.")
	else {  
		new viponline[200]  
		new vipname[32], iVIPID  

		for(new z = 0; z<vCounter; z++) {
			iVIPID = VIP[z]
			get_user_name(iVIPID, vipname, 31)
			add(viponline, charsmax(viponline), vipname)

			if(z != vCounter-1) add(viponline, charsmax(viponline), ", ")
		}
		client_print_color(id, print_team_default, "^1[^3Online^1]^3 VIP:^4 %s", viponline)
	}
	
	if(gCounter == 0) client_print_color(id, print_team_default, "^1[^3Online^1]^3 Девушек:^4 Нет в Сети.")
	else {  
		new girlonline[200]  
		new girlname[32], iGirlID  

		for(new z = 0; z < gCounter; z++) {
			iGirlID = Girl[z]
			get_user_name(iGirlID, girlname, 31)
			add(girlonline, charsmax(girlonline), girlname)

			if(z != gCounter-1) add(girlonline, charsmax(girlonline), ", ")
		}
		client_print_color(id, print_team_default, "^1[^3Online^1]^3 Девушки:^4 %s", girlonline)
	}
}
