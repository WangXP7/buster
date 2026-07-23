class_name UpgradeProcessor
extends Node

# Maybe consider making this an Autoload if you want to access it from anywhere in the future

func gain_upgrade(upgrade: Upgrade, level: int) -> void:
	match upgrade.id:
		"Damage1":
			State.stats.damage += 1
		"Size1":
			State.stats.player_size_mod += 0.1
		"Health1":
			State.stats.max_health += 4
		"SpawnRate1":
			State.stats.spawn_rate_mod += 0.5
		"Armor1":
			State.stats.armor += 0.2
		"BitBoost1":
			State.stats.bit_boost += 1
		"BossArmor1":
			State.stats.boss_armor += 1
		"HealthRegen1":
			State.stats.health_regen += 0.1
		"NodeFinder1":
			State.stats.blue_enemy_chance += 0.01
		"Salvaging1":
			State.stats.health_on_kill += 1
		"DamagePerEnemy1":
			State.stats.damage_mod_per_enemy += 0.05
		"BossDamage1":
			State.stats.boss_damage_mod += 0.5
		"AttackSpeed1":
			State.stats.attack_speed_mod += 0.2
		"BonusDropChance1":
			State.stats.bonus_drop_chance += 0.1
		"ExplodersChance":
			State.stats.exploder_spawn_chance += 0.05
		"Health2":
			State.stats.max_health += 12
		"Armor2":
			State.stats.armor += 0.6
		"Lifesteal1":
			State.stats.health_on_hit += 0.5
		"Damage2":
			State.stats.damage += 3
		"PickupRadius1":
			State.stats.drop_pickup_radius += 8
		"HealthRegen2":
			State.stats.health_regen += 4
		"Milestones":
			State.stats.milestones_unlocked = true
			if Refs.curr_scn is ShopScene:
				Refs.curr_scn.show_milestones_btn()
			MySteam.set_achievement("MILESTONES")
		"Salvaging2":
			State.stats.health_on_kill += 8
		"AttackSpeed2":
			State.stats.attack_speed_mod += 0.2
		"SpawnRate2":
			State.stats.spawn_rate_mod += 2.5
		"NodeBoost1":
			State.stats.node_boost += 1
		"ArmorPerEnemy1":
			State.stats.armor_mod_per_enemy += 0.02
		"Armor3":
			State.stats.armor += 2
		"DropHeal1":
			State.stats.health_on_pickup_drop += 0.5
		"Health3":
			State.stats.max_health += 80
		"PulseBolts":
			State.stats.pulse_bolt_count += 3
		"PulseBoltDamage1":
			State.stats.pulse_bolt_damage_mod += 0.25
		"PulseBoltCount1":
			State.stats.pulse_bolt_count += 1
		"ExplodersSize":
			State.stats.exploder_size += 0.15
		"MaxHealthHeal1":
			State.stats.max_health_regen += 0.01
		"Armor4":
			State.stats.armor += 5
		"BossArmor2":
			State.stats.boss_armor_mod += 0.25
		"Damage3":
			State.stats.damage += 6
		"Undamaged1":
			State.stats.undamaged_mod += 0.25
		"Execute1":
			State.stats.execute_mod += 0.25
		"CritChance1":
			State.stats.crit_chance += 0.1
		"SpawnRate3":
			State.stats.spawn_rate_mod += 1.0
		"Armor5":
			State.stats.armor += 2
		"Damage4":
			State.stats.damage += 25
		"Size2":
			State.stats.player_size_mod += 0.5
		"CryptoMine":
			State.stats.crypto_mine_unlocked = true
			if Refs.curr_scn is ShopScene:
				Refs.curr_scn.show_crypto_mine_btn()
			MySteam.set_achievement("CRYPTO_MINE")
		"YellowSpawn1":
			State.stats.yellow_enemy_chance += 0.001
		"Health4":
			State.stats.max_health += 300
		"Armor6":
			State.stats.armor += 5
		"BossDamage2":
			State.stats.boss_damage_mod += 1.0
		"Lifesteal2":
			State.stats.health_on_hit += 10
		"MovingPulser1":
			State.stats.auto_pulser_count += 1
		"Size3":
			State.stats.player_size += 1.0
		"MovingPulserSize1":
			State.stats.auto_pulser_size_mod += 0.25
		"MovingPulserAttackSpeed1":
			State.stats.auto_pulser_attack_speed_mod += 0.2
		"Health5":
			State.stats.max_health += 4000
		"Lifesteal3":
			State.stats.max_health_on_hit += 0.01
		"MaxHealthToArmor1":
			State.stats.max_health_armor += 0.01
		"CritDamage1":
			State.stats.crit_damage += 0.5
		"Damage5":
			State.stats.damage += 100
		"Armor7":
			State.stats.armor += 200
		"FocusArmor1":
			State.stats.focus_armor_mod += 0.5
		"StealMaxHealth1":
			State.stats.perma_max_health_on_kill += 1
		"PulseBoltExplode":
			State.stats.pulse_bolt_explode = true
		"MovingPulserSize2":
			State.stats.auto_pulser_size_mod += 0.5
		"PulseBoltCount2":
			State.stats.pulse_bolt_count += 2
		"PulseBoltDamage2":
			State.stats.pulse_bolt_damage_mod += 1.0
		"MovingPulserSpeed1":
			State.stats.auto_pulser_speed_mod += 0.2
		"Undamaged2":
			State.stats.undamaged_mod += 1.0
		"Execute2":
			State.stats.execute_mod += 1.0
		"MaxHealthHeal2":
			State.stats.max_health_regen += 0.02
		"RampingDamage1":
			State.stats.damage_mod_per_sec += 0.01
		"EnemyDeathPulseBolts":
			State.stats.enemy_death_pulse_bolt_chance += 0.01
		"SpawnRate4":
			State.stats.spawn_rate_mod += 4.0
		"StealMaxHealth2":
			State.stats.perma_max_health_on_kill += 2
		"MaxHealthToArmor2":
			State.stats.max_health_armor += 0.05
		"RampingArmor1":
			State.stats.armor_mod_per_sec += 0.01
		"Health6":
			State.stats.max_health += 50000
		"StealMaxHealth3":
			State.stats.perma_max_health_on_kill += 5
		"LightningChance1":
			State.stats.lightning_chance += 0.05
		"LightningChainCount1":
			State.stats.lightning_chains += 1
		"LightningDamage1":
			State.stats.lightning_damage_mod += 0.5
		"CritDamage2":
			State.stats.crit_damage += 2.0
		"MaxHealthToDamage1":
			State.stats.max_health_damage += 0.001
		"Health7":
			State.stats.max_health += 100000
		"Infinity1":
			State.stats.spawn_rate_mod += 10.0
			State.stats.perma_max_health_on_kill += 12
		"Laboratory":
			State.stats.lab_unlocked = true
			if Refs.curr_scn is ShopScene:
				Refs.curr_scn.show_lab_btn()
			MySteam.set_achievement("THE_LAB")
		"YellowSpawn2":
			State.stats.yellow_enemy_chance += 0.004
		"AutoCollect":
			State.stats.autocollect_chance += 0.1

