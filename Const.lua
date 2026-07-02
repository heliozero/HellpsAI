-- ============================================================
-- Const.lua — Constantes da API do Ragnarok Online
-- Estas constantes são usadas nas chamadas GetV(), SkillObject(), etc.
-- ============================================================

-- Argumentos de GetV()
V_OWNER          = 0
V_POSITION       = 1
V_TYPE           = 2
V_MOTION         = 3
V_ATTACKRANGE    = 4
V_TARGET         = 5
V_HOMUNTYPE      = 7
V_HP             = 8
V_SP             = 9
V_MAXHP          = 10
V_MAXSP          = 11

-- Tipos de movimento (V_MOTION)
MOTION_STAND     = 0
MOTION_MOVE      = 1
MOTION_ATTACK    = 2
MOTION_SIT       = 3
MOTION_CASTING   = 5
MOTION_DEAD      = 6

-- IDs dos tipos de Homunculus (V_HOMUNTYPE)
LIF              = 1
AMISTR           = 2
FILIR            = 3
VANILMIRTH       = 4
LIF2             = 5
AMISTR2          = 6
FILIR2           = 7
VANILMIRTH2      = 8
EIRA             = 48
BAYERI           = 49
SERA             = 50
DIETER           = 51
ELEANOR          = 52

-- ============================================================
-- Skills de Homunculus base
-- ============================================================

-- Lif
HLIF_HEAL                = 8001
HLIF_TOUCH_OF_HEAL       = 8001
HLIF_AVOID               = 8002
HLIF_EMERGENCY_AVOID     = 8002
HLIF_CHANGE              = 8004
HLIF_MENTAL_CHANGE       = 8004
-- Brain Surgery e passivas similares nao aparecem com ID utilizavel
-- no backup original usado como referencia.

-- Amistr
HAMI_CASTLE              = 8005
HAMI_CASTLING            = 8005
HAMI_DEFENCE             = 8006
HAMI_DEFENSE             = 8006
HAMI_BLOODLUST           = 8008
-- Adamantium Skin nao aparece com ID utilizavel no backup original.

-- Filir
HFLI_MOON                = 8009
HFLI_MOONLIGHT           = 8009
HFLI_FLEET               = 8010
HFLI_FLEET_MOVE          = 8010
HFLI_SPEED               = 8011
HFLI_OVER_SPEED          = 8011
HFLI_SBR44               = 8012

-- Vanilmirth
HVAN_CAPRICE             = 8013
HVAN_CHAOTIC             = 8014
HVAN_CHAOTIC_BENEDICTION = 8014
HVAN_SELFDESTRUCT        = 8016
HVAN_BIO_EXPLOSION       = 8016
-- Change Instruction nao aparece com ID utilizavel no backup original.

-- ============================================================
-- Skills de Homunculus S
-- ============================================================

-- Eira
MH_LIGHT_OF_REGENE       = 8022
MH_OVERED_BOOST          = 8023
MH_ERASER_CUTTER         = 8024
MH_XENO_SLASHER          = 8025
MH_SILENT_BREEZE         = 8026
MH_TWISTER_CUTTER        = 8047
MH_ABSOLUTE_ZEPHYR       = 8048

-- Sera
MH_SUMMON_LEGION         = 8018
MH_NEEDLE_OF_PARALYZE    = 8019
MH_POISON_MIST           = 8020
MH_PAIN_KILLER           = 8021
MH_TOXIN_OF_MANDARA      = 8053
MH_NEEDLE_STINGER        = 8054

-- Eleanor
MH_STYLE_CHANGE          = 8027
MH_SONIC_CRAW            = 8028
MH_SONIC_CLAW            = 8028
MH_SILVERVEIN_RUSH       = 8029
MH_MIDNIGHT_FRENZY       = 8030
MH_CBC                   = 8037
MH_EQC                   = 8038
MH_BLAZING_AND_FURIOUS   = 8050
MH_THE_ONE_FIGHTER_RISES = 8051
MH_TINDER_BREAKER        = 8036

