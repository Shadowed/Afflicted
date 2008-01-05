if( GetLocale() ~= "deDE" ) then
	return
end

AfflictedLocals = setmetatable({
	-- Spells
	["Divine Shield"] = "Gottesschild",
	["Ice Block"] = "Eisblock",
	["Feral Charge"] = "Wilde Attacke",
	["Silencing Shot"] = "Unterdr\195\188ckender Schuss",
	["Blessing of Protection"] = "Segen des Schutzes",
	["Blessing of Freedom"] = "Segen der Freiheit",
	["Blessing of Sacrifice"] = "Segen der Opferung",
	["Cloak of Shadows"] = "Mantel der Schatten",
	["Spell Reflection"] = "Zauberreflektion",
	["Spell Lock"] = "Zaubersperre",
	["Counterspell - Silenced"] = "Gegenzauber - zum Schweigen gebracht",
	["Counterspell"] = "Gegenzauber",
	
	-- Slash command
	["Afflicted slash commands"] = "Afflicted Slashkommandos",
	["- test - Show 5 buff and 5 silence/interrupt test timers."] = "- test - zeigt 5 Buff- und Schweigen-/Unterbrechungseffektimer an.",
	["- ui - Opens the OptionHouse configuration for Afflicted."] = "- ui - \195\182ffnet die OptionHouse Konfiguration f\195\188r Afflicted.",
	["- toggle - Toggles the anchors shown/hidden."] = "- toggle - Blendet die Anker ein/aus.",
	
	-- GUI
	["General"] = "Allgemein",
	["Timers"] = "Timer",
	["Alerts"] = "Warnungen",
	
	["Test Timers"] = "Test Timer",
	
	["Show buff timers"] = "Bufftimer zeigen",
	["Show timers on buffs like Divine Shield, Ice Block, Blessing of Protection and so on, for how long until they fade."] = "Zeigt Timer f\195\188r Buffs wie Gottesschild, Eisblock, Segen des Schutzes usw., wie viel Zeit verbleibt bis sie auslaufen.",
	
	["Show silence and interrupt timers"] = "Stille- und Unterbrechungseffekttimer",
	["Show timers on silence and interrupt spells like Spell Lock or Silencing Shot, for how long until they're ready again."] = "Zeigt Timer f\195\188r Stille- und Unterbrechungszauber wie Zaubersperre und Unterdr\195\188ckenden Schuss, wie lang es dauert bis diese wieder bereit sind.",
	
	["ALT + Drag the anchors to move the frames."] = "ALT + ziehen der Anker, um die Frames zu verschieben",
	["Show timers anchor"] = "Timer - Anker zeigen",
	
	["Only enable inside arenas"] = "Nur in der Arena Aktivieren",
	["No timers, interrupt or removal alerts will be shown outside of arenas."] = "Es werden keine Timer, Unterbrechungs- oder Entfernungswarnungen au\195\159erhalb der Arena angezeigt.",
	
	["Show interrupt alerts"] = "Unterbrechungswarnungen zeigen",
	["Shows player name, and the spell you interrupted to chat."] = "Zeigt den Spielernamen sowie den unterbrochenen Zauber im Chat.",
		
	["Chat frame"] = "Chat frame",
	["Frame to show alerts in."] = "Frame, in dem Warnungen gezeigt werden.",
	
	["Show spell removal alerts"] = "Warnungen beim Entfernen von Zaubern anzeigen",
	["Shows spells that you remove from enemies to chat, or failed attempts at removing something."] = "Zeigt Zauber, die Ihr von Gegnern entfernt, im Chat -  genauso wie Fehlversuche beim Entfernen.",
	
	["Scale: %d%%"] = "Gr\195\182\195\159e: %d%%",
	
	["Frame"] = "Frame",
	
	["Announce Timers"] = "Ansagentimer",
	["Announces when the selected types of abilities are used, and are over."] = "Zeigt an, wenn die ausgew\195\163 hlten F\195\163 higkeiten benutzt werden, und wenn diese auslaufen.",
	["Interrupts & Silences"] = "Unterbrechungen und Stilleeffekte",
	["Buffs"] = "Buffs",
	
	["Grow Up"] = "Nach oben wachsen",
	["Timers that should grow up instead of down."] = "Timer, die nicht nach unten, sondern nach oben wachsen sollten.",
}, {__index = AfflictedLocals})