func check_upgrade_unlocked(upgrade_node: UpgradeNode) -> bool:
	# Key: Connected upgrade id, Value: That upgrade's current level
	var connected: Dictionary = {}
	# Key: Connected upgrade id, Value: That upgrade's max level
	var max: Dictionary
	for connected_node: UpgradeNode in upgrade_node.connected_nodes:
		connected[connected_node.upgrade.id] = connected_node.upgrade.curr_level
		max[connected_node.upgrade.id] = connected_node.upgrade.get_max_level()
	match upgrade_node.upgrade.id:
		"Health1":
			return connected["Damage1"] > 0
		"SpawnRate1":
			return connected["Damage1"] > 0
		"Armor1":
			return connected["Health1"] > 0
		"BitBoost1":
			return connected["SpawnRate1"] > 0
		"Size1":
			return connected["SpawnRate1"] > 0
		"BossArmor1":
			return connected["Armor1"] > 0
		"HealthRegen1":
			return connected["Health1"] > 0
		"NodeFinder1":
			return connected["BitBoost1"] > 0
		"Salvaging1":
			return connected["HealthRegen1"] > 0
		"DamagePerEnemy1":
			return connected["Damage1"] > 0
		"BossDamage1":
			return connected["DamagePerEnemy1"] > 0
		"AttackSpeed1":
			return connected["DamagePerEnemy1"] > 0
		"BonusDropChance1":
			return connected["BitBoost1"] > 0
		"ExplodersChance":
			return connected["NodeFinder1"] > 0
		"Health2":
			return connected["BossArmor1"] > 0 or connected["Salvaging1"] > 0
		"Armor2":
			return connected["Armor1"] >= max["Armor1"]
		"Lifesteal1":
			return connected["Salvaging1"] > 0
		"Damage2":
			return connected["AttackSpeed1"] > 0
		"PickupRadius1":
			return connected["Size1"] > 0
		"HealthRegen2":
			return connected["Health2"] > 0
		"Milestones":
			return connected["NodeFinder1"] > 0
		"Salvaging2":
			return connected["Salvaging1"] >= max["Salvaging1"]
		"AttackSpeed2":
			return connected["AttackSpeed1"] > 0
		"SpawnRate2":
			return connected["SpawnRate1"] > 0
		"NodeBoost1":
			return connected["NodeFinder1"] > 0
		"ArmorPerEnemy1":
			return connected["Armor2"] > 0
		"Armor3":
			return connected["Armor2"] >= max["Armor2"]
		"DropHeal1":
			return connected["Lifesteal1"] > 0
		"Health3":
			return connected["Health2"] > 0
		"PulseBolts":
			return connected["AttackSpeed2"] > 0
		"PulseBoltDamage1":
			return connected["PulseBolts"] > 0
		"PulseBoltCount1":
			return connected["PulseBolts"] > 0
		"ExplodersSize":
			return connected["ExplodersChance"] > 0
		"MaxHealthHeal1":
			return connected["HealthRegen2"] > 0
		"Armor4":
			return connected["Armor3"] >= max["Armor3"]
		"BossArmor2":
			return connected["Armor4"] > 0
		"Damage3":
			return connected["Damage2"] >= max["Damage2"]
		"Undamaged1":
			return connected["Damage3"] > 0
		"Execute1":
			return connected["Undamaged1"] > 0
		"CritChance1":
			return connected["Damage3"] > 0
		"SpawnRate3":
			return connected["SpawnRate2"] >= max["SpawnRate2"]
		"Armor5":
			return connected["Armor4"] >= max["Armor4"]
		"Damage4":
			return connected["Damage3"] >= max["Damage3"]
		"Size2":
			return connected["SpawnRate3"] > 0
		"CryptoMine":
			return connected["Size2"] > 0
		"YellowSpawn1":
			return connected["CryptoMine"] > 0
		"Health4":
			return connected["Health3"] >= max["Health3"]
		"Armor6":
			return connected["Armor5"] >= max["Armor5"]
		"BossDamage2":
			return connected["BossDamage1"] >= max["BossDamage1"]
		"Lifesteal2":
			return connected["MaxHealthHeal1"] >= max["MaxHealthHeal1"]
		"MovingPulser1":
			return connected["Damage4"] >= max["Damage4"]
		"Size3":
			return connected["Size2"] >= max["Size2"]
		"MovingPulserSize1":
			return connected["MovingPulser1"] > 0
		"MovingPulserAttackSpeed1":
			return connected["MovingPulserSize1"] > 0
		"Health5":
			return connected["Health4"] >= max["Health4"]
		"Lifesteal3":
			return connected["Lifesteal2"] >= max["Lifesteal2"]
		"MaxHealthToArmor1":
			return connected["Armor6"] >= max["Armor6"]
		"CritDamage1":
			return connected["CritChance1"] > 0
		"Damage5":
			return connected["Damage4"] >= max["Damage4"]
		"Armor7":
			return connected["Armor6"] >= max["Armor6"]
		"FocusArmor1":
			return connected["Armor6"] >= max["Armor6"]
		"StealMaxHealth1":
			return connected["Health5"] >= max["Health5"]
		"PulseBoltExplode":
			return connected["PulseBoltDamage1"] >= max["PulseBoltDamage1"]
		"MovingPulserSize2":
			return connected["MovingPulserSize1"] >= max["MovingPulserSize1"]
		"PulseBoltCount2":
			return connected["PulseBoltCount1"] > 0
		"PulseBoltDamage2":
			return connected["PulseBoltCount2"] > 0 or connected["PulseBoltExplode"] > 0
		"MovingPulserSpeed1":
			return connected["MovingPulser1"] > 0
		"Undamaged2":
			return connected["Undamaged1"] >= max["Undamaged1"]
		"Execute2":
			return connected["Execute1"] >= max["Execute1"]
		"MaxHealthHeal2":
			return connected["Health5"] > 0
		"RampingDamage1":
			return connected["Damage5"] >= max["Damage5"]
		"EnemyDeathPulseBolts":
			return connected["PulseBoltDamage2"] > 0
		"SpawnRate4":
			return connected["SpawnRate3"] >= max["SpawnRate3"]
		"StealMaxHealth2":
			return connected["StealMaxHealth1"] > 0
		"MaxHealthToArmor2":
			return connected["MaxHealthToArmor1"] >= max["MaxHealthToArmor1"]
		"RampingArmor1":
			return connected["MaxHealthToArmor2"] > 0
		"Health6":
			return connected["StealMaxHealth2"] > 0
		"StealMaxHealth3":
			return connected["StealMaxHealth2"] > 0
		"LightningChance1":
			return connected["RampingDamage1"] > 0
		"LightningChainCount1":
			return connected["LightningChance1"] > 0
		"LightningDamage1":
			return connected["LightningChance1"] > 0
		"CritDamage2":
			return connected["CritDamage1"] >= max["CritDamage1"]
		"MaxHealthToDamage1":
			return connected["RampingDamage1"] > 0
		"Health7":
			return connected["Health6"] >= max["Health6"]
		"Infinity1":
			return connected["Health7"] > 0
		"Infinity2":
			return connected["Infinity1"] > 0
		"Infinity3":
			return connected["Infinity2"] > 0
		"Infinity4":
			return connected["Infinity3"] > 0
		"Infinity5":
			return connected["Infinity4"] > 0
		"Infinity6":
			return connected["Infinity5"] > 0
		"Infinity7":
			return connected["Infinity6"] > 0
		"Infinity8":
			return connected["Infinity7"] > 0
		"Infinity9":
			return connected["Infinity8"] > 0
		"Laboratory":
			return connected["Infinity9"] > 0
		"YellowSpawn2":
			return connected["Infinity9"] > 0
		"AutoCollect":
			return connected["Size3"] > 0
	
	return true