-- Bayeri
MH_STAHL_HORN            = 8031
MH_GOLDENE_FERSE         = 8032
MH_STEINWAND             = 8033
MH_HEILIGE_STANGE        = 8034
MH_ANGRIFFS_MODUS        = 8035
MH_ANGRIFF_MODUS         = 8035
MH_GLANZEN_SPIES         = 8056
MH_HEILIGE_PFERD         = 8057
MH_GOLDENE_TONE          = 8058

-- Dieter
MH_MAGMA_FLOW            = 8039
MH_GRANITIC_ARMOR        = 8040
MH_LAVA_SLIDE            = 8041
MH_PYROCLASTIC           = 8042
MH_VOLCANIC_ASH          = 8043
MH_BLAST_FORGE           = 8044
MH_TEMPERING             = 8045

-- ============================================================
-- Catalogo estatico de skills de Homunculus
-- ============================================================

local HomSkills = {}

function GetHomSkillKey(homunculusType)
	if homunculusType == LIF or homunculusType == LIF2 then return LIF, "hom" end
	if homunculusType == AMISTR or homunculusType == AMISTR2 then return AMISTR, "hom" end
	if homunculusType == FILIR or homunculusType == FILIR2 then return FILIR, "hom" end
	if homunculusType == VANILMIRTH or homunculusType == VANILMIRTH2 then return VANILMIRTH, "hom" end
	if homunculusType == EIRA then return EIRA, "hom_s" end
	if homunculusType == BAYERI then return BAYERI, "hom_s" end
	if homunculusType == SERA then return SERA, "hom_s" end
	if homunculusType == DIETER then return DIETER, "hom_s" end
	if homunculusType == ELEANOR then return ELEANOR, "hom_s" end
	return nil, nil
end

function GetHomSkills(homunculusType)
	local key, bucket = GetHomSkillKey(homunculusType)
	if not key then
		return {}, nil, nil
	end
	return HomSkills[key] or {}, key, bucket
end

function GetHomSkillDefinition(skillID)
	for _, homSkills in pairs(HomSkills) do
		if type(homSkills) == "table" and homSkills[skillID] then
			return homSkills[skillID]
		end
	end
	return nil
end

HomSkills[LIF] = {
	hom_name = "lif",
	[HLIF_HEAL] = {
		skill_name = "Healing Hands",
		skill_type = "support",
		action_area = "target",
		target = "owner",
		level_max = 5,
		range = {9,9,9,9,9},
		sp_cost = {20,20,20,20,20},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0},
		reuse_delay = {0,0,0,0,0},
	},
	[HLIF_AVOID] = {
		skill_name = "Urgent Escape",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {40,40,40,40,40},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000},
		reuse_delay = {60000,60000,60000,60000,60000},
	},
	[HLIF_CHANGE] = {
		skill_name = "Mental Charge",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 3,
		range = {0,0,0},
		sp_cost = {100,100,100},
		fixed_cast = {0,0,0},
		variable_cast = {0,0,0},
		delay = {2000,2000,2000},
		duration = {300000,600000,900000},
		reuse_delay = {180000,180000,180000},
	},
}

HomSkills[AMISTR] = {
	hom_name = "amistr",
	[HAMI_CASTLE] = {
		skill_name = "Castling",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {10,10,10,10,10},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0},
		reuse_delay = {2000,2000,2000,2000,2000},
	},
	[HAMI_DEFENCE] = {
		skill_name = "Amistr Bulwark",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {40,40,40,40,40},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000},
		reuse_delay = {60000,60000,60000,60000,60000},
	},
	[HAMI_BLOODLUST] = {
		skill_name = "Bloodlust",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 3,
		range = {0,0,0},
		sp_cost = {120,120,120},
		fixed_cast = {0,0,0},
		variable_cast = {0,0,0},
		delay = {2000,2000,2000},
		duration = {300000,600000,900000},
		reuse_delay = {180000,180000,180000},
	},
}

