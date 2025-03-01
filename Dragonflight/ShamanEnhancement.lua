-- ShamanEnhancement.lua
-- October 2022

if UnitClassBase( "player" ) ~= "SHAMAN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local PTR = ns.PTR
local FindPlayerAuraByID = ns.FindPlayerAuraByID

-- Globals
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local strformat = string.format
local insert, wipe = table.insert, table.wipe

local spec = Hekili:NewSpecialization( 263 )

spec:RegisterResource( Enum.PowerType.Maelstrom )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Shaman
    ancestral_defense         = { 92682, 382947, 1 }, -- Increases Leech by 2% and reduces damage taken from area-of-effect attacks by 2%.
    ancestral_guidance        = { 81102, 108281, 1 }, -- For the next 10 sec, 25% of your healing done and 25% of your damage done is converted to healing on up to 3 nearby injured party or raid members, up to 88,218 healing to each target per second.
    ancestral_wolf_affinity   = { 81058, 382197, 1 }, -- Cleanse Spirit, Wind Shear, Purge, and totem casts no longer cancel Ghost Wolf.
    astral_bulwark            = { 81056, 377933, 1 }, -- Astral Shift reduces damage taken by an additional 20%.
    astral_shift              = { 81057, 108271, 1 }, -- Shift partially into the elemental planes, taking 40% less damage for 12 sec.
    brimming_with_life        = { 81085, 381689, 1 }, -- Maximum health increased by 8%, and while you are at full health, Reincarnation cools down 75% faster.
    call_of_the_elements      = { 81090, 383011, 1 }, -- Reduces the cooldown of Totemic Recall by 60 sec.
    capacitor_totem           = { 81071, 192058, 1 }, -- Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after 2 sec, stunning all enemies within 8 yards for 3 sec.
    creation_core             = { 81090, 383012, 1 }, -- Totemic Recall affects an additional totem.
    earth_elemental           = { 81064, 198103, 1 }, -- Calls forth a Greater Earth Elemental to protect you and your allies for 1 min. While this elemental is active, your maximum health is increased by 15%.
    earth_shield              = { 81106, 974   , 1 }, -- Protects the target with an earthen shield, increasing your healing on them by 20% and healing them for 15,348 when they take damage. This heal can only occur once every few seconds. Maximum 9 charges. Earth Shield can only be placed on one target at a time. Only one Elemental Shield can be active on the Shaman.
    earthgrab_totem           = { 81082, 51485 , 1 }, -- Summons a totem at the target location for 20 sec. The totem pulses every 2 sec, rooting all enemies within 8 yards for 8 sec. Enemies previously rooted by the totem instead suffer 50% movement speed reduction.
    elemental_orbit           = { 81105, 383010, 1 }, -- Increases the number of Elemental Shields you can have active on yourself by 1. You can have Earth Shield on yourself and one ally at the same time.
    elemental_warding         = { 81084, 381650, 2 }, -- Reduces all magic damage taken by 2%.
    enfeeblement              = { 81078, 378079, 1 }, -- Your Hex target is slowed by 70% during Hex and for 6 sec after it ends.
    fire_and_ice              = { 81067, 382886, 1 }, -- Increases all Fire and Frost damage you deal by 3%.
    flurry                    = { 81059, 382888, 1 }, -- Increases your attack speed by 15% for your next 3 melee swings after dealing a critical strike with a spell or ability.
    frost_shock               = { 81074, 196840, 1 }, -- Chills the target with frost, causing 10,557 Frost damage and reducing the target's movement speed by 50% for 6 sec.
    go_with_the_flow          = { 81089, 381678, 2 }, -- Reduces the cooldown of Spirit Walk by 10 sec. Reduces the cooldown of Gust of Wind by 5 sec.
    graceful_spirit           = { 81065, 192088, 1 }, -- Reduces the cooldown of Spiritwalker's Grace by 30 sec and increases your movement speed by 20% while it is active.
    greater_purge             = { 81076, 378773, 1 }, -- Purges the enemy target, removing 2 beneficial Magic effects.
    guardians_cudgel          = { 81070, 381819, 1 }, -- When Capacitor Totem fades or is destroyed, another Capacitor Totem is automatically dropped in the same place.
    gust_of_wind              = { 81088, 192063, 1 }, -- A gust of wind hurls you forward.
    healing_stream_totem      = { 81100, 5394  , 1 }, -- Summons a totem at your feet for 15 sec that heals an injured party or raid member within 40 yards for 11,018 every 1.7 sec. If you already know Healing Stream Totem, instead gain 1 additional charge of Healing Stream Totem.
    hex                       = { 81079, 51514 , 1 }, -- Transforms the enemy into a frog for 1 min. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    lightning_lasso           = { 81096, 305483, 1 }, -- Grips the target in lightning, stunning and dealing 115,311 Nature damage over 5 sec while the target is lassoed. Can move while channeling.
    mana_spring               = { 81103, 381930, 1 }, -- Your Stormstrike casts restore 250 mana to you and 4 allies nearest to you within 40 yards. Allies can only benefit from one Shaman's Mana Spring effect at a time, prioritizing healers.
    natures_fury              = { 81086, 381655, 2 }, -- Increases the critical strike chance of your Nature spells and abilities by 2%.
    natures_guardian          = { 81081, 30884 , 2 }, -- When your health is brought below 35%, you instantly heal for 20% of your maximum health. Cannot occur more than once every 45 sec.
    natures_swiftness         = { 81099, 378081, 1 }, -- Your next healing or damaging Nature spell is instant cast and costs no mana.
    planes_traveler           = { 81056, 381647, 1 }, -- Reduces the cooldown of Astral Shift by 30 sec.
    poison_cleansing_totem    = { 81093, 383013, 1 }, -- Summons a totem at your feet that removes all Poison effects from a nearby party or raid member within 30 yards every 1.5 sec for 6 sec.
    purge                     = { 81076, 370   , 1 }, -- Purges the enemy target, removing 1 beneficial Magic effect.
    spirit_walk               = { 81088, 58875 , 1 }, -- Removes all movement impairing effects and increases your movement speed by 60% for 8 sec.
    spirit_wolf               = { 81072, 260878, 1 }, -- While transformed into a Ghost Wolf, you gain 5% increased movement speed and 5% damage reduction every 1 sec, stacking up to 4 times.
    spiritwalkers_aegis       = { 81065, 378077, 1 }, -- When you cast Spiritwalker's Grace, you become immune to Silence and Interrupt effects for 5 sec.
    spiritwalkers_grace       = { 81066, 79206 , 1 }, -- Calls upon the guidance of the spirits for 15 sec, permitting movement while casting Shaman spells. Castable while casting.
    static_charge             = { 81070, 265046, 1 }, -- Reduces the cooldown of Capacitor Totem by 5 sec for each enemy it stuns, up to a maximum reduction of 20 sec.
    stoneskin_totem           = { 81095, 383017, 1 }, -- Summons a totem at your feet for 15 sec that grants 10% physical damage reduction to you and the 4 allies nearest to the totem within 30 yards.
    surging_shields           = { 81092, 382033, 2 }, -- Increases the damage dealt by Lightning Shield by 50% and it has an additional 25% chance to trigger Maelstrom Weapon when triggered. Increases the healing done by Earth Shield by 12%.
    swirling_currents         = { 81101, 378094, 2 }, -- Increases the healing done by Healing Stream Totem by 160%.
    thunderous_paws           = { 81072, 378075, 1 }, -- Ghost Wolf removes snares and increases your movement speed by an additional 25% for the first 3 sec. May only occur once every 20 sec.
    thundershock              = { 81096, 378779, 1 }, -- Thunderstorm knocks enemies up instead of away and its cooldown is reduced by 5 sec.
    thunderstorm              = { 81097, 51490 , 1 }, -- Calls down a bolt of lightning, dealing 1,295 Nature damage to all enemies within 10 yards, reducing their movement speed by 40% for 5 sec, and knocking them away from the Shaman. Usable while stunned.
    totemic_focus             = { 81094, 382201, 2 }, -- Increases the radius of your totem effects by 15%. Increases the duration of your Earthbind and Earthgrab Totems by 5 sec. Increases the duration of your Healing Stream, Tremor, Poison Cleansing, and Wind Rush Totems by 1.5 sec.
    totemic_projection        = { 81080, 108287, 1 }, -- Relocates your active totems to the specified location.
    totemic_recall            = { 81091, 108285, 1 }, -- Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_surge             = { 81104, 381867, 2 }, -- Reduces the cooldown of your totems by 3 sec.
    tranquil_air_totem        = { 81095, 383019, 1 }, -- Summons a totem at your feet for 20 sec that prevents cast pushback and reduces the duration of all incoming interrupt effects by 50% for you and the 4 allies nearest to the totem within 30 yards.
    tremor_totem              = { 81069, 8143  , 1 }, -- Summons a totem at your feet that shakes the ground around it for 10 sec, removing Fear, Charm and Sleep effects from party and raid members within 30 yards.
    voodoo_mastery            = { 81078, 204268, 1 }, -- Reduces the cooldown of Hex by 15 sec.
    wind_rush_totem           = { 81082, 192077, 1 }, -- Summons a totem at the target location for 15 sec, continually granting all allies who pass within 10 yards 40% increased movement speed for 5 sec.
    wind_shear                = { 81068, 57994 , 1 }, -- Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for 2 sec.
    winds_of_alakir           = { 81087, 382215, 2 }, -- Increases the movement speed bonus of Ghost Wolf by 5%. When you have 3 or more totems active, your movement speed is increased by 7%.

    -- Enhancement
    alpha_wolf                = { 80970, 198434, 1 }, -- While Feral Spirits are active, Chain Lightning and Crash Lightning causes your wolves to attack all nearby enemies for 2,219 Physical damage every 2 sec for the next 8 sec.
    ascendance                = { 92219, 114051, 1 }, -- Transform into an Air Ascendant for 15 sec, immediately dealing 36,391 Nature damage to any enemy within 8 yds, reducing the cooldown and cost of Stormstrike by 60%, and transforming your auto attack and Stormstrike into Wind attacks which bypass armor and have a 30 yd range.
    ashen_catalyst            = { 80947, 390370, 1 }, -- Each time Flame Shock deals periodic damage, increase the damage of your next Lava Lash by 12% and reduce the cooldown of Lava Lash by 0.5 sec.
    chain_heal                = { 81063, 1064  , 1 }, -- Heals the friendly target for 30,084, then jumps up to 15 yards to heal the 3 most injured nearby allies. Healing is reduced by 30% with each jump.
    chain_lightning           = { 81061, 188443, 1 }, -- Hurls a lightning bolt at the enemy, dealing 9,833 Nature damage and then jumping to additional nearby enemies. Affects 5 total targets. If Chain Lightning hits more than 1 target, each target hit by your Chain Lightning increases the damage of your next Crash Lightning by 20%. Each target hit by Chain Lightning reduces the cooldown of Crash Lightning by 1.0 sec.
    cleanse_spirit            = { 81075, 51886 , 1 }, -- Removes all Curse effects from a friendly target.
    converging_storms         = { 80973, 384363, 1 }, -- Each target hit by Crash Lightning increases the damage of your next Stormstrike by 25%, up to a maximum of 6 stacks.
    crash_lightning           = { 80974, 187874, 1 }, -- Electrocutes all enemies in front of you, dealing 6,499 Nature damage. Hitting 2 or more targets enhances your weapons for 12 sec, causing Stormstrike, Ice Strike, and Lava Lash to also deal 6,499 Nature damage to all targets in front of you. Damage reduced beyond 6 targets.
    crashing_storms           = { 80953, 334308, 1 }, -- Crash Lightning damage increased by 40%. Chain Lightning now jumps to 2 extra targets.
    deeply_rooted_elements    = { 92219, 378270, 1 }, -- [114052] Transform into a Water Ascendant, duplicating all healing you deal at $s4% effectiveness for $114051d and immediately healing for $294020s1. Ascendant healing is distributed evenly among allies within $114083A1 yds.
    doom_winds                = { 80959, 384352, 1 }, -- Strike your target for 7,979 Physical damage, increase your chance to activate Windfury Weapon by 200%, and increases damage dealt by Windfury Weapon by 10% for 8 sec.
    elemental_assault         = { 80962, 210853, 2 }, -- Stormstrike damage is increased by $s1%, and Stormstrike, Lava Lash, and Ice Strike have a $m3% chance to generate $m2 $Lstack:stacks; of Maelstrom Weapon.
    elemental_blast           = { 80966, 117014, 1 }, -- Harnesses the raw power of the elements, dealing 27,914 Elemental damage and increasing your Critical Strike or Haste by 3% or Mastery by 6% for 10 sec. If Lava Burst is known, Elemental Blast replaces Lava Burst and gains 1 additional charge.
    elemental_spirits         = { 80970, 262624, 1 }, -- Your Feral Spirits are now imbued with Fire, Frost, or Lightning, increasing your damage dealt with that element by 20%.
    elemental_weapons         = { 80961, 384355, 2 }, -- Each active weapon imbue Increases all Fire, Frost, and Nature damage dealt by 2.5%.
    feral_lunge               = { 80946, 196884, 1 }, -- Lunge at your enemy as a ghostly wolf, biting them to deal 1,105 Physical damage.
    feral_spirit              = { 80972, 51533 , 1 }, -- Summons two Elemental Spirit Wolves that aid you in battle for 15 sec. They are immune to movement-impairing effects, and each Elemental Feral Spirit summoned grants you 20% increased Fire, Frost, or Nature damage dealt by your abilities. Feral Spirit generates one stack of Maelstrom Weapon immediately, and one stack every 3 sec for 15 sec.
    fire_nova                 = { 80944, 333974, 1 }, -- Erupt a burst of fiery damage from all targets affected by your Flame Shock, dealing 7,876 Flamestrike damage to up to 6 targets within 8 yds of your Flame Shock targets. Each eruption from Fire Nova generates 1 stack of Maelstrom Weapon.
    focused_insight           = { 80937, 381666, 1 }, -- Casting Flame Shock reduces the mana cost of your next heal by 20% and increases its healing effectiveness by 30%.
    forceful_winds            = { 80969, 262647, 1 }, -- Windfury causes each successive Windfury attack within 15 sec to increase the damage of Windfury by 20%, stacking up to 5 times.
    hailstorm                 = { 80944, 334195, 1 }, -- Each stack of Maelstrom Weapon consumed increases the damage of your next Frost Shock by 15%, and causes your next Frost Shock to hit 1 additional target per Maelstrom Weapon stack consumed, up to 5. Consuming at least 2 stacks of Hailstorm generates 1 stack of Maelstrom Weapon.
    hot_hand                  = { 80945, 201900, 2 }, -- Melee auto-attacks with Flametongue Weapon active have a 5% chance to reduce the cooldown of Lava Lash by 38% and increase the damage of Lava Lash by 50% for 8 sec.
    ice_strike                = { 80956, 342240, 1 }, -- Strike your target with an icy blade, dealing 24,828 Frost damage and snaring them by 50% for 6 sec. Ice Strike increases the damage of your next Frost Shock by 100% and generates 1 stack of Maelstrom Weapon.
    improved_maelstrom_weapon = { 80957, 383303, 2 }, -- Maelstrom Weapon now increases the damage of spells it affects by 10% per stack and the healing of spells it affects by 10% per stack.
    lashing_flames            = { 80948, 334046, 1 }, -- Lava Lash increases the damage of Flame Shock on its target by 100% for 20 sec.
    lava_burst                = { 81062, 51505 , 1 }, -- Hurls molten lava at the target, dealing 15,504 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.
    lava_lash                 = { 80942, 60103 , 1 }, -- Charges your off-hand weapon with lava and burns your target, dealing 12,946 Fire damage. Damage is increased by 100% if your offhand weapon is imbued with Flametongue Weapon. Lava Lash will spread Flame Shock from your target to 4 nearby targets. Lava Lash increases the damage of Flame Shock on its target by 100% for 20 sec.
    legacy_of_the_frost_witch = { 80951, 384450, 2 }, -- Consuming $s2 stacks of Maelstrom Weapon will reset the cooldown of Stormstrike and increases the damage of your Physical and Frost abilities by $s1% for $384451d.
    maelstrom_weapon          = { 81060, 187880, 1 }, -- When you deal damage with a melee weapon, you have a chance to gain Maelstrom Weapon, stacking up to 10 times. Each stack of Maelstrom Weapon reduces the cast time of your next damage or healing spell by 20% and increase its damage by 25% or its healing by 15%. A maximum of 10 stacks of Maelstrom Weapon can be consumed at a time.
    molten_assault            = { 80943, 334033, 2 }, -- Lava Lash cooldown reduced by 3.0 sec, and if Lava Lash is used against a target affected by your Flame Shock, Flame Shock will be spread to up to 2 enemies near the target.
    overflowing_maelstrom     = { 80938, 384149, 1 }, -- Your damage or healing spells will now consume up to 10 Maelstrom Weapon stacks.
    primal_maelstrom          = { 80964, 384405, 2 }, -- Primordial Wave generates 5 stacks of Maelstrom Weapon.
    primordial_wave           = { 80965, 375982, 1 }, -- Blast your target with a Primordial Wave, dealing $375984s1 Shadow damage and apply Flame Shock to them.; Your next $?a137040[Lava Burst]?a137041[Lightning Bolt][Healing Wave] will also hit all targets affected by your $?a137040|a137041[Flame Shock][Riptide] for $?a137039[$s2%]?a137040[$s3%][$s4%] of normal $?a137039[healing][damage].$?s384405[; Primordial Wave generates $s5 stacks of Maelstrom Weapon.][]
    raging_maelstrom          = { 80939, 384143, 1 }, -- Maelstrom Weapon can now stack 5 additional times, and Maelstrom Weapon now increases the damage of spells it affects by an additional 5% per stack and the healing of spells it affects by an additional 5% per stack.
    refreshing_waters         = { 80937, 393905, 1 }, -- Your Healing Surge is 25% more effective on yourself.
    splintered_elements       = { 80963, 382042, 1 }, -- Primordial Wave grants you $s1% Haste plus $s2% for each additional $?a137039[Healing Wave]?a137040[Lava Burst][Lightning Bolt] generated by Primordial Wave for $382043d.
    static_accumulation       = { 80950, 384411, 2 }, -- 10% chance to refund Maelstrom Weapon stacks spent on Lightning Bolt or Chain Lightning. While Ascendance is active, generate 1 Maelstrom Weapon stack every 1 sec.
    stormblast                = { 80960, 319930, 1 }, -- Stormbringer now also causes your next Stormstrike to deal 25% additional damage as Nature damage.
    stormflurry               = { 80954, 344357, 1 }, -- Stormstrike has a 25% chance to strike the target an additional time for 40% of normal damage. This effect can chain off of itself.
    storms_wrath              = { 80967, 392352, 1 }, -- Increase the chance for Mastery: Enhanced Elements to trigger Windfury and Stormbringer by 150%.
    stormstrike               = { 80941, 17364 , 1 }, -- Energizes both your weapons with lightning and delivers a massive blow to your target, dealing a total of 21,474 Physical damage.
    sundering                 = { 80975, 197214, 1 }, -- Shatters a line of earth in front of you with your main hand weapon, causing 36,783 Flamestrike damage and Incapacitating any enemy hit for 2 sec.
    swirling_maelstrom        = { 80955, 384359, 1 }, -- Consuming at least 2 stacks of Hailstorm, using Ice Strike, and each explosion from Fire Nova now also grants you 1 stack of Maelstrom Weapon.
    tempest_strikes           = { 80966, 428071, 1 }, -- Stormstrike, Ice Strike, and Lava Lash have a $h% chance to discharge electricity at your target, dealing $428078s1 Nature damage.
    thorims_invocation        = { 80949, 384444, 1 }, -- Lightning Bolt and Chain Lightning damage increased by 20%. While Ascendance is active, Windstrike automatically consumes up to 5 Maelstrom Weapon stacks to discharge a Lightning Bolt or Chain Lightning at your enemy, whichever you most recently used.
    unruly_winds              = { 80968, 390288, 1 }, -- Windfury Weapon has a 100% chance to trigger a third attack.
    windfury_totem            = { 80940, 8512  , 1 }, -- Summons a totem at your feet for 2 min. Party members within 30 yds have a 20% chance when they auto-attack to swing an extra time.
    windfury_weapon           = { 80958, 33757 , 1 }, -- Imbue your main-hand weapon with the element of Wind for 1 |4hour:hrs;. Each main-hand attack has a 27% chance to trigger two extra attacks, dealing 3,314 Physical damage each.
    witch_doctors_ancestry    = { 80971, 384447, 2 }, -- Increases the chance to gain a stack of Maelstrom Weapon by 2%, and whenever you gain a stack of Maelstrom Weapon, the cooldown of Feral Spirits is reduced by 1.0 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    burrow              = 5575, -- (409293) Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by 50% for 5 sec. When the effect ends, enemies within 6 yards are knocked in the air and take 68,767 Physical damage.
    counterstrike_totem = 3489, -- (204331) Summons a totem at your feet for 15 sec. Whenever enemies within 20 yards of the totem deal direct damage, the totem will deal 100% of the damage dealt back to attacker.
    grounding_totem     = 3622, -- (204336) Summons a totem at your feet that will redirect all harmful spells cast within 30 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts 3 sec.
    ride_the_lightning  = 721 , -- (289874) If there are more than 2 enemies within 8 yards when you cast Stormstrike, you also cast a Chain Lightning on the target, dealing 9,833 Nature damage. Otherwise, you conjure bolts of lightning to up to 2 furthest enemies within 40 yards dealing 5,209 Nature damage.
    seasoned_winds      = 5414, -- (355630) Interrupting a spell with Wind Shear decreases your damage taken from that spell school by 15% for 18 sec. Stacks up to 3 times.
    shamanism           = 722 , -- (193876) Your Bloodlust spell now has a 60 sec. cooldown, but increases Haste by 20%, and only affects you and your friendly target when cast for 10 sec. In addition, Bloodlust is no longer affected by Sated.
    skyfury_totem       = 3487, -- (204330) Summons a totem at your feet for 15 sec that increases the critical effect of damage and healing spells of all nearby allies within 40 yards by 20% for 15 sec.
    static_field_totem  = 5438, -- (355580) Summons a totem with 4% of your health at the target location for 6 sec that forms a circuit of electricity that enemies cannot pass through.
    stormweaver         = 5596, -- (410673) Maelstrom Weapon no longer benefits Healing Surge or Chain Heal. Instead, consuming Maelstrom Weapon on a damage spell causes your next Healing Surge or Chain Heal to gain 100% of the benefits of Maelstrom Weapon based on the stacks consumed.
    traveling_storms    = 5527, -- (204403) Thunderstorm now can be cast on allies within 40 yards, reduces enemies movement speed by 60% and knocks enemies 25% further. Thundershock knocks enemies 100% higher.
    unleash_shield      = 3492, -- (356736) Unleash your Elemental Shield's energy on an enemy target: Lightning Shield: Knocks them away. Earth Shield: Roots them in place for 2 sec. Water Shield: Summons a whirlpool for 6 sec, reducing damage and healing by 50% while they stand within it.
} )



