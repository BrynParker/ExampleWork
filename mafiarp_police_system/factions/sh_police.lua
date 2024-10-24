
-- Since this faction is not a default, any player that wants to become part of this faction will need to be manually
-- whitelisted by an administrator.

FACTION.name = "Metro-Dade Police Department"
FACTION.description = "It's also again...in the name."
FACTION.color = Color(20, 120, 185)
FACTION.pay = 10 -- How much money every member of the faction gets paid at regular intervals.
FACTION.weapons = {
"weapon_pistol", "weapon_rpt_handcuff", "weapon_rpt_finebook", "weapon_rpt_stungun", "dradio"
}
FACTION.isGloballyRecognized = false -- Makes it so that everyone knows the name of the characters in this faction.
-- Note that FACTION.models is optional. If it is not defined, it will use all the standard HL2 citizen models.
FACTION.models = {
	"models/police.mdl"
}




FACTION.Ranks = {
    [1] = {"Academy Cadet", nil, nil},
    [2] = {"Probationary Officer", nil},
    [3] = {"Officer", "mafiarp_menu/mdpd_ranks/rank_officer.png", nil},
    [4] = {"Senior Officer", "mafiarp_menu/mdpd_ranks/rank_snr_officer.png", nil},
    [5] = {"Corporal", "mafiarp_menu/mdpd_ranks/rank_cpl.png", nil},
    [6] = {"Sergeant", "mafiarp_menu/mdpd_ranks/rank_sgt.png", nil, nil},
    [7] = {"Lieutenant", "mafiarp_menu/mdpd_ranks/rank_lt.png", nil, nil, true},
    [8] = {"Captain", "mafiarp_menu/mdpd_ranks/rank_capt.png", nil, nil, true},
    [9] = {"Assistant Chief", "mafiarp_menu/mdpd_ranks/rank_ass_chief.png", nil, nil, true},
    [10] = {"Chief of Department", "mafiarp_menu/mdpd_ranks/rank_chief.png", nil, nil, true},
    [11] = {"Deputy Commissioner", "mafiarp_menu/mdpd_ranks/rank_dep_comm.png", nil, nil, true},
    [12] = {"Commissioner", "mafiarp_menu/mdpd_ranks/rank_comm.png", nil, nil, true},
}


FACTION_POLICE = FACTION.index