func gain_milestone(milestone: Milestone) -> void:
	match milestone.id:
		"Reds500":
			State.bits += 500
		"Blues10":
			State.nodes += 5
		"Reds2k":
			State.bits += 3000
		"Blues100":
			State.nodes += 100
		"Reds4k":
			State.bits += 5000
		"Blues200":
			State.nodes += 200
		"Reds6k":
			State.bits += 8000
		"Blues300":
			State.nodes += 300
		"Reds8k":
			State.bits += 12000
		"Blues500":
			State.nodes += 500
		"Reds10k":
			State.bits += 16000
		"Blues800":
			State.nodes += 800
		"Yellows5":
			State.processors += 1
		"Reds15k":
			State.bits += 20000
		"Blues1.2k":
			State.nodes += 1200
		"Yellows10":
			State.processors += 1
		"Reds20k":
			State.bits += 30000
		"Blues1.6k":
			State.nodes += 1600
		"Yellows15":
			State.processors += 1
		"Reds30k":
			State.bits += 50000
		"Blues2k":
			State.nodes += 2000
		"Reds50k":
			State.bits += 100000
		"Blues4k":
			State.nodes += 4000
		"Reds100k":
			State.bits += 1000000
		"Blues8k":
			State.nodes += 8000

# Returns a percentage of completion. If >=1 then milestone can be claimed
func check_milestone(milestone: Milestone) -> float:
	match milestone.id:
		"Reds500":
			return State.nums.reds_killed/500.0
		"Blues10":
			return State.nums.blues_killed/10.0
		"Reds2k":
			return State.nums.reds_killed/2000.0
		"Blues100":
			return State.nums.blues_killed/100.0
		"Reds4k":
			return State.nums.reds_killed/4000.0
		"Blues200":
			return State.nums.blues_killed/200.0
		"Reds6k":
			return State.nums.reds_killed/6000.0
		"Blues300":
			return State.nums.blues_killed/300.0
		"Reds8k":
			return State.nums.reds_killed/8000.0
		"Blues500":
			return State.nums.blues_killed/500.0
		"Reds10k":
			return State.nums.reds_killed/10000.0
		"Blues800":
			return State.nums.blues_killed/800.0
		"Yellows5":
			return State.nums.yellows_killed/5.0
		"Reds15k":
			return State.nums.reds_killed/15000.0
		"Blues1.2k":
			return State.nums.blues_killed/1200.0
		"Yellows10":
			return State.nums.yellows_killed/10.0
		"Reds20k":
			return State.nums.reds_killed/20000.0
		"Blues1.6k":
			return State.nums.blues_killed/1600.0
		"Yellows15":
			return State.nums.yellows_killed/15.0
		"Reds30k":
			return State.nums.reds_killed/30000.0
		"Blues2k":
			return State.nums.blues_killed/2000.0
		"Reds50k":
			return State.nums.reds_killed/50000.0
		"Blues4k":
			return State.nums.blues_killed/4000.0
		"Reds100k":
			return State.nums.reds_killed/100000.0
		"Blues8k":
			return State.nums.blues_killed/8000.0
	return false
