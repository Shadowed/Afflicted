AfflictedLocals = {
	["Interrupted %s's %s (%s)"] = "Interrupted %s's %s (%s)",
	["FAILED %s's %s"] = "FAILED %s's %s",
	["Removed %s's %s"] = "Removed %s's %s",
	
	["GAINED *spell (*target)"] = "GAINED *spell (*target)",
	["USED *spell (*target)"] = "USED *spell (*target)",
	["FADED *spell (*target)"] = "FADED *spell (*target)",
	["READY *spell (*target)"] = "READY *spell (*target)",
	
	-- Default frames
	["Spells"] = "Spells",
	["Buffs"] = "Buffs",
	["Cooldowns"] = "Cooldowns",
	
	-- Schools
	["Schools"] = "Schools",
	["School Lockout"] = "School Lockout",
	["Physical"] = "Physical",
	["Holy"] = "Holy",
	["Fire"] = "Fire",
	["Nature"] = "Nature",
	["Frost"] = "Frost",
	["Shadow"] = "Shadow",
	["Arcane"] = "Arcane",

	-- Cmd
	["Afflicted slash commands"] = "Afflicted slash commands",
	["- clear - Clears all running timers."] = "- clear - Clears all running timers.",
	["- ui - Opens the configuration for Afflicted."] = "- ui - Opens the configuration for Afflicted.",
	["- test - Shows test timers in Afflicted."] = "- test - Shows test timers in Afflicted.",
	
	["Your configuration has been upgraded to the latest version, anchors and spells have been wiped."] = "Your configuration has been upgraded to the latest version, anchors and spells have been wiped.",
	
	-- GUI
	["General"] = "General",
	["Bars"] = "Bars",
	["Dispels"] = "Dispels",
	["Interrupts"] = "Interrupts",
	["Anchors"] = "Anchors",
	
	["Combat text"] = "Combat text",
	["Chat frame #%d"] = "Chat frame #%d",
	["Party"] = "Party",
	["Raid"] = "Raid",
	["Raid warning"] = "Raid warning",
	["Middle of screen"] = "Middle of screen",
	["None"] = "None",

	-- General
	["Show anchors"] = "Show anchors",
	["Display timer anchors for moving around."] = "Display timer anchors for moving around.",

	["Show spell icons"] = "Show spell icons",
	["Prefixes messages with the spell icon if you're using local outputs."] = "Prefixes messages with the spell icon if you're using local outputs.",
	
	["Only show target/focus timers"] = "Only show target/focus timers",
	["Only timers of people you have targeted, or focused will be triggered. They will not be removed if you change targets however."] = "Only timers of people you have targeted, or focused will be triggered. They will not be removed if you change targets however.",
	
	["Use bar display"] = "Use bar display",
	["Displays timers using a bar format instead of the standard icons.\nRequires a game restart to take effect."] = "Displays timers using a bar format instead of the standard icons.\nRequires a game restart to take effect.",
	
	["Bar width"] = "Bar width",
	["Bar texture"] = "Bar texture",
	
	["Text color"] = "Text color",
	["Alert text color, only applies to local outputs."] = "Alert text color, only applies to local outputs.",
	
	["Announce destination"] = "Announce destination",
	["Location to send announcements for this option to."] = "Location to send announcements for this option to.",
	
	["Enable dispel alerts"] = "Enable dispel alerts",
	["Displays alerts when you dispel a friendly player, can also be enabled to show alerts for enemies as well."] = "Displays alerts when you dispel a friendly player, can also be enabled to show alerts for enemies as well.",
	
	["Show alerts for dispelling enemies"] = "Show alerts for dispelling enemies",
	["Enables showing alerts for when you dispel enemies as well as friendly players."] = "Enables showing alerts for when you dispel enemies as well as friendly players.",
	
	["Enable interrupt alerts"] = "Enable interrupt alerts",
	["Displays alerts when you interrupt enemies."] = "Displays alerts when you interrupt enemies.",
		
	["Everywhere else"] = "Everywhere else",
	["Battlegrounds"] = "Battlegrounds",
	["Arenas"] = "Arenas",
	["Raid instances"] = "Raid instances",
	["Party instances"] = "Party instances",
	
	["Enable Afflicted inside"] = "Enable Afflicted inside",
	["Allows you to set what scenario's Afflicted should be enabled inside."] = "Allows you to set what scenario's Afflicted should be enabled inside.",
	
	["Only show triggered name in text"] = "Only show triggered name in text",
	["Instead of showing both the spell name and the triggered name, only the name will be shown in the bar."] = "Instead of showing both the spell name and the triggered name, only the name will be shown in the bar.",
	
	-- Anchors
	["You must enter a name for this anchor."] = "You must enter a name for this anchor.",
	["The anchor \"%s\" already exists."] = "The anchor \"%s\" already exists.",
	
	["Anchor name"] = "Anchor name",
	["Name of the new anchor to create that timers can be shown under."] = "Name of the new anchor to create that timers can be shown under.",
	
	["Enable anchor"] = "Enable anchor",
	["Allows timers to be shown under this anchor, if the anchor is disabled you won't see any timers."] = "Allows timers to be shown under this anchor, if the anchor is disabled you won't see any timers.",
	
	["Grow display up"] = "Grow display up",
	["Instead of adding everything from top to bottom, timers will be shown from bottom to top."] = "Instead of adding everything from top to bottom, timers will be shown from bottom to top.",
	
	["Display scale"] = "Display scale",
	["How big the actual timers should be."] = "How big the actual timers should be.",
	
	["Announcements"] = "Announcements",
	
	["Enable announcements"] = "Enable announcements",
	["Enables showing alerts for when timers are triggered to this anchor."] = "Enables showing alerts for when timers are triggered to this anchor.",
	
	["Announce text"] = "Announce text",
	
	["Gained message"] = "Gained message",
	["Messages that cause someone to gain a buff, or a debuff."] = "Messages that cause someone to gain a buff, or a debuff.",

	
	["Used message"] = "Used message",
	["Messages that were triggered due to an ability being used."] = "Messages that were triggered due to an ability being used.",
	

	["Ready message"] = "Ready message",
	["Messages that were triggered due to an ability being used, and the ability is either over or is ready again."] = "Messages that were triggered due to an ability being used, and the ability is either over or is ready again.",
	
	["Fade message"] = "Fade message",
	["Messages that were triggered by someone gaining a buff, or a debuff that has faded."] = "Messages that were triggered by someone gaining a buff, or a debuff that has faded.",
		
	["Announcement text for when timers are triggered in this anchor. You can use *spell for the spell name, and *target for the person who triggered it (if any)."] = "Announcement text for when timers are triggered in this anchor. You can use *spell for the spell name, and *target for the person who triggered it (if any).",
	
	["Allows you to add a new anchor to Afflicted that you can then show timers under."] = "Allows you to add a new anchor to Afflicted that you can then show timers under.",
	
	["Redirection"] = "Redirection",
	["Redirect bars to group"] = "Redirect bars to group",
	["Group name to redirect bars to, this lets you show Afflicted timers under another addons bar group. Requires the bars to be created using GTB."] = "Group name to redirect bars to, this lets you show Afflicted timers under another addons bar group. Requires the bars to be created using GTB.",
	
	-- Spells
	["You must enter a spell name, or spellID for this."] = "You must enter a spell name, or spellID for this.",
	["The spell \"%s\" already exists."] = "The spell \"%s\" already exists.",
	
	["Allows you to add a new spell that Afflicted should start tracking."] = "Allows you to add a new spell that Afflicted should start tracking.",
	["Spell name or spell ID"] = "Spell name or spell ID",
	["The name of the spell, or the spell ID. This is note always the exact spell name, for example Intercept is actually Intercept Stun."] = "The name of the spell, or the spell ID. This is note always the exact spell name, for example Intercept is actually Intercept Stun.",
	
	["Disable spell"] = "Disable spell",
	["While disabled, this spell will be completely ignored and no timer will be started for it."] = "While disabled, this spell will be completely ignored and no timer will be started for it.",
	
	["Timer"] = "Timer",
	
	["Repeating timer"] = "Repeating timer",
	["Sets the timer as repeating, meaning once it hits 0 it'll start back up at the original time until the timer is specifically removed."] = "Sets the timer as repeating, meaning once it hits 0 it'll start back up at the original time until the timer is specifically removed.",
	
	["Ignore fade events"] = "Ignore fade events",
	["Prevents the timer from ending early due to the spell fading early before the timer runs out."] = "Prevents the timer from ending early due to the spell fading early before the timer runs out.",
	
	["Duration"] = "Duration",
	["How many seconds this timer should last."] = "How many seconds this timer should last.",
	
	["Show inside anchor"] = "Show inside anchor",
	["Anchor to display this timer inside, if the anchor is disabled then this timer won't show up."] = "Anchor to display this timer inside, if the anchor is disabled then this timer won't show up.",
	
	["Link spell to"] = "Link spell to",
	["If you link this spell to another, then it means this spell will not trigger a new timer started while the timer is running for the spell it's linked to."] = "If you link this spell to another, then it means this spell will not trigger a new timer started while the timer is running for the spell it's linked to.",
	
	["Trigger limits"] = "Trigger limits",
	["Lets you prevent timers from trigger too quickly, causing duplicates."] = "Lets you prevent timers from trigger too quickly, causing duplicates.",
	
	["Per-player limit"] = "Per-player limit",
	["How many seconds between the time this timer triggers, and the next one can trigger. This is the per player one, meaning it won't trigger more then the set amount per the player it triggered on/from."] = "How many seconds between the time this timer triggers, and the next one can trigger. This is the per player one, meaning it won't trigger more then the set amount per the player it triggered on/from.",
	
	["Per-spell limit"] = "Per-spell limit",
	["How many seconds between the time this timer triggers, and the next one can trigger. This is the per spell one, meaning it won't trigger more then the set amount per the spellID that triggers it."] = "How many seconds between the time this timer triggers, and the next one can trigger. This is the per spell one, meaning it won't trigger more then the set amount per the spellID that triggers it.",
	
	["Icon path"] = "Icon path",
	["Icon path to use for display, you do not have to specify this option. As long as you leave it blank or using the question mark icon then will auto-detect and save it."] = "Icon path to use for display, you do not have to specify this option. As long as you leave it blank or using the question mark icon then will auto-detect and save it.",
	
	["Check events to trigger"] = "Check events to trigger",
	["List of events that should be checked to see if we should trigger this timer."] = "List of events that should be checked to see if we should trigger this timer.",
	
	["General damage/misses/resists"] = "General damage/misses/resists",
	
	["Group, gained debuff"] = "Group, gained debuff",
	["Enemy, gained buff"] = "Enemy, gained buff",
	["Enemy, summons object"] = "Enemy, summons object",
	["Enemy, creates object"] = "Enemy, creates object",
	["Group, interrupted by enemy"] = "Group, interrupted by enemy",
	["Enemy, successfully casts"] = "Enemy, successfully casts",
	["Enemy, gained debuff"] = "Enemy, gained debuff",
	
	["Custom announcements"] = "Custom announcements",
	
	["Enable custom messages"] = "Enable custom messages",
	["Allows you to override the per-anchor messages for this specific timer."] = "Allows you to override the per-anchor messages for this specific timer.",
	
	["Triggered message"] = "Triggered message",
	["Custom message to use for when this timer starts, if you leave the message blank and you have custom messages enabled then no message will be given when it's triggered."] = "Custom message to use for when this timer starts, if you leave the message blank and you have custom messages enabled then no message will be given when it's triggered.",
	
	["Ended message"] = "Ended message",
	["Custom message to use for when this timer ends, if you leave the message blank and you have custom messages enabled then no message will be given when it's ends."] = "Custom message to use for when this timer ends, if you leave the message blank and you have custom messages enabled then no message will be given when it's ends.",
	
	["Cooldown"] = "Cooldown",
	["Allows you to start a new timer when this one is triggered that has the cooldown left on the ability, use this if you want to track both the timer duration and the timer cooldown."] = "Allows you to start a new timer when this one is triggered that has the cooldown left on the ability, use this if you want to track both the timer duration and the timer cooldown.",
	
	["How many seconds this cooldown timer should last."] = "How many seconds this cooldown timer should last.",
	
	["New spell"] = "New spell",
	["Spell list"] = "Spell list",
	["Edit"] = "Edit",
	["Delete"] = "Delete",
	["Enable"] = "Enable",
	["Disable"] = "Disable",
	
	["Dur: %d / CD: %d / Anchor: %s"] = "Dur: %d / CD: %d / Anchor: %s",
	
	["Enable cooldown"] = "Enable cooldown",
	["While disabled, no cooldown will be started when this timer is triggered."] = "While disabled, no cooldown will be started when this timer is triggered.",
	["Anchor to display this cooldown timer inside, if the anchor is disabled nothing will be shown."] = "Anchor to display this cooldown timer inside, if the anchor is disabled nothing will be shown.",
	
	["Delete"] = "Delete",
	["None"] = "None",
	
	["You can delete spells manually added through this, note that spells that are included with Afflicted by default cannot be deleted. All this will do is reset them to the default values."] = "You can delete spells manually added through this, note that spells that are included with Afflicted by default cannot be deleted. All this will do is reset them to the default values.",
	["Are you REALLY sure you want to delete this spell?"] = "Are you REALLY sure you want to delete this spell?",
	
	-- Profile options
	["Profile Options"] = "Profile Options",
	
}