HomSkills[FILIR] = {
	hom_name = "filir",
	[HFLI_MOON] = {
		skill_name = "Moonlight",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 5,
		range = {1,1,1,1,1},
		sp_cost = {20,20,20,20,20},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {0,0,0,0,0},
		delay = {500,500,500,500,500},
		duration = {0,0,0,0,0},
		reuse_delay = {1000,1000,1000,1000,1000},
	},
	[HFLI_FLEET] = {
		skill_name = "Flitting",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {50,50,50,50,50},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000},
		reuse_delay = {60000,60000,60000,60000,60000},
	},
	[HFLI_SPEED] = {
		skill_name = "Accellerated Flight",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {50,50,50,50,50},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000},
		reuse_delay = {60000,60000,60000,60000,60000},
	},
	[HFLI_SBR44] = {
		skill_name = "S.B.R.44",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 3,
		range = {1,1,1},
		sp_cost = {1,1,1},
		fixed_cast = {0,0,0},
		variable_cast = {0,0,0},
		delay = {0,0,0},
		duration = {0,0,0},
		reuse_delay = {180000,180000,180000},
	},
}

HomSkills[VANILMIRTH] = {
	hom_name = "vanilmirth",
	[HVAN_CAPRICE] = {
		skill_name = "Caprice",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 5,
		range = {9,9,9,9,9},
		sp_cost = {30,30,30,30,30},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {0,0,0,0,0},
		delay = {500,500,500,500,500},
		duration = {0,0,0,0,0},
		reuse_delay = {1000,1000,1000,1000,1000},
	},
	[HVAN_CHAOTIC] = {
		skill_name = "Chaotic Blessing",
		skill_type = "support",
		action_area = "target",
		target = "owner",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {40,40,40,40,40},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {0,0,0,0,0},
		delay = {0,0,0,0,0},
		duration = {0,0,0,0,0},
		reuse_delay = {3000,3000,3000,3000,3000},
	},
	[HVAN_SELFDESTRUCT] = {
		skill_name = "Self Destruct",
		skill_type = "offensive",
		action_area = "target",
		target = "self",
		level_max = 3,
		range = {0,0,0},
		sp_cost = {1,1,1},
		fixed_cast = {0,0,0},
		variable_cast = {0,0,0},
		delay = {1000,1000,1000},
		duration = {0,0,0},
		reuse_delay = {180000,180000,180000},
		area_of_effect = {9,9,9},
	},
}

HomSkills[EIRA] = {
	hom_name = "eira",
	[MH_ERASER_CUTTER] = {
		skill_name = "Eraser Cutter",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 10,
		range = {7,7,7,7,7,7,7,7,7,7},
		sp_cost = {25,30,35,40,45,50,55,60,65,70},
		fixed_cast = {0,0,0,0,0,0,0,0,0,0},
		variable_cast = {1500,1500,1500,1500,1500,1500,1500,1500,1500,1500},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {2000,2000,2000,2000,2000,2000,2000,2000,2000,2000},
	},
	[MH_XENO_SLASHER] = {
		skill_name = "Xeno Slasher",
		skill_type = "offensive",
		action_area = "ground",
		target = "enemy",
		level_max = 10,
		range = {7,7,7,7,7,7,7,7,7,7},
		sp_cost = {85,90,95,100,105,110,115,120,125,130},
		fixed_cast = {0,0,0,0,0,0,0,0,0,0},
		variable_cast = {1500,1500,1500,1500,1500,1500,1500,1500,1500,1500},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {3000,3000,3000,3000,3000,3000,3000,3000,3000,3000},
		area_of_effect = {3,3,3,5,5,5,7,7,7,9},
	},
	[MH_SILENT_BREEZE] = {
		skill_name = "Silent Breeze",
		skill_type = "support",
		action_area = "target",
		target = "enemy",
		level_max = 5,
		range = {9,9,9,9,9},
		sp_cost = {45,54,63,72,81},
		fixed_cast = {1000,800,600,400,200},
		variable_cast = {1200,1200,1400,1600,1800},
		delay = {1000,1000,1000,1000,1000},
		duration = {9000,12000,15000,18000,21000},
		reuse_delay = {20000,20000,20000,20000,20000},
	},
	[MH_LIGHT_OF_REGENE] = {
		skill_name = "Light of Regenerate",
		skill_type = "support",
		action_area = "target",
		target = "owner",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {80,80,80,80,80},
		fixed_cast = {1600,1400,1200,1000,800},
		variable_cast = {400,600,800,1000,1200},
		delay = {1000,1000,1000,1000,1000},
		duration = {30000,30000,30000,30000,30000},
		reuse_delay = {60000,60000,60000,60000,60000},
	},
	[MH_OVERED_BOOST] = {
		skill_name = "Overed Boost",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {70,90,110,130,150},
		fixed_cast = {200,300,400,500,600},
		variable_cast = {800,700,600,500,400},
		delay = {1000,1000,1000,1000,1000},
		duration = {30000,30000,30000,30000,30000},
		reuse_delay = {60000,60000,60000,60000,60000},
	},
	[MH_TWISTER_CUTTER] = {
		skill_name = "Twister Cutter",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 10,
		range = {7,7,7,7,7,7,7,7,7,7},
		sp_cost = {106,112,118,124,130,136,142,148,154,160},
		fixed_cast = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		variable_cast = {800,900,1000,1100,1200,1300,1400,1500,1600,1700},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {3000,3000,3000,3000,3000,3000,3000,3000,3000,3000},
	},
	[MH_ABSOLUTE_ZEPHYR] = {
		skill_name = "Absolute Zephyr",
		skill_type = "offensive",
		action_area = "ground",
		target = "enemy",
		level_max = 10,
		range = {7,7,7,7,7,7,7,7,7,7},
		sp_cost = {122,129,136,143,150,157,164,171,178,185},
		fixed_cast = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		variable_cast = {1000,1200,1400,1600,1800,2000,2200,2400,2600,2800},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {5000,5000,5000,5000,5000,5000,5000,5000,5000,5000},
		area_of_effect = {3,3,3,5,5,5,7,7,7,9},
	},
}

