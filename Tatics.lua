-- ============================================================
-- Metadata
-- Nome: HellpsAI
-- Versao: 1.0
-- ============================================================
-- ============================================================
-- Tatics.lua -- configuracao de taticas do Homunculus
-- Define as taticas por monstro.
-- ============================================================

local Tactic = _G.Tactic or {}
_G.Tactic = Tactic

Tactic[0] = {
    monster_name = "Padrão",
    battle_mode = "basic_with_skills",
    dance_attack = true,
    target_priority = 2,
    target_scan_interval = 200,
    skill_interval = 10000,
    hom = {
        [LIF] = {
            slot_01 = false,
        },
        [AMISTR] = {
            slot_01 = false,
        },
        [FILIR] = {
            slot_01 = false,
        },
        [VANILMIRTH] = {
            slot_01 = false,
        },
    },
    hom_s = {
        [EIRA] = {
            slot_01 = false,
        },
        [BAYERI] = {
            slot_01 = false,
        },
        [SERA] = {
            slot_01 = MH_POISON_MIST,
        },
        [DIETER] = {
            slot_01 = MH_LAVA_SLIDE,
        },
        [ELEANOR] = {
            slot_01 = false,
        },
    },
}

Tactic[1002] = {
    monster_name = "Poring",
    battle_mode = "basic",
    dance_attack = true,
    target_priority = 2,
    target_scan_interval = 200,
    skill_interval = 5000,
    hom = {
        [LIF] = {
            slot_01 = false,
        },
        [AMISTR] = {
            slot_01 = false,
        },
        [FILIR] = {
            slot_01 = false,
        },
        [VANILMIRTH] = {
            slot_01 = false,
        },
    },
    hom_s = {
        [EIRA] = {
            slot_01 = false,
        },
        [BAYERI] = {
            slot_01 = false,
        },
        [SERA] = {
            slot_01 = false,
        },
        [DIETER] = {
            slot_01 = false,
        },
        [ELEANOR] = {
            slot_01 = false,
        },
    },
}