-- Auras
spec:RegisterAuras( {
    -- Talent: A percentage of damage or healing dealt is copied as healing to up to 3 nearby injured party or raid members.
    -- https://wowhead.com/ptr-2/spell=108281
    ancestral_guidance = {
        id = 108281,
        duration = 10,
        tick_time = 0.5,
        max_stack = 1
    },
    -- Health increased by $s1%.    If you die, the protection of the ancestors will allow you to return to life.
    -- https://wowhead.com/ptr-2/spell=207498
    ancestral_protection = {
        id = 207498,
        duration = 30,
        max_stack = 1
    },
    -- Talent: Transformed into a powerful Air ascendant. Auto attacks have a $114089r yard range. Stormstrike is empowered and has a $114089r yard range.$?s384411[    Generating $384411s1 $lstack:stacks; of Maelstrom Weapon every $384437t1 sec.][]
    -- https://wowhead.com/ptr-2/spell=114051
    ascendance = {
        id = 114051,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Damage of your next Lava Lash increased by $s1%.
    -- https://wowhead.com/ptr-2/spell=390371
    ashen_catalyst = {
        id = 390371,
        duration = 15,
        max_stack = 8
    },
    -- Haste increased by $w1%.
    -- https://wowhead.com/ptr-2/spell=2825
    bloodlust = {
        id = 2825,
        duration = 40,
        max_stack = 1
    },
    -- Increases nature damage dealt from your abilities by $s1%.
    -- https://wowhead.com/ptr-2/spell=224127
    crackling_surge = {
        id = 224127,
        duration = 15,
        max_stack = 1
    },
    crash_lightning = {
        id = 187878,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Damage of your next Crash Lightning increased by $s1%.
    -- https://wowhead.com/ptr-2/spell=333964
    cl_crash_lightning = {
        id = 333964,
        duration = 15,
        max_stack = 6,
        copy = "converging_storms"
    },
    -- Talent: Chance to activate Windfury Weapon increased to ${$319773h}.1%.  Damage dealt by Windfury Weapon increased by $s2%.
    -- https://wowhead.com/ptr-2/spell=384352
    doom_winds_talent = {
        id = 384352,
        duration = 8,
        max_stack = 1,
    },
    doom_winds_buff = { -- legendary.
        id = 335903,
        duration = 8,
        max_stack = 1,
    },
    doom_winds_debuff = {
        id = 335904,
        duration = 60,
        max_stack = 1,
        copy = "doom_winds_cd",
    },
    doom_winds = {
        alias = { "doom_winds_talent", "doom_winds_buff" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 8,
        max_stack = 1,
    },
    -- Talent:
    -- https://wowhead.com/ptr-2/spell=198103
    earth_elemental = {
        id = 198103,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Heals for ${$w2*(1+$w1/100)} upon taking damage.
    -- https://wowhead.com/ptr-2/spell=974
    earth_shield = {
        id = 974,
        duration = 600,
        type = "Magic",
        max_stack = 9
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/ptr-2/spell=3600
    earthbind = {
        id = 3600,
        duration = 5,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Increases physical damage dealt from your abilities by $s1%.
    -- https://wowhead.com/ptr-2/spell=392375
    earthen_weapon = {
        id = 392375,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Rooted.
    -- https://wowhead.com/ptr-2/spell=64695
    earthgrab = {
        id = 64695,
        duration = 8,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Heals $w1 every $t1 sec.
    -- https://wowhead.com/ptr-2/spell=382024
    earthliving_weapon = {
        id = 382024,
        duration = 12,
        max_stack = 1
    },
    -- Your next damage or healing spell will be cast a second time ${$s2/1000}.1 sec later for free.
    -- https://wowhead.com/ptr-2/spell=320125
    echoing_shock = {
        id = 320125,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Cannot move while using Far Sight.
    -- https://wowhead.com/ptr-2/spell=6196
    far_sight = {
        id = 6196,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Generating $s1 stack of Maelstrom Weapon every $t1 sec.
    -- https://wowhead.com/ptr-2/spell=333957
    feral_spirit = {
        id = 333957,
        duration = 15,
        tick_time = 3,
        max_stack = 1,
        meta = {
            active = function( t ) return active_feral_spirits end,
        }
    },
    -- Suffering $w2 Fire damage every $t2 sec.
    -- https://wowhead.com/ptr-2/spell=188389
    flame_shock = {
        id = 188389,
        duration = 18,
        type = "Magic",
        max_stack = 1
    },
    -- Each of your weapon attacks causes up to ${$max(($<coeff>*$AP),1)} additional Fire damage.
    -- https://wowhead.com/ptr-2/spell=319778
    flametongue_weapon = {
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Attack speed increased by $w1%.
    -- https://wowhead.com/ptr-2/spell=382889
    flurry = {
        id = 382889,
        duration = 15,
        max_stack = 3
    },
    -- Talent: The mana cost of your next heal is reduced by $w1% and its effectiveness is increased by $?s137039[${$W2}.1][$w2]%.
    -- https://wowhead.com/ptr-2/spell=381668
    focused_insight = {
        id = 381668,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/ptr-2/spell=196840
    frost_shock = {
        id = 196840,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    converging_storms = {
        id = 198300,
        duration = 12,
        max_stack = 1,
    },
    -- Increases movement speed by $?s382215[${$382216s1+$w2}][$w2]%.$?$w3!=0[  Less hindered by effects that reduce movement speed.][]
    -- https://wowhead.com/ptr-2/spell=2645
    ghost_wolf = {
        id = 2645,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Frost Shock will deal $s1% additional damage, and hit up to ${$334195s1/$s2} additional $Ltarget:targets;.
    -- https://wowhead.com/ptr-2/spell=334196
    hailstorm = {
        id = 334196,
        duration = 20,
        max_stack = 5
    },
    -- Your Healing Rain is currently active.  $?$w1!=0[Magic damage taken reduced by $w1%.][]
    -- https://wowhead.com/ptr-2/spell=73920
    healing_rain = {
        id = 73920,
        duration = 10,
        max_stack = 1
    },
    -- Healing $?s147074[two injured party or raid members][an injured party or raid member] every $t1 sec.
    -- https://wowhead.com/ptr-2/spell=5672
    healing_stream = {
        id = 5672,
        duration = 15,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/ptr-2/spell=51514
    hex = {
        id = 51514,
        duration = 60,
        mechanic = "polymorph",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Lava Lash damage increased by $s1% and cooldown reduced by ${$s2/4}%.
    -- https://wowhead.com/ptr-2/spell=215785
    hot_hand = {
        id = 215785,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/ptr-2/spell=342240
    ice_strike_snare = {
        id = 342240,
        duration = 6,
        max_stack = 1,
    },
    -- Talent: Damage of your next Frost Shock increased by $s1%.
    -- https://wowhead.com/ptr-2/spell=384357
    ice_strike = {
        id = 384357,
        duration = 12,
        max_stack = 1
    },
    -- Frost Shock damage increased by $w2%.
    -- https://wowhead.com/ptr-2/spell=210714
    icefury = {
        id = 210714,
        duration = 25,
        type = "Magic",
        max_stack = 4
    },
    -- Increases frost damage dealt from your abilities by $s1%.
    -- https://wowhead.com/ptr-2/spell=224126
    icy_edge = {
        id = 224126,
        duration = 15,
        max_stack = 1
    },
    -- Fire damage inflicted every $t2 sec.
    -- https://wowhead.com/ptr-2/spell=118297
    immolate = {
        id = 118297,
        duration = 21,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage taken from the Shaman's Flame Shock increased by $s1%.
    -- https://wowhead.com/ptr-2/spell=334168
    lashing_flames = {
        id = 334168,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Damage dealt by your physical abilities increased by $w1%.
    -- https://wowhead.com/ptr-2/spell=384451
    legacy_of_the_frost_witch = {
        id = 384451,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Stunned. Suffering $w1 Nature damage every $t1 sec.
    -- https://wowhead.com/ptr-2/spell=305485
    lightning_lasso = {
        id = 305485,
        duration = 5,
        tick_time = 1,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Chance to deal $192109s1 Nature damage when you take melee damage$?a137041[ and have a $s3% chance to generate a stack of Maelstrom Weapon]?a137040[ and have a $s4% chance to generate $s5 Maelstrom][].
    -- https://wowhead.com/ptr-2/spell=192106
    lightning_shield = {
        id = 192106,
        duration = 1800,
        max_stack = 1
    },
    -- Talent: Your next damage or healing spell has its cast time reduced by ${$max($187881s1, -100)*-1}%$?s383303[ and damage or healing increased by][]$?s383303&!s384149[ ${$min($187881w2, 5*$s~2)}%]?s383303&s384149[ $187881w2%][].
    -- https://wowhead.com/ptr-2/spell=344179
    maelstrom_weapon = {
        id = 344179,
        duration = 30,
        type = "Magic",
        max_stack = function() return talent.raging_maelstrom.enabled and 10 or 5 end
    },
    -- Increases fire damage dealt from your abilities by $s1%.
    -- https://wowhead.com/ptr-2/spell=224125
    molten_weapon = {
        id = 224125,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next healing or damaging Nature spell is instant cast and costs no mana.
    -- https://wowhead.com/ptr-2/spell=378081
    natures_swiftness = {
        id = 378081,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        onRemove = function( t )
            -- 20221117:  This function is triggered when the buff is removed.
            setCooldown( "natures_swiftness", action.natures_swiftness.cooldown )
        end
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/ptr-2/spell=280205
    pack_spirit = {
        id = 280205,
        duration = 3600,
        max_stack = 1
    },
    -- Cleansing $383015s1 poison effect from a nearby party or raid member every $t1 sec.
    -- https://wowhead.com/ptr-2/spell=383014
    poison_cleansing = {
        id = 383014,
        duration = 6,
        tick_time = 1.5,
        type = "Magic",
        max_stack = 1
    },
    primal_lava_actuators = {
        id = 335896,
        duration = 15,
        max_stack = 20,
    },
    primordial_wave = {
        id = 375986,
        duration = 10,
        max_stack = 1,
        copy = 327164
    },
    -- Heals $w2 every $t2 seconds.
    -- https://wowhead.com/ptr-2/spell=61295
    riptide = {
        id = 61295,
        duration = 18,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Increases movement speed by $s1%.
    -- https://wowhead.com/ptr-2/spell=58875
    spirit_walk = {
        id = 58875,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Able to move while casting all Shaman spells.
    -- https://wowhead.com/ptr-2/spell=79206
    spiritwalkers_grace = {
        id = 79206,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/ptr-2/spell=118905
    static_charge = {
        id = 118905,
        duration = 3,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Stormstrike cooldown has been reset$?$?a319930[ and will deal $319930w1% additional damage as Nature][].
    -- https://wowhead.com/ptr-2/spell=201846
    stormbringer = {
        id = 201846,
        duration = 12,
        max_stack = 1
    },
    -- Your next Lightning Bolt or Chain Lightning will deal $s2% increased damage and be instant cast.
    -- https://wowhead.com/ptr-2/spell=383009
    stormkeeper = {
        id = 383009,
        duration = 15,
        type = "Magic",
        max_stack = 2,
        copy = 320137
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/ptr-2/spell=197214
    sundering = {
        id = 197214,
        duration = 2,
        max_stack = 1
    },
    -- Talent: Movement speed increased by $378075s1%.
    -- https://wowhead.com/ptr-2/spell=378076
    thunderous_paws = {
        id = 378076,
        duration = 3,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s3%.
    -- https://wowhead.com/ptr-2/spell=51490
    thunderstorm = {
        id = 51490,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Your next healing spell has increased effectiveness.
    -- https://wowhead.com/ptr-2/spell=73685
    unleash_life = {
        id = 73685,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    windfury_totem = {
        id = 327942,
        duration = 120,
        max_stack = 1,
        shared = "player"
    },
    windfury_weapon = {
        duration = 3600,
        max_stack = 1,
    },

    chains_of_devastation_cl = {
        id = 336736,
        duration = 20,
        max_stack = 1,
    },
    chains_of_devastation_ch = {
        id = 336737,
        duration = 20,
        max_stack = 1
    },
} )




spec:RegisterStateTable( "feral_spirit", setmetatable( {}, {
    __index = function( t, k )
        return buff.feral_spirit[ k ]
    end
} ) )

spec:RegisterStateTable( "twisting_nether", setmetatable( { onReset = function( self ) end }, {
    __index = function( t, k )
        if k == "count" then
            return ( buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( buff.shock_of_the_twisting_nether.up and 1 or 0 )
        end

        return 0
    end
} ) )


local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES         = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

local vesper_heal = 0
local vesper_damage = 0
local vesper_used = 0

local vesper_expires = 0
local vesper_guid
local vesper_last_proc = 0

local last_totem_actual = 0

local recall_totems = {
    capacitor_totem = 1,
    earthbind_totem = 1,
    earthgrab_totem = 1,
    grounding_totem = 1,
    healing_stream_totem = 1,
    liquid_magma_totem = 1,
    poison_cleansing_totem = 1,
    skyfury_totem = 1,
    stoneskin_totem = 1,
    tranquil_air_totem = 1,
    tremor_totem = 1,
    wind_rush_totem = 1,
}

local recallTotem1
local recallTotem2

local actual_spirits = {}

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    -- Deaths/despawns.
    if death_events[ subtype ] and destGUID == vesper_guid then
        vesper_guid = nil
        return
    end

    if sourceGUID == state.GUID then
        -- Summons.
        if subtype == "SPELL_SUMMON" then
            if spellID == 262627 then
                actual_spirits[ destGUID ] = {
                    expires = GetTime() + 15,
                    alpha_expires = 0
                }

                C_Timer.After( 15, function()
                    actual_spirits[ destGUID ] = nil
                end )

            elseif spellID == 324386 then
                vesper_guid = destGUID
                vesper_expires = GetTime() + 30

                vesper_heal = 3
                vesper_damage = 3
                vesper_used = 0
            end

        -- For any Maelstrom Weapon changes, force an immediate update for responsiveness.
        elseif spellID == 344179 then
            Hekili:ForceUpdate( subtype, true )

        elseif state.talent.alpha_wolf.enabled and ( spellID == 187874 or spellID == 188443 ) then
            local expires = GetTime() + 8

            for k, v in pairs( actual_spirits ) do
                v.alpha_expires = expires
            end

            -- Vesper Totem heal
        elseif spellID == 324522 then
            local now = GetTime()

            if vesper_last_proc + 0.75 < now then
                vesper_last_proc = now
                vesper_used = vesper_used + 1
                vesper_heal = vesper_heal - 1
            end

        -- Vesper Totem damage; only fires on SPELL_DAMAGE...
        elseif spellID == 324520 then
            local now = GetTime()

            if vesper_last_proc + 0.75 < now then
                vesper_last_proc = now
                vesper_used = vesper_used + 1
                vesper_damage = vesper_damage - 1
            end

        end

        if subtype == "SPELL_CAST_SUCCESS" then
            -- Reset in case we need to deal with an instant after a hardcast.
            vesper_last_proc = 0

            local ability = class.abilities[ spellID ]
            local key = ability and ability.key

            if key and recall_totems[ key ] then
                recallTotem2 = recallTotem1
                recallTotem1 = key
            end
        end
    end
end )

spec:RegisterStateExpr( "vesper_totem_heal_charges", function()
    return vesper_heal
end )

spec:RegisterStateExpr( "vesper_totem_dmg_charges", function ()
    return vesper_damage
end )

spec:RegisterStateExpr( "vesper_totem_used_charges", function ()
    return vesper_used
end )

spec:RegisterStateFunction( "trigger_vesper_heal", function ()
    if vesper_totem_heal_charges > 0 then
        vesper_totem_heal_charges = vesper_totem_heal_charges - 1
        vesper_totem_used_charges = vesper_totem_used_charges + 1
    end
end )

spec:RegisterStateFunction( "trigger_vesper_damage", function ()
    if vesper_totem_dmg_charges > 0 then
        vesper_totem_dmg_charges = vesper_totem_dmg_charges - 1
        vesper_totem_used_charges = vesper_totem_used_charges + 1
    end
end )


local virtual_spirits = {}

spec:RegisterStateExpr( "active_feral_spirits", function()
    local count = 0

    for _, v in pairs( virtual_spirits ) do
        if v.expires > query_time then count = count + 1 end
    end

    return count
end )

spec:RegisterStateExpr( "alpha_wolf_min_remains", function()
    local minimum

    for _, v in pairs( virtual_spirits ) do
        if v.expires > query_time then
            local remains = max( 0, v.alpha_expires - query_time )
            if remains == 0 then return 0 end
            if not minimum then minimum = remains
            else minimum = min( minimum, remains ) end
        end
    end

    return minimum or 0
end )


local TriggerFeralMaelstrom = setfenv( function()
    gain_maelstrom( 1 )
end, state )

local TriggerStaticAccumulation = setfenv( function()
    gain_maelstrom( 1 )
end, state )


local tiSpell = "lightning_bolt"

spec:RegisterStateExpr( "ti_lightning_bolt", function ()
    return tiSpell == "lightning_bolt"
end)

spec:RegisterStateExpr( "ti_chain_lightning", function ()
    return tiSpell == "chain_lightning"
end)


spec:RegisterHook( "reset_precast", function ()
    local mh, _, _, mh_enchant, oh, _, _, oh_enchant = GetWeaponEnchantInfo()

    if mh and mh_enchant == 5401 then applyBuff( "windfury_weapon" ) end
    if oh and oh_enchant == 5400 then applyBuff( "flametongue_weapon" ) end

    if buff.windfury_totem.down and ( now - action.windfury_totem.lastCast < 1 or totem.windfury_totem.remains > 10 and now - action.totemic_projection.lastCast < 1 ) then
        applyBuff( "windfury_totem" )
    end


    if buff.windfury_totem.up and pet.windfury_totem.up then
        buff.windfury_totem.expires = pet.windfury_totem.expires
    end

    if buff.windfury_weapon.down and ( now - action.windfury_weapon.lastCast < 1 ) then applyBuff( "windfury_weapon" ) end
    if buff.flametongue_weapon.down and ( now - action.flametongue_weapon.lastCast < 1 ) then applyBuff( "flametongue_weapon" ) end

    if settings.pad_windstrike and cooldown.windstrike.remains > 0 then
        reduceCooldown( "windstrike", latency * 2 )
    end

    if settings.pad_lava_lash and cooldown.lava_lash.remains > 0 and buff.hot_hand.up then
        reduceCooldown( "lava_lash", latency * 2 )
    end

    if action.windfury_totem.lastCast < 1 and buff.windfury_totem.down then
        applyBuff( "windfury_totem" )
    end

    if vesper_expires > 0 and now > vesper_expires then
        vesper_expires = 0
        vesper_heal = 0
        vesper_damage = 0
        vesper_used = 0
    end

    vesper_totem_heal_charges = nil
    vesper_totem_dmg_charges = nil
    vesper_totem_used_charges = nil

    if totem.vesper_totem.up then
        applyBuff( "vesper_totem", totem.vesper_totem.remains )
    end

    if buff.feral_spirit.up then
        local next_mw = query_time + 3 - ( ( query_time - buff.feral_spirit.applied ) % 3 )

        while ( next_mw <= buff.feral_spirit.expires ) do
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, next_mw, "AURA_PERIODIC" )
            next_mw = next_mw + 3
        end

        if talent.alpha_wolf.enabled then
            local last_trigger = max( action.chain_lightning.lastCast, action.crash_lightning.lastCast )

            if last_trigger > buff.feral_spirit.applied then
                applyBuff( "alpha_wolf", last_trigger + 8 - now )
            end
        end
    end

    wipe( virtual_spirits )
    for k, v in pairs( actual_spirits ) do
        if v.expires > now then
            virtual_spirits[ k ] = {
                expires = v.expires,
                alpha_expires = v.alpha_expires
            }
        end
    end

    if buff.ascendance.up and talent.static_accumulation.enabled then
        local next_mw = query_time + 1 - ( ( query_time - buff.ascendance.applied ) % 1 )

        while ( next_mw <= buff.ascendance.expires ) do
            state:QueueAuraEvent( "ascendance_maelstrom", TriggerStaticAccumulation, next_mw, "AURA_PERIODIC" )
            next_mw = next_mw + 1
        end
    end

    tiSpell = action.chain_lightning.lastCast > action.lightning_bolt.lastCast and "chain_lightning" or "lightning_bolt"

    rawset( buff, "doom_winds_debuff", debuff.doom_winds_debuff )
    rawset( buff, "doom_winds_cd", debuff.doom_winds_debuff )
end )


local ancestral_wolf_affinity_spells = {
    cleanse_spirit = 1,
    wind_shear = 1,
    purge = 1,
    -- TODO: List totems?
}

spec:RegisterStateExpr( "recall_totem_1", function()
    return recallTotem1
end )

spec:RegisterStateExpr( "recall_totem_2", function()
    return recallTotem2
end )

spec:RegisterHook( "runHandler", function( action )
    if buff.ghost_wolf.up then
        if talent.ancestral_wolf_affinity.enabled then
            local ability = class.abilities[ action ]
            if not ancestral_wolf_affinity_spells[ action ] and not ability.gcd == "totem" then
                removeBuff( "ghost_wolf" )
                removeBuff( "spirit_wolf" )
            end
        else
            removeBuff( "ghost_wolf" )
            removeBuff( "spirit_wolf" )
        end
    end

    if talent.totemic_recall.enabled and recall_totems[ action ] then
        recall_totem_2 = recall_totem_1
        recall_totem_1 = action
    end
end )


spec:RegisterGear( "tier29", 200396, 200398, 200400, 200401, 200399 )
spec:RegisterAuras( {
    maelstrom_of_elements = {
        id = 394677,
        duration = 15,
        max_stack = 1
    },
    fury_of_the_storm = {
        id = 396006,
        duration = 3,
        max_stack = 10
    }
} )

-- Tier 30
spec:RegisterGear( "tier30", 202473, 202471, 202470, 202469, 202468 )
spec:RegisterAuras( {
    earthen_might = {
        id = 409689,
        duration = 15,
        max_stack = 1,
        copy = "t30_2pc_enh"
    },
    volcanic_strength = {
        id = 409833,
        duration = 15,
        max_stack = 1,
        copy = "t30_4pc_enh_damage"
    },
    crackling_thunder = {
        id = 409834,
        duration = 15,
        max_stack = 2,
        copy = "t30_4pc_enh_cl"
    }
} )

spec:RegisterGear( "tier31", 207207, 207208, 207209, 207210, 207212 )


spec:RegisterGear( "waycrest_legacy", 158362, 159631 )
spec:RegisterGear( "electric_mail", 161031, 161034, 161032, 161033, 161035 )

spec:RegisterStateFunction( "consume_maelstrom", function( cap )
    local stacks = min( buff.maelstrom_weapon.stack, cap or ( talent.overflowing_maelstrom.enabled and 10 or 5 ) )

    if talent.hailstorm.enabled and stacks > buff.hailstorm.stack then
        applyBuff( "hailstorm", nil, stacks )
    end

    removeStack( "maelstrom_weapon", stacks )
    if set_bonus.tier29_4pc > 0 then addStack( "fury_of_the_storm", nil, stacks ) end

    -- TODO: Have to actually track consumed MW stacks.
    if legendary.legacy_oF_the_frost_witch.enabled and stacks > 4 or talent.legacy_of_the_frost_witch.enabled and stacks > 9 then
        setCooldown( "stormstrike", 0 )
        setCooldown( "windstrike", 0 )
        applyBuff( "legacy_of_the_frost_witch" )
    end
end )

spec:RegisterStateFunction( "gain_maelstrom", function( stacks )
    if talent.witch_doctors_ancestry.enabled and not action.feral_spirit.disabled then
        reduceCooldown( "feral_spirit", stacks * talent.witch_doctors_ancestry.rank )
    end

    addStack( "maelstrom_weapon", nil, stacks )
end )

spec:RegisterStateFunction( "maelstrom_mod", function( amount )
    local mod = max( 0, 1 - ( 0.2 * buff.maelstrom_weapon.stack ) )
    return mod * amount
end )

spec:RegisterTotem( "counterstrike_totem", 511726 )
spec:RegisterTotem( "poison_cleansing_totem", 136070 )
spec:RegisterTotem( "skyfury_totem", 135829 )
spec:RegisterTotem( "stoneskin_totem", 4667425 )
spec:RegisterTotem( "windfury_totem", 136114 )


-- Abilities
spec:RegisterAbilities( {
    -- Talent: For the next $d, $s1% of your damage and healing is converted to healing on up to 3 nearby injured party or raid members.
    ancestral_guidance = {
        id = 108281,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        school = "nature",

        talent = "ancestral_guidance",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "ancestral_guidance" )
        end,
    },

    -- Talent: Transform into an Air Ascendant for $114051d, immediately dealing $344548s1 Nature damage to any enemy within $344548A1 yds, reducing the cooldown and cost of Stormstrike by $s4%, and transforming your auto attack and Stormstrike into Wind attacks which bypass armor and have a $114089r yd range.$?s384411[    While Ascendance is active, generate $s1 Maelstrom Weapon $lstack:stacks; every $384437t1 sec.][]
    ascendance = {
        id = 114051,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        school = "nature",

        talent = "ascendance",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            -- trigger ascendance [344548], windstrike [115356]
            applyBuff( "ascendance" )
            if talent.static_accumulation.enabled then
                for i = 1, 15 do
                    state:QueueAuraEvent( "ascendance_maelstrom", TriggerStaticAccumulation, query_time + i, "AURA_PERIODIC" )
                end
            end
        end,
    },

    -- Talent: Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after $s2 sec, stunning all enemies within $118905A1 yards for $118905d.
    capacitor_totem = {
        id = 192058,
        cast = 0,
        cooldown = function () return 60 - 3 * talent.totemic_surge.rank + conduit.totemic_surge.mod * 0.001 end,
        gcd = "totem",
        school = "nature",

        spend = 0.1,
        spendType = "mana",

        talent = "capacitor_totem",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "capacitor_totem" )
        end,
    },

    -- Talent: Heals the friendly target for $s1, then jumps to heal the $<jumps> most injured nearby allies. Healing is reduced by $s2% with each jump.
    chain_heal = {
        id = 1064,
        cast = function ()
            if buff.chains_of_devastation_ch.up then return 0 end
            if buff.natures_swiftness.up then return 0 end
            return 2.5 * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return buff.natures_swiftness.up and 0 or 0.15 end,
        spendType = "mana",

        talent = "chain_heal",
        startsCombat = false,

        handler = function ()
            consume_maelstrom()

            removeBuff( "chains_of_devastation_ch" )
            removeBuff( "natures_swiftness" )
            removeBuff( "focused_insight" )

            if legendary.chains_of_devastation.enabled then
                applyBuff( "chains_of_devastation_cl" )
            end

            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },

    -- Talent: Hurls a lightning bolt at the enemy, dealing $s1 Nature damage and then jumping to additional nearby enemies. Affects $x1 total targets.$?s187874[    If Chain Lightning hits more than 1 target, each target hit by your Chain Lightning increases the damage of your next Crash Lightning by $333964s1%.][]$?s187874[    Each target hit by Chain Lightning reduces the cooldown of Crash Lightning by ${$s3/1000}.1 sec.][]$?a343725[    |cFFFFFFFFGenerates $343725s5 Maelstrom per target hit.|r][]
    chain_lightning = {
        id = 188443,
        cast = function ()
            if buff.chains_of_devastation_cl.up then return 0 end
            if buff.natures_swiftness.up then return 0 end
            if buff.stormkeeper.up then return 0 end
            return ( talent.unrelenting_calamity.enabled and 1.75 or 2 ) * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return buff.natures_swiftness.up and 0 or 0.01 end,
        spendType = "mana",

        talent = "chain_lightning",
        startsCombat = true,

        handler = function ()
            local refund = ceil( buff.maelstrom_weapon.stack * 0.5 )
            consume_maelstrom()

            if set_bonus.tier30_2pc > 1 then applyBuff( "maelstrom_weapon", nil, refund ) end

            removeBuff( "chains_of_devastation_cl" )
            removeBuff( "natures_swiftness" ) -- TODO: Determine order of instant cast effect consumption.
            removeBuff( "master_of_the_elements" )

            if legendary.chains_of_devastation.enabled then
                applyBuff( "chains_of_devastation_ch" )
            end

            if talent.crash_lightning.enabled then
                if true_active_enemies > 1 then applyBuff( "cl_crash_lightning", nil, min( talent.crashing_storms.enabled and 5 or 3, true_active_enemies ) ) end
                reduceCooldown( "crash_lightning", min( talent.crashing_storms.enabled and 5 or 3, true_active_enemies ) )
            end

            if talent.alpha_wolf.enabled then
                for _, v in pairs( virtual_spirits ) do
                    if v.expires > query_time then
                        v.alpha_expires = min( v.expires, query_time + 8 )
                    end
                end
            end

            removeStack( "stormkeeper" )

            if pet.storm_elemental.up then
                addStack( "wind_gust" )
            end

            if buff.feral_spirit.up and talent.alpha_wolf.enabled then
                applyBuff( "alpha_wolf" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end

            tiSpell = "chain_lightning"
        end,
    },


    counterstrike_totem = {
        id = 204331,
        cast = 0,
        cooldown = function () return 45 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "counterstrike_totem",

        startsCombat = false,
        texture = 511726,

        handler = function ()
            summonPet( "counterstrike_totem" )
        end,
    },

    -- Talent: Electrocutes all enemies in front of you, dealing ${$s1*$<CAP>/$AP} Nature damage. Hitting 2 or more targets enhances your weapons for $187878d, causing Stormstrike, Ice Strike, and Lava Lash to also deal ${$195592s1*$<CAP>/$AP} Nature damage to all targets in front of you. Damage reduced beyond $s2 targets.$?s384363[    Each target hit by Crash Lightning increases the damage of your next Stormstrike by $198300s1%, up to a maximum of $198300u stacks.][]
    crash_lightning = {
        id = 187874,
        cast = 0,
        cooldown = 12,
        gcd = "spell",
        school = "nature",

        spend = 0.01,
        spendType = "mana",

        talent = "crash_lightning",
        startsCombat = true,

        handler = function ()
            if active_enemies > 1 then
                applyBuff( "crash_lightning" )
            end

            removeBuff( "crashing_lightning" )
            removeBuff( "cl_crash_lightning" )

            if buff.feral_spirit.up and talent.alpha_wolf.enabled then
                applyBuff( "alpha_wolf" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end

            if talent.converging_storms.enabled then
                applyBuff( "converging_storms", nil, min( 6, active_enemies ) )
            end

            if talent.alpha_wolf.enabled then
                for _, v in pairs( virtual_spirits ) do
                    if v.expires > query_time then
                        v.alpha_expires = min( v.expires, query_time + 8 )
                    end
                end
            end
        end,
    },

    -- Talent: Strike your target for $s3 Physical damage, increase your chance to activate Windfury Weapon by $s1%, and increases damage dealt by Windfury Weapon by $s2% for $d.
    doom_winds = {
        id = 384352,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        school = "physical",

        talent = "doom_winds",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "doom_winds" )
            -- TODO: See how/if the legacy legendary works in 10.0.
        end,
    },

    -- Talent: Calls forth a Greater Earth Elemental to protect you and your allies for $188616d.    While this elemental is active, your maximum health is increased by $381755s1%.
    earth_elemental = {
        id = 198103,
        cast = 0,
        cooldown = 300,
        gcd = "spell",
        school = "nature",

        talent = "earth_elemental",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            summonPet( "greater_earth_elemental", 60 )
            if conduit.vital_accretion.enabled then
                applyBuff( "vital_accretion" )
                health.max = health.max * ( 1 + ( conduit.vital_accretion.mod * 0.01 ) )
            end
        end,
    },

    -- Talent: Protects the target with an earthen shield, increasing your healing on them by $s1% and healing them for ${$379s1*(1+$s1/100)} when they take damage. This heal can only occur once every few seconds. Maximum $n charges.    $?s383010[Earth Shield can only be placed on the Shaman and one other target at a time. The Shaman can have up to two Elemental Shields active on them.][Earth Shield can only be placed on one target at a time. Only one Elemental Shield can be active on the Shaman.]
    earth_shield = {
        id = 974,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.05,
        spendType = "mana",

        talent = "earth_shield",
        startsCombat = false,

        timeToReady = function () return buff.earth_shield.remains - 120 end,

        handler = function ()
            applyBuff( "earth_shield" )
            if talent.elemental_orbit.rank == 0 then removeBuff( "lightning_shield" ) end

            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },

    -- Talent: Summons a totem at the target location for $d. The totem pulses every $116943t1 sec, rooting all enemies within $64695A1 yards for $64695d. Enemies previously rooted by the totem instead suffer $116947s1% movement speed reduction.
    earthgrab_totem = {
        id = 51485,
        cast = 0,
        cooldown = function () return 30 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.025,
        spendType = "mana",

        talent = "earthgrab_totem",
        startsCombat = true,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "earthgrab_totem" )
        end,
    },

    -- Talent: Harnesses the raw power of the elements, dealing $s1 Elemental damage and increasing your Critical Strike or Haste by $118522s1% or Mastery by ${$173184s1*$168534bc1}% for $118522d.$?s137041[    If Lava Burst is known, Elemental Blast replaces Lava Burst and gains $394152s2 additional $Lcharge:charges;.][]
    elemental_blast = {
        id = 117014,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return maelstrom_mod( 2 ) * haste
        end,
        flash = { 51505, 394150 },
        charges = function() if talent.lava_burst.enabled then return 2 end end,
        cooldown = 12,
        recharge = function() if talent.lava_burst.enabled then return 12 end end,
        gcd = "spell",
        school = "elemental",

        spend = 0.0280,
        spendType = "mana",

        talent = "elemental_blast",
        startsCombat = false,

        handler = function ()
            consume_maelstrom()

            removeBuff( "natures_swiftness" )
            applyBuff( "elemental_blast" )

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        bind = "lava_burst"
    },

    -- Changes your viewpoint to the targeted location for $d.
    far_sight = {
        id = 6196,
        cast = 2,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyBuff( "far_sight" )
        end,
    },

    -- Talent: Lunge at your enemy as a ghostly wolf, biting them to deal $215802s1 Physical damage.
    feral_lunge = {
        id = 196884,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        school = "physical",

        talent = "feral_lunge",
        startsCombat = true,

        min_range = 8,
        max_range = 25,

        handler = function ()
            setDistance( 5 )
        end,
    },

    -- Talent: Summons two $?s262624[Elemental ][]Spirit $?s147783[Raptors][Wolves] that aid you in battle for $228562d. They are immune to movement-impairing effects, and each $?s262624[Elemental ][]Feral Spirit summoned grants you $?s262624[$224125s1%][$392375s1%] increased $?s262624[Fire, Frost, or Nature][Physical] damage dealt by your abilities.    Feral Spirit generates one stack of Maelstrom Weapon immediately, and one stack every $333957t1 sec for $333957d.
    feral_spirit = {
        id = 51533,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( 90 - ( talent.elemental_spirits.enabled and 30 or 0 ) ) end,
        gcd = "spell",
        school = "nature",

        talent = "feral_spirit",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            -- instant MW stack?
            applyBuff( "feral_spirit" )

            insert( virtual_spirits, {
                expires = query_time + 15,
                alpha_expires = 0
            } )

            insert( virtual_spirits, {
                expires = query_time + 15,
                alpha_expires = 0
            } )

            if set_bonus.tier31_4pc > 0 then
                reduceCooldown( "primordial_wave", 14 )
            end

            gain_maelstrom( 1 )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 3, "AURA_PERIODIC" )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 6, "AURA_PERIODIC" )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 9, "AURA_PERIODIC" )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 12, "AURA_PERIODIC" )
            state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 15, "AURA_PERIODIC" )
        end
    },

    -- Talent: Erupt a burst of fiery damage from all targets affected by your Flame Shock, dealing $333977s1 Fire damage to up to $333977I targets within $333977A1 yds of your Flame Shock targets.$?s384359[    Each eruption from Fire Nova generates $384359s1 $Lstack:stacks; of Maelstrom Weapon.][]
    fire_nova = {
        id = 333974,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "fire",

        spend = 0.01,
        spendType = "mana",

        talent = "fire_nova",
        startsCombat = true,

        usable = function() return active_dot.flame_shock > 0, "requires active flame_shock" end,

        handler = function ()
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            if talent.swirling_maelstrom.enabled then
                gain_maelstrom( min( 6, active_dot.flame_shock ) + ( buff.maelstrom_of_elements.up and 1 or 0 ) )
            end
            removeBuff( "maelstrom_of_elements" )
        end,
    },

    -- Sears the target with fire, causing $s1 Fire damage and then an additional $o2 Fire damage over $d.    Flame Shock can be applied to a maximum of $I targets.
    flame_shock = {
        id = 188389,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",
        school = "fire",

        spend = 0.015,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "flame_shock" )
            if talent.focused_insight.enabled then applyBuff( "focused_insight" ) end
            if talent.primal_lava_actuators.enabled then addStack( "primal_lava_actuators_df" ) end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Imbue your $?s33757[off-hand ][]weapon with the element of Fire for $319778d, causing each of your attacks to deal ${$max(($<coeff>*$AP),1)} additional Fire damage$?s382027[ and increasing the damage of your Fire spells by $382028s1%][].
    flametongue_weapon = {
        id = 318038,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        startsCombat = false,
        nobuff = "flametongue_weapon",
        essential = true,

        usable = function () return off_hand.size > 0, "requires an offhand weapon" end,
        handler = function ()
            applyBuff( "flametongue_weapon" )
        end,
    },

    -- Talent: Chills the target with frost, causing $s1 Frost damage and reducing the target's movement speed by $s2% for $d.
    frost_shock = {
        id = 196840,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",
        school = "frost",

        spend = 0.01,
        spendType = "mana",

        talent = "frost_shock",
        startsCombat = false,

        handler = function ()
            if buff.hailstorm.up then
                if talent.swirling_maelstrom.enabled and buff.hailstorm.stack > 1 then gain_maelstrom( 1 + ( buff.maelstrom_of_elements.up and 1 or 0 ) ) end
                removeBuff( "hailstorm" )
            end

            removeBuff( "ice_strike_buff" )
            removeBuff( "maelstrom_of_elements" )

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Turn into a Ghost Wolf, increasing movement speed by $?s382215[${$s2+$382216s1}][$s2]% and preventing movement speed from being reduced below $s3%.
    ghost_wolf = {
        id = 2645,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyBuff( "ghost_wolf" )
            if conduit.thunderous_paws.enabled then applyBuff( "thunderous_paws_sl" ) end
            if talent.thunderous_paws.enabled and query_time - buff.thunderous_paws_df.lastApplied > 20 then
                applyBuff( "thunderous_paws_df" )
                if debuff.snared.up then removeDebuff( "player", "snared" ) end
            end
        end,
    },

    -- Talent: Purges the enemy target, removing $m1 beneficial Magic effects.
    greater_purge = {
        id = 378773,
        cast = 0,
        cooldown = 12,
        gcd = "spell",
        school = "nature",

        spend = 0.21,
        spendType = "mana",

        talent = "greater_purge",
        startsCombat = true,
        toggle = "interrupts",
        debuff = "dispellable_magic",

        handler = function ()
            removeDebuff( "target", "dispellable_magic" )
        end,
    },

    -- Talent: A gust of wind hurls you forward.
    gust_of_wind = {
        id = 192063,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "nature",

        talent = "gust_of_wind",
        startsCombat = false,

        toggle = "interrupts",
        debuff = "dispellable_magic",

        handler = function ()
            removeDebuff( "target", "dispellable_magic" )
        end,
    },

    -- Talent: Summons a totem at your feet for $d that heals $?s147074[two injured party or raid members][an injured party or raid member] within $52042A1 yards for $52042s1 every $5672t1 sec.    If you already know $?s157153[$@spellname157153][$@spellname5394], instead gain $392915s1 additional $Lcharge:charges; of $?s157153[$@spellname157153][$@spellname5394].
    healing_stream_totem = {
        id = 5394,
        cast = 0,
        cooldown = function () return 30 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.05,
        spendType = "mana",

        talent = "healing_stream_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "healing_stream_totem" )
            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },

    -- A quick surge of healing energy that restores $s1 of a friendly target's health.
    healing_surge = {
        id = 8004,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return maelstrom_mod( 1.5 ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return buff.natures_swiftness.up and 0 or maelstrom_mod( 0.10 ) end,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            consume_maelstrom()

            removeBuff( "natures_swiftness" )
            removeBuff( "focused_insight" )

            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end
    },

    -- Talent: Strike your target with an icy blade, dealing $s1 Frost damage and snaring them by $s2% for $d.    Ice Strike increases the damage of your next Frost Shock by $384357s1%$?s384359[ and generates $384359s1 $Lstack:stacks; of Maelstrom Weapon][].
    ice_strike = {
        id = 342240,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "frost",

        spend = 0.033,
        spendType = "mana",

        talent = "ice_strike",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "ice_strike" )
            applyBuff( "ice_strike_buff" )

            if talent.swirling_maelstrom.enabled then gain_maelstrom( 1 + ( buff.maelstrom_of_elements.up and 1 or 0 ) ) end
            removeBuff( "maelstrom_of_elements" )

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Hurls molten lava at the target, dealing $285452s1 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.$?a343725[    |cFFFFFFFFGenerates $343725s3 Maelstrom.|r][]
    lava_burst = {
        id = 51505,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return maelstrom_mod( 2 ) * haste
        end,
        cooldown = 8,
        gcd = "spell",
        school = "fire",

        spend = 0.025,
        spendType = "mana",

        talent = "lava_burst",
        notalent = "elemental_blast",
        startsCombat = false,
        velocity = 30,

        indicator = function()
            return active_enemies > 1 and settings.cycle and dot.flame_shock.down and active_dot.flame_shock > 0 and "cycle" or nil
        end,

        handler = function ()
            removeBuff( "windspeakers_lava_resurgence" )
            removeBuff( "lava_surge" )
            removeBuff( "echoing_shock" )

            consume_maelstrom()

            if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end

            if talent.surge_of_power.enabled then
                gainChargeTime( "fire_elemental", 6 )
                removeBuff( "surge_of_power" )
            end

            if buff.primordial_wave.up and state.spec.elemental and ( talent.splintered_elements.enabled or legendary.splintered_elements.enabled ) then
                applyBuff( "splintered_elements", nil, active_dot.flame_shock )
            end
            removeBuff( "primordial_wave" )

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        impact = function () end,  -- This + velocity makes action.lava_burst.in_flight work in APL logic.

        bind = "elemental_blast",
    },

    -- Talent: Charges your off-hand weapon with lava and burns your target, dealing $s1 Fire damage.    Damage is increased by $s2% if your offhand weapon is imbued with Flametongue Weapon. $?s334033[Lava Lash will spread Flame Shock from your target to $s3 nearby targets.][]$?s334046[    Lava Lash increases the damage of Flame Shock on its target by $334168s1% for $334168d.][]
    lava_lash = {
        id = 60103,
        cast = 0,
        cooldown = function () return ( 18 - 3 * talent.molten_assault.rank ) * ( buff.hot_hand.up and ( 1 - 0.375 * talent.hot_hand.rank ) or 1 ) * haste - ( settings.pad_lava_lash and buff.hot_hand.up and ( latency * 2 ) or 0 ) end,
        gcd = "spell",
        school = "fire",

        spend = 0.008,
        spendType = "mana",

        talent = "lava_lash",
        startsCombat = true,

        cycle = function()
            return talent.lashing_flames.enabled and "lashing_flames" or nil
        end,

        indicator = function()
            if debuff.flame_shock.down and active_dot.flame_shock > 0 and active_enemies > 1 then return "cycle" end
        end,

        handler = function ()
            removeDebuff( "target", "primal_primer" )

            if talent.lashing_flames.enabled then applyDebuff( "target", "lashing_flames" ) end

            removeBuff( "primal_lava_actuators" )
            removeBuff( "ashen_catalyst" )

            if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
            if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_fire" ) end
            if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end

            -- This is dumb, but technically you don't know if FS will go to a new target or refresh an old one.  Even your current target.
            if talent.molten_assault.enabled and debuff.flame_shock.up then
                active_dot.flame_shock = min( active_enemies, active_dot.flame_shock + 2 )
            end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Hurls a bolt of lightning at the target, dealing $s1 Nature damage.$?a343725[    |cFFFFFFFFGenerates $343725s1 Maelstrom.|r][]
    lightning_bolt = {
        id = 188196,
        cast = function ()
            if buff.natures_swiftness.up then return 0 end
            return maelstrom_mod( 2 ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return buff.natures_swiftness.up and 0 or 0.01 end,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            consume_maelstrom()

            removeBuff( "natures_swiftness" )

            if buff.primordial_wave.up and state.spec.enhancement and ( talent.splintered_elements.enabled or legendary.splintered_elements.enabled ) then
                applyBuff( "splintered_elements", nil, active_dot.flame_shock )
            end
            removeBuff( "primordial_wave" )

            if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_nature" ) end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end

            tiSpell = "lightning_bolt"
        end,
    },

    -- Talent: Grips the target in lightning, stunning and dealing $305485o1 Nature damage over $305485d while the target is lassoed. Can move while channeling.
    lightning_lasso = {
        id = 305483,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "nature",

        talent = "lightning_lasso",
        startsCombat = false,

        start = function ()
            removeBuff( "echoing_shock" )
            applyDebuff( "target", "lightning_lasso" )

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        copy = 305485
    },

    -- Surround yourself with a shield of lightning for $d.    Melee attackers have a $h% chance to suffer $192109s1 Nature damage$?a137041[ and have a $s3% chance to generate a stack of Maelstrom Weapon]?a137040[ and have a $s4% chance to generate $s5 Maelstrom][].    $?s383010[The Shaman can have up to two Elemental Shields active on them.][Only one Elemental Shield can be active on the Shaman at a time.]
    lightning_shield = {
        id = 192106,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.015,
        spendType = "mana",

        startsCombat = false,
        essential = true,
        nobuff = function() if not talent.elemental_orbit.enabled then return "earth_shield" end end,

        timeToReady = function () return buff.lightning_shield.remains - 120 end,

        handler = function ()
            applyBuff( "lightning_shield" )
            if talent.elemental_orbit.rank == 0 then removeBuff( "earth_shield" ) end
        end,
    },

    -- Talent: Your next healing or damaging Nature spell is instant cast and costs no mana.
    natures_swiftness = {
        id = 378081,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        school = "nature",

        talent = "natures_swiftness",
        startsCombat = false,

        toggle = "cooldowns",
        nobuff = "natures_swiftness",

        handler = function ()
            applyBuff( "natures_swiftness" )
        end,
    },

    -- Talent: Summons a totem at your feet that removes $383015s1 poison effect from a nearby party or raid member within $383015a yards every $383014t1 sec for $d.
    poison_cleansing_totem = {
        id = 383013,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "nature",

        spend = 0.025,
        spendType = "mana",

        talent = "poison_cleansing_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "poison_cleaning_totem" )
        end,
    },

    -- An instant weapon strike that causes $sw2 Physical damage.
    primal_strike = {
        id = 73899,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 0.094,
        spendType = "mana",

        notalent = "stormstrike",
        startsCombat = true,

        handler = function ()
        end,
    },

    -- Talent / Covenant (Necrolord): Blast your target with a Primordial Wave, dealing $375984s1 Shadow damage and apply Flame Shock to them.; Your next $?a137040[Lava Burst]?a137041[Lightning Bolt][Healing Wave] will also hit all targets affected by your $?a137040|a137041[Flame Shock][Riptide] for $?a137039[$s2%]?a137040[$s3%][$s4%] of normal $?a137039[healing][damage].$?s384405[; Primordial Wave generates $s5 stacks of Maelstrom Weapon.][]
    primordial_wave = {
        id = function() return talent.primordial_wave.enabled and 375982 or 326059 end,
        cast = 0,
        charges = 1,
        cooldown = 45,
        recharge = 45,
        gcd = "spell",
        school = "shadow",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        velocity = 30,

        toggle = "essences",

        usable = function()
            if buff.maelstrom_weapon.stack < 5 then return true end
            return not ( talent.primal_maelstrom.enabled and settings.burn_before_wave ), "setting requires spending maelstrom_weapon before using with primal_maelstrom"
        end,

        handler = function ()
            if talent.primal_maelstrom.enabled then gain_maelstrom( 5 * talent.primal_maelstrom.rank ) end
            if set_bonus.tier31_2pc > 0 then
                insert( virtual_spirits, {
                    expires = query_time + 15,
                    alpha_expires = 0
                } )
                applyBuff( "crackling_surge" )
            end
        end,

        impact = function ()
            applyBuff( "primordial_wave" )
            applyDebuff( "target", "flame_shock" )
        end,

        copy = { 326059, 375982 }
    },

    -- Talent: Purges the enemy target, removing $m1 beneficial Magic $leffect:effects;.$?(s147762&s51530)  [ Successfully purging a target grants a stack of Maelstrom Weapon.][]
    purge = {
        id = 370,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        icd = function() if settings.purge_icd > 0 then return settings.purge_icd end end,
        school = "nature",

        spend = 0.14,
        spendType = "mana",

        talent = "purge",
        startsCombat = true,
        toggle = "interrupts",
        buff = "dispellable_magic",

        handler = function ()
            removeBuff( "dispellable_magic" )
            if time > 0 and talent.inundate.enabled then gain( 8, "maelstrom" ) end
        end,
    },


    skyfury_totem = {
        id = 204330,
        cast = 0,
        cooldown = function () return 40 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "fire",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135829,

        pvptalent = "skyfury_totem",

        handler = function ()
            summonPet( "skyfury_totem" )
            applyBuff( "skyfury_totem" )
        end,
    },

    -- Talent: Calls upon the guidance of the spirits for $d, permitting movement while casting Shaman spells. Castable while casting.$?a192088[ Increases movement speed by $192088s2%.][]
    spiritwalkers_grace = {
        id = 79206,
        cast = 0,
        cooldown = function () return 120 - 30 * talent.graceful_spirit.rank end,
        gcd = "off",
        school = "nature",

        spend = 0.141,
        spendType = "mana",

        talent = "spiritwalkers_grace",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "spiritwalkers_grace" )
        end,
    },

    -- Talent: Summons a totem at your feet for $d that grants $383018s1% physical damage reduction to you and the $s1 allies nearest to the totem within $?s382201[${$s2*(1+$382201s3/100)}][$s2] yards.
    stoneskin_totem = {
        id = 383017,
        cast = 0,
        cooldown = function () return 30 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.015,
        spendType = "mana",

        talent = "stoneskin_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "stoneskin_totem" )
            applyBuff( "stoneskin" )
        end,
    },

    -- Talent: Energizes both your weapons with lightning and delivers a massive blow to your target, dealing a total of ${$32175sw1+$32176sw1} Physical damage.$?s210853[    Stormstrike has a $s4% chance to generate $210853m2 $Lstack:stacks; of Maelstrom Weapon.][]
    stormstrike = {
        id = 17364,
        cast = 0,
        cooldown = function() return gcd.execute * 5 end,
        gcd = "spell",
        school = "physical",

        rangeSpell = 73899,

        spend = 0.02,
        spendType = "mana",

        talent = "stormstrike",
        startsCombat = true,

        bind = "windstrike",
        cycle = function () return azerite.lightning_conduit.enabled and "lightning_conduit" or nil end,
        nobuff = "ascendance",

        handler = function ()
            setCooldown( "windstrike", action.stormstrike.cooldown )

            if buff.stormbringer.up then
                removeBuff( "stormbringer" )
            end

            removeBuff( "converging_storms" )

            if azerite.lightning_conduit.enabled then
                applyDebuff( "target", "lightning_conduit" )
            end

            removeBuff( "strength_of_earth" )
            removeBuff( "legacy_of_the_frost_witch" )

            if talent.elemental_assault.rank > 1 then
                gain_maelstrom( 1 )
            end

            if set_bonus.tier29_2pc > 0 then applyBuff( "maelstrom_of_elements" ) end

            if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
            if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
            if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Shatters a line of earth in front of you with your main hand weapon, causing $s1 Flamestrike damage and Incapacitating any enemy hit for $d.
    sundering = {
        id = 197214,
        cast = 0,
        cooldown = 40,
        gcd = "spell",
        school = "flamestrike",

        spend = 0.06,
        spendType = "mana",

        talent = "sundering",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "sundering" )

            if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Calls down a bolt of lightning, dealing $s1 Nature damage to all enemies within $A1 yards, reducing their movement speed by $s3% for $d, and knocking them $?s378779[upward][away from the Shaman]. Usable while stunned.
    -- TODO: Track Thunderstorm for CDR.
    thunderstorm = {
        id = 51490,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "nature",

        talent = "thunderstorm",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "thunderstorm" )
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Relocates your active totems to the specified location.
    totemic_projection = {
        id = 108287,
        cast = 0,
        cooldown = 10,
        gcd = "off",
        school = "nature",

        talent = "totemic_projection",
        startsCombat = false,
        essential = true,

        handler = function ()
            -- Assume we're trying to bring WF totem in range if the totem is active but the buff is down.
            if totem.windfury_totem.remains > 0 and not buff.windfury_totem.up then
                applyBuff( "windfury_totem" )
            end
        end,
    },


    -- Talent: Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_recall = {
        id = 108285,
        cast = 0,
        cooldown = function() return talent.call_of_the_elements.enabled and 120 or 180 end,
        gcd = "spell",
        school = "nature",

        talent = "totemic_recall",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            if recall_totem_1 then setCooldown( recall_totem_1, 0 ) end
            if talent.creation_core.enabled and recall_totem_2 then setCooldown( recall_totem_2, 0 ) end
        end,

        copy = "call_of_the_elements"
    },

    -- Talent: Summons a totem at your feet for $d that prevents cast pushback and reduces the duration of all incoming interrupt effects by $383020s2% for you and the $s1 allies nearest to the totem within $?s382201[${$s2*(1+$382201s3/100)}][$s2] yards.
    tranquil_air_totem = {
        id = 383019,
        cast = 0,
        cooldown = function () return 60 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.015,
        spendType = "mana",

        talent = "tranquil_air_totem",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "tranquil_air_totem" )
            applyBuff( "tranquil_air" )
        end,
    },

    -- Talent: Summons a totem at your feet that shakes the ground around it for $d, removing Fear, Charm and Sleep effects from party and raid members within $8146a1 yards.
    tremor_totem = {
        id = 8143,
        cast = 0,
        cooldown = function () return 60 + ( conduit.totemic_surge.mod * 0.001 ) - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.023,
        spendType = "mana",

        talent = "tremor_totem",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "tremor_totem" )
        end,
    },


    water_walking = {
        id = 546,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135863,

        handler = function ()
            applyBuff( "water_walking" )
        end,
    },

    -- Talent: Summons a totem at the target location for $d, continually granting all allies who pass within $192078s1 yards $192082s% increased movement speed for $192082d.
    wind_rush_totem = {
        id = 192077,
        cast = 0,
        cooldown = function () return 120 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",

        talent = "wind_rush_totem",
        startsCombat = false,
        texture = 538576,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "wind_rush_totem" )
            applyBuff( "wind_rush" )
        end,
    },

    -- Talent: Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for $d.
    wind_shear = {
        id = 57994,
        cast = 0,
        cooldown = 12,
        gcd = "off",
        school = "nature",

        talent = "wind_shear",
        startsCombat = false,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },

    -- Talent: Summons a totem at your feet for $d.  Party members within $?s382201[${(1+$382201s3/100)*$s2}][$s2] yds have a $327942h% chance when they main-hand auto-attack to swing an extra time.
    windfury_totem = {
        id = 8512,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "nature",

        spend = 0.015,
        spendType = "mana",

        talent = "windfury_totem",
        startsCombat = false,
        readyTime = function()
            if buff.windfury_totem.up then return totem.windfury_totem.remains - 30 end
        end,
        essential = true,

        handler = function ()
            applyBuff( "windfury_totem" )
            summonTotem( "windfury_totem", nil, 120 )

            if legendary.doom_winds.enabled and debuff.doom_winds_cd.down then
                applyBuff( "doom_winds_buff" )
                applyDebuff( "player", "doom_winds_cd" )
            end
        end,
    },

    -- Talent: Imbue your main-hand weapon with the element of Wind for $319773d. Each main-hand attack has a $319773h% chance to trigger $?s390288[three][two] extra attacks, dealing $25504sw1 Physical damage each.$?s262647[    Windfury causes each successive Windfury attack within $262652d to increase the damage of Windfury by $262652s1%, stacking up to $262652u times.][]
    windfury_weapon = {
        id = 33757,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        talent = "windfury_weapon",
        startsCombat = false,
        essential = true,
        nobuff = "windfury_weapon",

        usable = function() return main_hand.size > 0, "requires a mainhand weapon" end,
        handler = function ()
            applyBuff( "windfury_weapon" )
        end,
    },


    windstrike = {
        id = 115356,
        cast = 0,
        cooldown = function() return gcd.execute * 2 - ( settings.pad_windstrike and latency * 2 or 0 ) end,
        gcd = "spell",

        texture = 1029585,
        known = 17364,

        buff = "ascendance",

        bind = "stormstrike",

        handler = function ()
            setCooldown( "stormstrike", action.stormstrike.cooldown )
            setCooldown( "strike", action.stormstrike.cooldown )

            if buff.stormbringer.up then
                removeBuff( "stormbringer" )
            end

            removeBuff( "converging_storms" )
            removeBuff( "strength_of_earth" )
            removeBuff( "legacy_of_the_frost_witch" )

            if talent.elemental_assault.enabled then
                addStack( "maelstrom_weapon" )
            end

            if talent.thorims_invocation.enabled and buff.maelstrom_weapon.up then
                consume_maelstrom( min( 5, buff.maelstrom_weapon.stack ) )
            end

            if azerite.natural_harmony.enabled then
                if buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                if buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },
} )


spec:RegisterRanges( "primal_strike", "lightning_bolt", "flame_shock", "wind_shear" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 2,
    cycle = false,

    nameplates = true,
    rangeChecker = "primal_strike",
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_agility",

    package = "Enhancement",
} )



spec:RegisterSetting( "funnel_priority", false, {
    name = "AOE Funnel Priority",
    desc = "If checked and multiple targets are detected, recommendations will prioritize damage to the current target vs. maximizing AOE damage on all targets.",
    type = "toggle",
    width = "full"
} )

spec:RegisterStateExpr( "funnel", function()
    return settings.funnel_priority
end )

spec:RegisterSetting( "pad_windstrike", true, {
    name = strformat( "Pad %s Cooldown", Hekili:GetSpellLinkWithTexture( spec.abilities.windstrike.id ) ),
    desc = strformat( "If checked, the cooldown of %s will be shortened to help ensure it is recommended as frequently as possible during %s.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.windstrike.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.ascendance.id ) ),
    type = "toggle",
    width = 1.5
} )

spec:RegisterSetting( "pad_lava_lash", true, {
    name = strformat( "Pad %s Cooldown", Hekili:GetSpellLinkWithTexture( spec.abilities.lava_lash.id ) ),
    desc = strformat( "If checked, the cooldown of %s will be shortened to help ensure that it is recommended as frequently as possible during %s.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.lava_lash.id ), Hekili:GetSpellLinkWithTexture( spec.auras.hot_hand.id ) ),
    type = "toggle",
    width = 1.5
} )

local elemental = Hekili:GetSpec( 262 )

spec:RegisterSetting( "pwave_targets", 0, {
    name = strformat( "%s: Required Targets", Hekili:GetSpellLinkWithTexture( spec.abilities.primordial_wave.id ) ),
    desc = strformat( "If set above 1, %s will not be recommended unless multiple targets are detected.  This option can be quickly accessed via the icon or addon compartment "
        .. "on your minimap, to quickly change it for different boss encounters.\n\nThis setting is also found in the |cFFFFD100Abilities |cFFFFFFFF>|r "
        .. "Enhancement |cFFFFFFFF>|r |W%s|w|r section.", Hekili:GetSpellLinkWithTexture( spec.abilities.primordial_wave.id ), spec.abilities.primordial_wave.name ),
    type = "range",
    min = 0,
    max = 15,
    step = 1,
    set = function( info, val )
        Hekili.DB.profile.specs[ 263 ].abilities.primordial_wave.targetMin = val
    end,
    get = function()
        return Hekili.DB.profile.specs[ 263 ].abilities.primordial_wave.targetMin or 0
    end,
    width = "full"
} )

spec:RegisterSetting( "pwave_gcds", 4, {
    name = strformat( "%s: GCD Threshold", Hekili:GetSpellLinkWithTexture( spec.abilities.primordial_wave.id ) ),
    desc = strformat( "By default, in a multi-target scenario, %s may be recommended with %s active while waiting for you to spread %s to additional targets.\n\n"
        .. "If set above 0, when %s is active and has fewer than this number of GCDs remaining, filler %s casts will be prevented and %s will be recommended despite "
        .. "having enemies without %s active.\n\n"
        .. "Setting this |cffffd100higher|r reduces your risk of having %s fall off during a lucky string of %s procs.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.chain_lightning.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.primordial_wave.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.flame_shock.id ), spec.abilities.primordial_wave.name, spec.abilities.chain_lightning.name, spec.abilities.lightning_bolt.name,
        spec.abilities.flame_shock.name, spec.abilities.primordial_wave.name, Hekili:GetSpellLinkWithTexture( spec.talents.hot_hand[2] ) ),
    type = "range",
    min = 0,
    max = 6,
    step = 0.1,
    width = "full",
} )

spec:RegisterSetting( "hostile_dispel", false, {
    name = strformat( "Use %s or %s", Hekili:GetSpellLinkWithTexture( 370 ), Hekili:GetSpellLinkWithTexture( 378773 ) ),
    desc = strformat( "If checked, %s or %s can be recommended when your target has a dispellable magic effect.\n\n"
        .. "These abilities are also on the Interrupts toggle by default.", Hekili:GetSpellLinkWithTexture( 370 ), Hekili:GetSpellLinkWithTexture( 378773 ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "purge_icd", 12, {
    name = strformat( "%s Internal Cooldown", Hekili:GetSpellLinkWithTexture( 370 ) ),
    desc = strformat( "If set above zero, %s cannot be recommended again until time has passed since it was last used, even if there are more "
        .. "dispellable magic effects on your target.\n\nThis feature can prevent you from being encouraged to spam your dispel endlessly against enemies "
        .. "with rapidly stacking magic buffs.", Hekili:GetSpellLinkWithTexture( 370 ) ),
    type = "range",
    min = 0,
    max = 20,
    step = 1,
    width = "full"
} )

spec:RegisterSetting( "project_windfury", 0, {
    name = strformat( "Use %s for %s", Hekili:GetSpellLinkWithTexture( spec.abilities.totemic_projection.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.windfury_totem.id ) ),
    desc = strformat( "If set above zero, %s can be recommended to relocate your %s when it is active, will remain active for the specified time, and you are currently out of range.\n\n"
        .. "This feature may be disruptive if you have other totems active that you do not want to move.", Hekili:GetSpellLinkWithTexture( spec.abilities.totemic_projection.id ),
            Hekili:GetSpellLinkWithTexture( spec.abilities.windfury_totem.id ) ),
    type = "range",
    min = 0,
    max = 120,
    step = 1,
    width = "full"
} )

spec:RegisterStateExpr( "project_windfury_totem", function ()
    if not settings.project_windfury or settings.project_windfury == 0 then return false end
    return totem.windfury_totem.remains >= settings.project_windfury and buff.windfury_totem.down
end )

spec:RegisterSetting( "tp_macro", nil, {
    name = strformat( "%s Macro", Hekili:GetSpellLinkWithTexture( spec.abilities.totemic_projection.id ) ),
    desc = strformat( "This macro will use %s at your feet.  It can be useful for pulling your %s to you if you get out of range.\n\n"
        .. "You can also add this command to a macro for other abilities (like %s) to routinely bring your totems to your character.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.totemic_projection.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.windfury_totem.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.stormstrike.id ) ),
    type = "input",
    width = "full",
    multiline = true,
    get = function () return "#showtooltip\n/use [@player] " .. class.abilities.totemic_projection.name end,
    set = function () end,
} )

--[[ spec:RegisterSetting( "burn_before_wave", true, {
    name = strformat( "Burn Maelstrom before %s", Hekili:GetSpellLinkWithTexture( spec.abilities.primordial_wave.id ) ),
    desc = strformat( "If checked, spending %s stacks may be recommended before using %s when %s is talented.\n\n"
        .. "This feature is damage-neutral in single-target and a slight increase in multi-target scenarios.", Hekili:GetSpellLinkWithTexture( spec.auras.maelstrom_weapon.id ),
            Hekili:GetSpellLinkWithTexture( spec.abilities.primordial_wave.id ), Hekili:GetSpellLinkWithTexture( spec.talents.primal_maelstrom[2] ) ),
    type = "toggle",
    width = "full",
} ) ]]


spec:RegisterSetting( "filler_shock", true, {
    name = strformat( "Filler %s", Hekili:GetSpellLinkWithTexture( spec.abilities.flame_shock.id ) ),
    desc = strformat( "If checked, a filler %s may be recommended when nothing else is currently ready, even if something better will be off cooldown very soon.\n\n"
        .. "This feature matches simulation profile behavior and is a small DPS increase, but has been confusing to some users.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.flame_shock.id ) ),
    type = "toggle",
    width = 1.5
} )



spec:RegisterPack( "Enhancement", 20231119, [[Hekili:T3ZAVTnss(BXyruKYdzjk7mzMtYl2n3oaZGCZnaEpCFtu0uusCdfPo(ioEHH(TFv3nj7xv3KupStYmadMK4UzvvxVRQF45JN)pNF7sV8G5)MZiNjJhp(hhoEY1)WKRMFB(d7cMF7op)p5Tg(lXEBH)))iEJxSFW2G4CYypeL4TKaJSKIuFy8n557Y(PlVCDy(MI7g6NS9YSWTfrE5HjX(PERYj)B)lVlk5UlxM6TojEvu46n5xgeVomo4s)iVSm3TjllIcYUmZ3nBJ3wV4H(72n)27kcJY)L453Hs0JVgOJDb(Wp(DtasjC5Ya2CdY8NFlzUVD843oE0pTFX(f)cqo01Hx0(fanTFrXocqhU)x3)RvZD0105()qhz)IvjP7xmE0qh(Kg9E4)Gj93wUC)IFUiooaaxYoYYD)cVy4hUlnmjnm)b4Ztta0CB42pi89)aGh47)DVC)nuGpE4160cmTroe0KLvSfOKFoYJ8h3UjX)tzacbKLKVjaiVCV01b5WpZlfMWUKCyjg6ffb4pPih(FR2Vi1lEDW)X(faJTGnK3UDK)qeSWpCvohIat6EywHXRFZ(fHaqIdcwgSuGeF3BDE3pvXSacipb4Y(eWLNg(j4pVeqqAswEjce(0RF7Kr)eNp)rVp7r()zahPidu)2V4EqHIS83eal1p4bsThYYLGGZivKdOn(taVqAAJVcM2ph(fIGjyRxEbHn9rIkymS22V4VNeLxHUF))17ZWOHak)B)3)dzW4uj09I2TXZ9(KOvUBdJDjanmoRu4lZqjSTkywk1(W)Peyhr4G)xjPuSkOGsuAQ0kKxpu1Io8fxXy1SVW8KC(r26lKOjBhEcsDbD8sB(pqS55woJf(YjvMx)cWhG5Nh(2Avn)GypWUjd01wfgfrudLzLzBskIws4He927cikkblzSyfMoWPtdwLgaEsUlky48BJcZYZOETajEua83(nQJqaNWewo)Vp)wFWInin0B(TxSFXYK8HRiWeCgr0BZd9)evxPhX4icy4dbVwBGFKlDAzdlHeDg9j2BHlDd(mzIElxMnKOqDdDepFctAi4JyBs6sWo19Eq9a8BMeTm5(yQndmTX7x8AynhK7ExsCrgqbbPtg7E1o)9lgq)VhFehnt3V4DWeMFldtGtBzunphCxABX36flhfc8kc4Nye83vSA1WTEbrz5GAJ79bE7aMrwUhrUDZS9lUweTbrLk3Uz7cbyiZMxfKwpYqcLqSYiW4koHXHWDWAiNqCxzK4u42JCDiC7EgKMZQLLzfXlbieVUwkYjG6XiO(6JLVqNgeu1)treXbeXLa9HmfNQX9i2sljbThwSJXodD93a(OCJ4E9y6PQFqTVmMYA16bOeIdD(WGU5A)Laf)fM6iFbxJcGvgrz4VZ(QEzczbhgd8vc5suRlf)ldcGyuUPjqinG)ZeLc6aKP2VE2z5jPBPszjTekoyJreda3IGfbcMogB9rO2FWo1Ujj3fsiAjafH1me9YLyJqaW7TzBrHbzXUQi9b3CyHTvcsYdra3pES6mGKhCXcYSzKW)FXT8FB1gz8OdhRVNZ2vDYvQoAW5i6NuRXX0xRyHz7adaGIe1lQ0Ewr0a5rLNc00yNg0rhBoCqxwW6MMvwGn4qJtBkgQuIZS76wsC9T4T0HX1UOzIuIhIP1y2Vph65BGCJ3M5gg)5eFAcd6MRwvQvm7URiTe7MDS3N7RRbE1aDVkan67657xuLGthP3Q41MmkKJxGOAAoQrjnYZhT54J9mN(kqSJe0dtb)zk6HM9K)mNVJ1KDgB2LopBhJ5Ym2S)Cn7fOqwpiRwjPqLE09HPuhd16k6M(H(aERden2SN)wMvMuyjhZU0RCQYXVumjzYYPbpLG7RiAivjySIufiNP6q9OPtNcWLmRjIZsGmuM2vItJMjb60UwCAIr9vMxh1YpG8aD(brs5oV1UjRCbAbQSxLyAu7ZSIfZyNA37QuqtZUUMAACske05iiCdtdCJt(ShLIBuTLRH0vhPhQl0jJe53I6IYC7jJfNNQhqL5AoOmop3a)AIKsEGxA(g3ApkQ40ATl5arMnKv8Sgkvkq7CvjYPiDNjnuWqljUoRK0qM)kzTZZVC)IjJSKbFoW9PDjCU1Uo03STALlgySG4GTHKK5jrdnn)zSoa0yE4w5MZA0bWjiNCSy6stIxKPnrNztrEICBH5geJgI2w3ESiwMQlvgy1N70k5ICkMEKwC66x1HtnNIkJRiFugvq6mWqMaQzPxnj1uNqYqqxrcM1d(rbULnHMOHNR3Jfm3q0M0NgUJncPJGRHbFZ(fpKuavQseY7xeNa)Vn0(N(714E)cwhvtd8w(aRPQ7kIIi0yE5NFVxCUABbPndN2wYp(ran)8V9MYw2w2G27PDAomN02JTePjW0cJiRHHKEw(3IYsGVi4lHz5uTdLoYV17Hs6L0Bs)OKm4pcItkwVH1C6SDecEiU6PkNTwlqOFi1XnekiJQMiKgBUTUm1VLL5jRFAVlC9n2HbgCO6nsLIq7)IAvrhUBiRLKAous)ttfP0kxgiSu9tI)Cq6AI7jwoMQRe9jGSueYInVXEsDAqPsFWmN45rkVSN(G1mdmNAzD59mV8Y00Rlh8Zjr(EXq18aHfeVoFdvv8gnQjRauFR(4tSoQsploW(S1jm25MDH0r2l4mjXCIRhxiA2PRzeiXk11K1mvnAnmTzRbPGMyDaPHoXHW5W2ubdLfAP)z2t1RKhzl)XRSMzczgS448uzmuVIL2SzT(Uo1KHM75LLIiBvhiy9YsxmixWLLwh1CALhsZLqtuclOfsUaczkymBIbNLKAXtc0sdSSPhoXuJfAWxjMRPETCVKmgf0s3UQ8iLw2foJ(JICnqAQmAL9UeX)JCFZm3QlPEkyPvxsDoZCd2K6CMXU1jzrzV5joMTRSPA4ys1WCYkFdMYRYUCGKvRLES9SMiK19NzYbMRJkq1BCtdPZCOnUXwl(AHV9jTz3W0cJzkGvoPE5vKymZrAJKuP00MWKwSR8OF5dknzdLxNayd8sNBT1j1DuCdqhHG39LHz7cI4aAhr7yosdf6amwdLedZ1Tgww3epQ4u54ny2GREeKSYUljJTNYinMAYi1DevaLQb4lJglIB8Piqe8OXcmZe6FIu(UIFGWITU7aDciTsV4phgvDonnoCrwGBYQvUR9xwgywTO4km4fbrVbhzG04F)VbH1DjFr7ZlXg6uv96IjUeYeutGjmMIidPNzOseXJSc2PAzkD7UFfFhB4HghclqXTASwdPVMsYlGI(F)iUYYG5i1OxXulpsIJvS))Sh83G5oSAC3WmWXxyA5UgY(PdZhdUiYCjcbcFPIGodgcOltbYOMVUSiL2Ke26xygmuupkxMvVwjv4XeGqoy(l5O6MznHlo0EcmlPwMzrj5cIpKwIOiIDAqe7yqe781Hi2PrrSZjteJIRNzrSZCKomvjIVlWZpbwzjU5Ba5uWdjXln5BeFUNDNJn4W66shwxx6VsR1tvl1T0mdxNggSc8o6VX0YuFEp3lrh1LOAAshNp5lm6wgZzHwRIooVfxy0HbMASLoj9e6APmi7DrjjlDjPwlCQFModB8d31InC907yP2Trn5m3ERZEgKkbPzbPKkymiv4JF8sfmC9mkvQjN52714tVuH0wdQsdUqHp8rltWW0ZNiPMAMNB9Cg(0lri4aQqaGQVxueUyrzohTSXioF(eqYK08w1B8JFJv7j2R66(KoRAS8qx52bjYHu)QBe(kTBdXa0UQI1HEPMBiFyvRUUi9)Q)()WAnFTXNGcIAJAn30Ugo1m9rfp9SinB40vkONlXSCef6gUPl46ckA41WFU9g)3aDkylXPtc5HreC0Z)S51n6hf9y8pst(td9ZPPNxbrIHQl7F4sUaCSRbNll79YlcxE1Mf0kuvBcbEokptBDgXEjmSAoxiJy9qrz53rBI6U0a)KT35XBJQODpT)VmhrQgcsgme1(8K41fb4ZUHlah3QiBtyq0s(f4Qk(g7CGknkrfkxD7jssVt0Po6PKJbf7nxfNSklkZef1RjcsO5LcFnwto5uYU0K)vGFURs745Lpr(NqHNLZlK10uZzmKhsoKwSJtqDYakBjG8rdvFJauJ0LSJ69N)jvr3j)TOIG6IXifkgMnePBPLYtPPPwrn2Cm0MxSPI3hcGulnl0QYfRhxDyP60ULQtlwQoTFP60HLQJ0svTxpnVuzH1QBDLuIv15Xjg)MEZ(FvTzY9H5(BCxM4dR5m3YuQEyyQx8NQIQt(OrJgr)QMsHdM(0)Qmjje8r8UAIasdP8PcqSUOJdqS8qhikemK5lZVmjSG1ZhDjwSTD7LzDWMyrCAr0dQRqSCbibq5N1i0HVEFdhmiRNa5sq26Z1n1fLXlc5uHtf9ROPiY2ITDKPr6rxM0cbfR)X64HBoACPUILdXdxH6OoHUpLhXCbwH4X(20zY(eESVnT1L)5X((j4yFBTPjxGKQ2z9mWy76gpO6)oPozAkabMZD6o4UVHR1CdN(6dN4fIOOFwNB48x)v0z01AGXgE(coYdmR5Ut0q0p5EeDMpXSM2gkHtsNwijt3Tx0dA5FE)N6Y9FYYMJvsrwovwkNt5d8WqtP82DoLLV1YMoNYwQ)TrXVqye0i25i96fnYUqlY4V(skzr9TW5w2SRxBEdmDULTCmOn6UwIL1MNbhgKSCpGKBjS6PC2SF0MIQwPmFspLZA9Ld)yjl1tolNY5d5zeW4PCwYESHt5SzRsBksgpLZMte5B2m843z7ZCsCwoI4ntGwtuZYHXgRxJD44hB9f7Ojx2wov0C(Cho(X5ZVfCUKrgR6r4eO(79sj8HS53(p3qEpc3UljTQCRxY2JHxsQy7)Ra0Kb5xwcP2jVI8KTE5KFaWqJxtFEb)yymme5LX8du)y0Ht2fW2l1m2JY4lVWqYk9SM3uV(6BAZn9zlvJBf3l6p(1yBa3Gbp(Oo4M(UbVKvW3tjnEzNProN(DnWQpaYPRSSko2bGQUUYFj9DOerlT8y13n10M4D9Vq)yk07cSJOq5pvQqiyj0p3uxv713sZzN68Qs(MYrBMWwiN3HE9L612lEX43pA6SjJQvE)MHYRj8AHYpiluEz1EeiFy9QwOgolFWW9h)LbTaOAhHveiJnNZk4BbGzsnZavD8Zk9EMbVjaRhxX8H)SNbnLE91TuavvelLYFQKLIbZrBRMPZmjLiMDnDcJUzMnytGWfMTCRgcBJOQhuFlLgWJj(1b)97o2BTc(7ny54y35N2WsMJMbAZMJ4Z5Sc(way7o)0h)SsVNzWBcWn78ZbX405SBC(cBRgbRtNJY6eb2NnRtto)EE4VF3XERvW)XZD644PoFnKb61NUmNrZYTeh8Y2g98SwDEcwRoQR1XNJm6P)IC4KhQC8KMKlNEd6xuwXeYTEz6m9X6MfTzyF2SNRuUo9CQVZyuCTUREg160VvpCMP(ThQBmtDyF2yMNFTUVtyuCTURF(060V3s18s9BhvNyL6q(SXjp7QCFxWLAFRQpdmYkojbCi3fRA2PY4hep1aooBm2ZU633JmnU2ytLtJDXWoOD3PRBNsTK9KrbDDxweytonvOIPDjRFFTlowpczY3Z3zJ7HSwQvm4s9AgPdDJj0UCykW9MXCJJNqQ7YoqDdl3dRvjrrj3tpLwEG1dWtVpG873TYFNOb83CY0yiD)cYTHQ8GYYMh9eRUkPiwA2lxsM8sVCV78Yc(P9)6(fVf(3LMNg2aT6Ru1l70wOzUv)4xJeKQ8moXwUNcixefCSGmR2Jcd3JfCmzEYThHy3ggCSzyMTSRKTuozzIThrnkNmnR2JI2kNAyYThHTsozBMsOQXEGX39vPGFvHUbp9JhE9RkdbA5QknyWRjx)Nxzlu6GP)vo6ecNwImzaGeUv8Z13Ry5pxpkppdh7R5l)UAnpK4F(xOUMjkaxl79N44LE7kxfsUrBSHYgw78(1ZUKqoc3a29)k2K0V7R4Zt9YK(MWvZOzrIE5xlB3T2Lm9XhlxWgUHPdWrUiCmJ4ID9WXAp7ifhN6xmvcMXVoR4qqEoKVMC5vNnQm9B5HPekoCQsH(nK7DxvN55736BO3MXznfVfy92cuQmSb)HkZcZpwhwdoMwdMcXWrpA4bLHBCny0xCBwdgQNPCL8hjVZe)u)fsuPC93P0AozP9Gl9Lkv8NsFQqjghgECrfNR0ZlAl)g2lXjzYNI6JLkpMCELE8XZq1PI0pzdkcj(pOADg0PFJWB62SXM)CeBk5pLYNo2nd6P6iJvFMXqxWKNrTAVLK1vBoZkN)JSYl4OYYU2EuNyLNWdSsJCEhuopYgMF(3V8xWrLfo)rTD5pH7wUzJCSiANbRCB7HUzItnM9tgH5yMW6KNIlWDv0iGB0q4cClbraZ3tYtv8SVV3bAjEx9oRDU5DFFS9GI8U6nj6mZ6(EyBUe5BY7PXzM5zydu(wEtAG6k(lvT9GWpjV8GFkWn4lqraXaOiSiwyLDj3d1fegVQGCLMOCAZ0t5iMFpd7PlLexIw(qBRumXClbR1Q)E8rLQsCgPw2flxAAliAexuYe)(ZDZ4E0DysAZr02)eYAsEw3qNLY2HizPOSHvL12DA20RoVTBsU(e44sM21kheA9jC3L6WEFjsVCZlc9AbLc2HvO8XhvHTiKvFR(ygKSll4BikE(5Se7ux4ndeVeBqa0QUG9wa2mKyZZoWQGfV7pSfbU65t4Tc8WvG5RabkLs9TIArGJYDXTUBSgCym7A9MVYmM4SejNAmPYnZUcb31pxciUhOVRi2mL0)T5ocgKnvBXIJoS(V4lPDDgPmgeZwTmcQI5YBvszNqQ6hhTJiyShExtQPCL8hQI1A9jiG3ahkePYz5OdSFoHzs)L8jgXuFH7RjLnj5UB8IPpdL6ZxVz5SI7u6so632DDYYB((mXBb)rRn8EgZr)11ctTeDQLs4ELLaJ)eRPfUFSdMaqrpRTup2VexB0e(eitEpKwlMFahEdwnIEJ6F0FzLXC3DuP9m76wPD0VV9L4arlla7(qCk)ITfrDHsgmaxnZGhnLN0cHua1F1OW8e3d)1IA2O2fL8jiAx7d2Hmt(ZhIaNHROP8(6uziKDFyk1gPwkzXsqYtyxd3ktFm3cs)kxfB1ZFQh4oFfECISrJwjbdUTnoOqaPMIMFSbUVZBTBYkxs6DFcZvE9lVIGqWSuSkxALu8SzzofFm(7xvBCGusyApJhn4sOtoee0oA2DrtCsC(ew4a6EYxBy1SnB9o7TkmkckT3ib3XWCgtz7WcZ1Xue6MOspNiSuIQYdyYiXsxGsNS693WtYdPIv2eWEWDvRXC24rd0koC2yH2SxshiXkXvDUrPSSY2GzirPPqQWVc5fZTMM0G(7me9S6SJGl4miuRnU7CcB6rYQhKKDVg7djec(laxVkXNHNET6sa0E42g0ZytmWzMtLLudm40umanB1OMMG0J2gR28lmiKOh0G)48iZQY5u8rEeYA9uIyyajT9(nM)npTwZf53hPKlWWanL)bv54EWwJ2DYP6YA6SjAMCDlUstKul8ltHGs56xufRs5H4t4iwCCjXRTSLskdJKWA7IMAAZPiaEI5DjwBSRm4l5MzsVrRw8tI4tPLPEJ4XTVDxUNl)MsNKgS3u1QomP)EQodBKATrn(gAvq6p1PQIz56mSN8kEbikkDn4VZUyWKlnrGGOwi82Mwh8uZHzTRudUAhC0c7dYgAIgNePfG6UpQxNn1hq23tpe6ApdPZENUpZoNTjdbyV1OAPAELk2Wk9uJlywt3OfFdRQdsq58TyCws5kp9HsLA2gxs3T6GS6gXOJcz)zxy2pi)lz7z0XvHd(8(MRufoR4piXoRxW)zbnDVGMAM35SMMAK8e7ULkSvpPhhxrnilk5d2rfTEGBXX4bneU3WG2iq0SroDGVBXvAIbBUVGMCXvV7sLB7dZdNioFnDGpNe5tp1RaIdIxNVbG5nkylJCJgyF0PwnPtTO8aG)xn1YYHKUEKCcN46GtBsheZ3)rwWm3nyZPrEIlzUg1TR6VEw38j(644lkuN32CyJUwAikCqIB)vrfHDrjrQOq7EI1R5QvLf2oxaNLc)qc9zFXAvB3wQRnVipuXJZ3KPNivv2ZFyqdKtxI0HdIdVuttEMS57PLfCo)wVcsADZV92WTFG(lVH5)))]] )