HomSkills[BAYERI] = {
	hom_name = "bayeri",
	[MH_STAHL_HORN] = {
		skill_name = "Stahl Horn",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 10,
		range = {5,5,6,6,7,7,8,8,9,9},
		sp_cost = {43,46,49,52,55,58,61,64,67,70},
		fixed_cast = {0,0,0,0,0,0,0,0,0,0},
		variable_cast = {500,500,500,500,500,500,500,500,500,500},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {2000,2000,2000,2000,2000,2000,2000,2000,2000,2000},
	},
	[MH_STEINWAND] = {
		skill_name = "Stein Wand",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {80,90,100,110,120},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {1000,1000,1000,1000,1000},
		delay = {1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000},
		reuse_delay = {60000,60000,60000,60000,60000},
	},
	[MH_HEILIGE_STANGE] = {
		skill_name = "Heilige Stange",
		skill_type = "offensive",
		action_area = "ground",
		target = "enemy",
		level_max = 10,
		range = {9,9,9,9,9,9,9,9,9,9},
		sp_cost = {48,54,60,66,72,78,84,90,96,102},
		fixed_cast = {0,0,0,0,0,0,0,0,0,0},
		variable_cast = {1500,1500,1500,1500,1500,1500,1500,1500,1500,1500},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {3000,3000,3000,3000,3000,3000,3000,3000,3000,3000},
		area_of_effect = {3,3,3,3,5,5,5,5,7,7},
	},
	[MH_ANGRIFFS_MODUS] = {
		skill_name = "Angriffs Modus",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {80,80,80,80,80},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {200,400,600,800,1000},
		delay = {1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000},
		reuse_delay = {30000,30000,30000,30000,30000},
	},
	[MH_GOLDENE_FERSE] = {
		skill_name = "Goldene Ferse",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {80,80,80,80,80},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {1000,1200,1400,1600,1800},
		delay = {1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000},
		reuse_delay = {30000,30000,30000,30000,30000},
	},
	[MH_GLANZEN_SPIES] = {
		skill_name = "Glanzen Spies",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 10,
		range = {7,7,7,7,7,7,7,7,7,7},
		sp_cost = {60,65,70,75,80,85,90,95,100,105},
		fixed_cast = {0,0,0,0,0,0,0,0,0,0},
		variable_cast = {0,0,0,0,0,0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {2000,2000,2000,2000,2000,2000,2000,2000,2000,2000},
	},
	[MH_HEILIGE_PFERD] = {
		skill_name = "Heilige Pferd",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 10,
		range = {0,0,0,0,0,0,0,0,0,0},
		sp_cost = {122,129,136,143,150,157,164,171,178,185},
		fixed_cast = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		variable_cast = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000,60000,60000,60000,60000,60000},
		reuse_delay = {8000,8000,8000,8000,8000,8000,8000,8000,8000,8000},
		area_of_effect = {3,3,3,3,5,5,5,5,7,7},
	},
	[MH_GOLDENE_TONE] = {
		skill_name = "Goldene Tone",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 10,
		range = {0,0,0,0,0,0,0,0,0,0},
		sp_cost = {124,133,142,151,160,169,178,187,196,205},
		fixed_cast = {1500,1500,1500,1500,1500,1500,1500,1500,1500,1500},
		variable_cast = {1500,1500,1500,1500,1500,1500,1500,1500,1500,1500},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000,60000,60000,60000,60000,60000},
		reuse_delay = {40000,50000,60000,70000,80000,90000,100000,110000,120000,130000},
	},
}

HomSkills[SERA] = {
	hom_name = "sera",
	[MH_NEEDLE_OF_PARALYZE] = {
		skill_name = "Needle of Paralyze",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 10,
		range = {5,5,5,5,5,5,5,5,5,5},
		sp_cost = {42,48,54,60,66,72,78,84,90,96},
		fixed_cast = {0,0,0,0,0,0,0,0,0,0},
		variable_cast = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {3000,3500,4000,4500,5000,5500,6000,6500,7000,7500},
		reuse_delay = {2000,2000,2000,2000,2000,2000,2000,2000,2000,2000},
	},
	[MH_POISON_MIST] = {
		skill_name = "Poison Mist",
		skill_type = "offensive",
		action_area = "ground",
		target = "enemy",
		level_max = 10,
		range = {7,7,7,7,7},
		sp_cost = {80,80,80,80,80},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {1000,1000,1000,1000,1000},
		delay = {1000,1000,1000,1000,1000},
		duration = {10000,10000,10000,10000,10000},
		reuse_delay = {10000,10000,10000,10000,10000},
		area_of_effect = {7,7,7,7,7},
	},
	[MH_PAIN_KILLER] = {
		skill_name = "Pain Killer",
		skill_type = "support",
		action_area = "target",
		target = "owner",
		level_max = 5,
		range = {5,5,5,5,5,5,5,5,5,5},
		sp_cost = {48,52,56,60,64,68,72,76,80,84},
		fixed_cast = {0,0,0,0,0,0,0,0,0,0},
		variable_cast = {2500,2500,2500,2500,2500,2500,2500,2500,2500,2500},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {30000,30000,30000,30000,30000,30000,30000,30000,30000,30000},
		reuse_delay = {60000,60000,60000,60000,60000,60000,60000,60000,60000,60000},
	},
	[MH_SUMMON_LEGION] = {
		skill_name = "Summon Legion",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 5,
		range = {9,9,9,9,9},
		sp_cost = {60,80,100,120,140},
		fixed_cast = {400,600,800,1000,1200},
		variable_cast = {1600,1400,1200,1000,800},
		delay = {1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000},
		reuse_delay = {60000,60000,60000,60000,60000},
	},
	[MH_TOXIN_OF_MANDARA] = {
		skill_name = "Toxin Of Mandara",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 10,
		range = {7,7,7,7,7,7,7,7,7,7},
		sp_cost = {60,65,70,75,80,85,90,95,100,105},
		fixed_cast = {500,500,500,500,500,500,500,500,500,500},
		variable_cast = {500,500,500,500,500,500,500,500,500,500},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {8000,8000,8000,8000,8000,8000,8000,8000,8000,8000},
	},
	[MH_NEEDLE_STINGER] = {
		skill_name = "Needle Stinger",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 10,
		range = {9,9,9,9,9,9,9,9,9,9},
		sp_cost = {74,82,90,98,106,114,122,130,138,146},
		fixed_cast = {500,500,500,500,500,500,500,500,500,500},
		variable_cast = {1000,1100,1200,1300,1400,1500,1600,1700,1800,1900},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {2000,2000,2000,2000,2000,2000,2000,2000,2000,2000},
	},
}

HomSkills[DIETER] = {
	hom_name = "dieter",
	[MH_LAVA_SLIDE] = {
		skill_name = "Lava Slide",
		skill_type = "offensive",
		action_area = "ground",
		target = "enemy",
		level_max = 5,
		range = {7,7,7,7,7,7,7,7,7,7},
		sp_cost = {80,80,80,80,80,80,80,80,80,80},
		fixed_cast = {0,0,0,0,0,0,0,0,0,0},
		variable_cast = {2000,2000,2000,2000,2000,2000,2000,2000,2000,2000},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {6000,7000,8000,9000,10000,11000,12000,13000,14000,15000},
		reuse_delay = {3000,3000,3000,3000,3000,3000,3000,3000,3000,3000},
		area_of_effect = {3,3,3,5,5,5,7,7,7,9},
	},
	[MH_VOLCANIC_ASH] = {
		skill_name = "Volcanic Ash",
		skill_type = "offensive",
		action_area = "ground",
		target = "enemy",
		level_max = 5,
		range = {7,7,7,7,7},
		sp_cost = {80,80,80,80,80},
		fixed_cast = {1000,1000,1000,1000,1000},
		variable_cast = {4000,3500,3000,2500,2000},
		delay = {1000,1000,1000,1000,1000},
		duration = {8000,16000,24000,32000,40000},
		reuse_delay = {10000,10000,10000,10000,10000},
		area_of_effect = {3,3,3,3,3},
	},
	[MH_GRANITIC_ARMOR] = {
		skill_name = "Granitic Armor",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {70,70,70,70,70},
		fixed_cast = {1000,1000,1000,1000,1000},
		variable_cast = {5000,4500,4000,3500,3000},
		delay = {1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000},
		reuse_delay = {60000,60000,60000,60000,60000},
	},
	[MH_PYROCLASTIC] = {
		skill_name = "Pyroclastic",
		skill_type = "support",
		action_area = "target",
		target = "owner",
		level_max = 5,
		range = {0,0,0,0,0,0,0,0,0,0},
		sp_cost = {20,28,36,44,52,56,60,64,66,70},
		fixed_cast = {0,0,0,0,0,0,0,0,0,0},
		variable_cast = {2500,2500,2500,2500,2500,2500,2500,2500,2500,2500},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {30000,30000,30000,30000,30000,30000,30000,30000,30000,30000},
		reuse_delay = {60000,60000,60000,60000,60000,60000,60000,60000,60000,60000},
	},
	[MH_MAGMA_FLOW] = {
		skill_name = "Magma Flow",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {50,50,50,50,50},
		fixed_cast = {2000,1500,1000,500,0},
		variable_cast = {2000,2500,3000,3500,4000},
		delay = {1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000},
		reuse_delay = {30000,30000,30000,30000,30000},
	},
	[MH_TEMPERING] = {
		skill_name = "Tempering",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 10,
		range = {0,0,0,0,0,0,0,0,0,0},
		sp_cost = {20,28,36,44,52,60,68,76,84,92},
		fixed_cast = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		variable_cast = {5000,4500,4000,3500,3000,2500,2000,1500,1000,500},
		delay = {500,500,500,500,500,500,500,500,500,500},
		duration = {60000,60000,60000,60000,60000,60000,60000,60000,60000,60000},
		reuse_delay = {45000,60000,75000,90000,105000,120000,135000,150000,165000,180000},
	},
	[MH_BLAST_FORGE] = {
		skill_name = "Blast Forge",
		skill_type = "offensive",
		action_area = "ground",
		target = "enemy",
		level_max = 10,
		range = {7,7,7,7,7,7,7,7,7,7},
		sp_cost = {52,59,66,73,80,87,94,101,108,115},
		fixed_cast = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		variable_cast = {5000,4500,4000,3500,3000,2500,2000,1500,1000,500},
		delay = {2000,2000,2000,2000,2000,2000,2000,2000,2000,2000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {5000,5000,5000,5000,5000,5000,5000,5000,5000,5000},
		area_of_effect = {3,3,3,5,5,5,7,7,7,7},
	},
}

HomSkills[ELEANOR] = {
	hom_name = "eleanor",
	[MH_STYLE_CHANGE] = {
		skill_name = "Style Change",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 1,
		range = {0},
		sp_cost = {35},
		fixed_cast = {0},
		variable_cast = {0},
		delay = {1000},
		duration = {0},
		reuse_delay = {0},
	},
	[MH_SONIC_CLAW] = {
		skill_name = "Sonic Claw",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 5,
		range = {1,1,1,1,1},
		sp_cost = {20,25,30,35,40},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0},
		reuse_delay = {1000,1000,1000,1000,1000},
	},
	[MH_SILVERVEIN_RUSH] = {
		skill_name = "Silvervein Rush",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 10,
		range = {1,1,1,1,1,1,1,1,1,1},
		sp_cost = {17,19,21,23,25,27,29,31,33,35},
		fixed_cast = {0,0,0,0,0,0,0,0,0,0},
		variable_cast = {0,0,0,0,0,0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {1500,1500,1500,1500,1500,1500,1500,1500,1500,1500},
	},
	[MH_MIDNIGHT_FRENZY] = {
		skill_name = "Midnight Frenzy",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 10,
		range = {1,1,1,1,1,1,1,1,1,1},
		sp_cost = {18,21,24,27,30,33,36,39,42,45},
		fixed_cast = {0,0,0,0,0,0,0,0,0,0},
		variable_cast = {0,0,0,0,0,0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {1500,1500,1500,1500,1500,1500,1500,1500,1500,1500},
	},
	[MH_TINDER_BREAKER] = {
		skill_name = "Tinder Breaker",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 5,
		range = {3,4,5,6,7},
		sp_cost = {20,25,30,35,40},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {1000,1000,1000,1000,1000},
		delay = {1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0},
		reuse_delay = {2000,2000,2000,2000,2000},
	},
	[MH_CBC] = {
		skill_name = "C.B.C (Continuous Brandishing Combo)",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 5,
		range = {1,1,1,1,1},
		sp_cost = {10,20,30,40,50},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0},
		reuse_delay = {2000,2000,2000,2000,2000},
	},
	[MH_EQC] = {
		skill_name = "E.Q.C (Eternal Quickening Combo)",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 5,
		range = {0,0,0,0,0},
		sp_cost = {24,28,32,36,40},
		fixed_cast = {0,0,0,0,0},
		variable_cast = {0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0},
		reuse_delay = {2000,2000,2000,2000,2000},
	},
	[MH_BLAZING_AND_FURIOUS] = {
		skill_name = "Blazing And Furious",
		skill_type = "offensive",
		action_area = "target",
		target = "enemy",
		level_max = 10,
		range = {7,7,7,7,7,7,7,7,7,7},
		sp_cost = {103,108,113,118,123,128,133,138,143,148},
		fixed_cast = {0,0,0,0,0,0,0,0,0,0},
		variable_cast = {0,0,0,0,0,0,0,0,0,0},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {0,0,0,0,0,0,0,0,0,0},
		reuse_delay = {4000,4000,4000,4000,4000,4000,4000,4000,4000,4000},
		area_of_effect = {3,3,3,3,5,5,5,7,7,7},
	},
	[MH_THE_ONE_FIGHTER_RISES] = {
		skill_name = "The One Fighter Rises",
		skill_type = "support",
		action_area = "target",
		target = "self",
		level_max = 10,
		range = {0,0,0,0,0,0,0,0,0,0},
		sp_cost = {100,106,112,118,124,130,136,142,148,154},
		fixed_cast = {500,500,500,500,500,500,500,500,500,500},
		variable_cast = {500,500,500,500,500,500,500,500,500,500},
		delay = {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000},
		duration = {60000,60000,60000,60000,60000,60000,60000,60000,60000,60000},
		reuse_delay = {120000,120000,120000,120000,120000,120000,120000,120000,120000,120000},
		area_of_effect = {3,3,3,5,5,5,5,5,7,7},
	},
}

