-- Translated by wowui.cn

if( GetLocale() ~= "zhCN" ) then
	return
end

AfflictedLocals = setmetatable({
	["Interrupted %s's %s"] = "打断 %s 的 %s",
	["Interrupted %s"] = "打断 %s",
	
	["FAILED %s's %s"] = "失败 %s 的 %s",
	["Removed %s's %s"] = "移除 %s 的 %s",
	
	["FINISHED *spell (*target)"] = "结束 *spell (*target)",
	["USED *spell (*target)"] = "使用 *spell (*target)",
	
	["READY *spell (*target)"] = "就绪 *spell (*target)",
	
	["ALT + Drag to move the frame anchor."] = "ALT + 拖动 来移动框体锚点.",
	
	-- Default frames
	["Spells"] = "法术",
	["Buffs"] = "增益",
	["Cooldowns"] = "冷却",
	["Totems"] = "图腾",
	
	-- Schools
	["Schools"] = "法术系",
	["School Lockout"] = "法术系锁定",
	["Physical"] = "物理",
	["Holy"] = "神圣",
	["Fire"] = "火焰",
	["Nature"] = "自然",
	["Frost"] = "冰霜",
	["Shadow"] = "暗影",
	["Arcane"] = "奥术",

	-- Cmd
	["Afflicted slash commands"] = "Afflicted命令行",
	["- clear - Clears all running timers."] = "- clear - 清除所有运行的计时条.",
	["- ui - Opens the configuration for Afflicted."] = "- ui - 打开Afflicted的配置.",
	["- test - Shows test timers in Afflicted."] = "- test - 显示Afflicted测试计时条.",
	
	["Your configuration has been upgraded to the latest version, anchors and spells have been wiped."] = "你的配置已被更新到最新版本, 锚点和法术已被重置.",
	["Your configuration has been reset to the defaults."] = "你的配置已被重置到默认.",
	
	-- GUI
	["General"] = "一般选项",
	["Bars"] = "计时条",
	["Icons"] = "图标",
	["Dispels"] = "驱散",
	["Interrupts"] = "打断",
	["Anchors"] = "锚点",
	
	["Combat text"] = "战斗文本",
	["Chat frame #%d"] = "聊天框 #%d",
	["Party"] = "小队",
	["Raid"] = "团队",
	["Raid warning"] = "团队警报",
	["Middle of screen"] = "屏幕中间",
	["None"] = "无",

	-- General
	["2 vs 2"] = "2 vs 2",
	["3 vs 3"] = "3 vs 3",
	["5 vs 5"] = "5 vs 5",
	
	["Spells that should be DISABLED for this specific arena bracket.\nThis means do not check everything and then complain that it's broken."] = "需要在特殊的竞技场环境下禁用的法术.\n这意味着不要去勾选并抱怨这怎么不能用了.",
	
	["%s in %dvs%d\nAnchor: %s\nDuration: %d\nCooldown: %d (%s)"] = "%s 在 %dvs%d\n锚点: %s\n持续: %d\n冷却: %d (%s)",
	
	["Arena spells"] = "竞技场法术",
	
	["Hide timer anchors"] = "隐藏计时条锚点",
	["Hides the anchors that lets you drag timer groups around."] = "隐藏可以拖动计时条分组的锚点.",
	
	["Show spell icons"] = "显示法术图标",
	["Prefixes messages with the spell icon if you're using local outputs."] = "如果你使用本地输出则在法术图标显示前缀信息.",
	
	["Only show target/focus timers"] = "仅显示目标/焦点的计时器",
	["Only timers of people you have targeted, or focused will be triggered. They will not be removed if you change targets however."] = "仅显示目标/焦点的计时器. 在你改变目标后将自动移除.",
	
	["Timer display"] = "计时器显示",

	["Global display setting, changing these will change all the anchors settings.\nNOTE: These values do not always reflect each anchors configuration, this is just a quick way to set all of them to the same thing."] = "全局显示设置, 此改动将影响全部的锚点设置.\n注意: 这些值不会影响每个锚点的配置, 仅是一种快捷的方式将锚点设置为一样.",
	["Display style"] = "显示样式",
	
	["Max timers"] = "最大计时条",
	["Maximum amount of timers that should be ran per an anchor at the same time, if too many are running at the same time then the new ones will simply be hidden until older ones are removed."] = "每个锚点下同一时间显示的最大的计时条数量, 如果同一时间超出这个值那么新的计时条将被隐藏直到旧的计时条被移除.",
	
	["Bar only"] = "仅显示计时条",
	["Configuration that only applies to bar displays."] = "配置成仅显示计时条.",

	["Only show triggered name in text"] = "仅显示已触发名字",
	["Instead of showing both the spell name and the triggered name, only the name will be shown in the bar."] = "仅在计时条内显示已触发的名字而不是同时显示法术名字和已触发的名字.",

	["Fade time"] = "渐隐时间",
	["How many seconds it should take after a bar is finished for it to fade out."] = "设置计时条在几秒内结束时渐隐.",

	["Icon position"] = "图标位置",
	["Left"] = "左",
	["Right"] = "右",
	
	["Bar width"] = "计时条宽",
	["Bar texture"] = "计时条材质",
	
	["Per anchor display for how timers should be displayed."] = "每个锚点的计时器的显示方式.",
	
	["Text color"] = "文本颜色",
	["Alert text color, only applies to local outputs."] = "警报文字的颜色, 仅用来本地输出.",
	
	["Alerts"] = "警报",
	
	["Announce destination"] = "通报目标",
	["Location to send announcements for this option to."] = "发送通报到目的地的选项.",
	
	["Enable dispel alerts"] = "启用驱散警报",
	["Displays alerts when you dispel a friendly player, can also be enabled to show alerts for enemies as well."] = "当你驱散了一个友方玩家时显示警报, 也可以启用显示敌对玩家的警报.",
	
	["Show alerts for dispelling enemies"] = "显示驱散敌对玩家时的警报",
	["Enables showing alerts for when you dispel enemies as well as friendly players."] = "当你驱散了一个敌对玩家时显示警报.",
	
	["Enable interrupt alerts"] = "启用打断警报",
	["Displays alerts when you interrupt enemies."] = "当你打断了一个敌对玩家时显示警报.",
	
	["Allows you to quickly enable or disable spells in Afflicted."] = "允许你在Afflicted里快速启用或禁用法术.",
	
	["Everywhere else"] = "任何地方",
	["Battlegrounds"] = "战场",
	["Arenas"] = "竞技场",
	["Raid instances"] = "团队副本",
	["Party instances"] = "小队副本",
	
	["Enable Afflicted inside"] = "在这里面启用Afflicted",
	["Allows you to set what scenario's Afflicted should be enabled inside."] = "允许你设置在哪些情况下启用Afflicted.",
	
	["Only show triggered name in text"] = "仅显示已触发名字",
	["Instead of showing both the spell name and the triggered name, only the name will be shown in the bar."] = "仅在计时条内显示已触发的名字而不是同时显示法术名字和已触发的名字.",
	
	-- Anchors
	["You must enter a name for this anchor."] = "你必须为这个锚点输入一个名字.",
	["The anchor \"%s\" already exists."] = "这个锚点 \"%s\" 已经存在.",
	
	["Anchor name"] = "锚点名字",
	["Name of the new anchor to create that timers can be shown under."] = "显示计时条的新的锚点名字.",
	
	["Enable showing timers in this anchor"] = "启用在这个锚点里显示计时条",
	["Allows timers to be shown under this anchor, if the anchor is disabled you won't see any timers."] = "允许在这个计时条下显示计时条, 如果此锚点被禁用你将看不到任何计时条.",
	
	["Grow display up"] = "计时条向上增长显示",
	["Instead of adding everything from top to bottom, timers will be shown from bottom to top."] = "计时条将从下往上增长,而不是从上往下.",
	
	["Display scale"] = "显示缩放",
	["How big the actual timers should be."] = "计时条的大小.",
	
	["Announcements"] = "通报",
	
	["Enable announcements"] = "启用通报",
	["Enables showing alerts for when timers are triggered to this anchor."] = "启用当计时条在这个锚点被触发时显示警报.",
	
	["Announce text"] = "通报文本",
		
	["Announcement text for when timers are triggered in this anchor. You can use *spell for the spell name, and *target for the person who triggered it (if any)."] = "当计时条在这个锚点被触发时的通报文本. 你可以使用 *spell 参数来显示法术名字, 和 *target 参数来显示触发的玩家 (如果有的话).",
	
	["Allows you to add a new anchor to Afflicted that you can then show timers under."] = "允许你增加一个新的锚点到Afflicted以来显示计时条.",
	
	["Redirection"] = "重定向",
	["Redirect bars to group"] = "重定向计时条到分组",
	["Group name to redirect bars to, this lets you show Afflicted timers under another addons bar group. Requires the bars to be created using GTB, and the bar display to be enabled for this anchor."] = "重定向计时条到分组的名字, 让你将Afflicted计时条显示到其他插件的计时条分组. 这个需要计时条使用GTB来创建, 而且这个锚点的计时条已启用.",
	
	-- Spells
	["You must enter a spell name, or spellID for this."] = "你必须输入一个法术名字, 或者法术ID.",
	["The spell \"%s\" already exists."] = "法术 \"%s\" 已经存在.",
	
	["Allows you to add a new spell that Afflicted should start tracking."] = "允许你增加一个Afflicted开始追踪的新的法术.",
	["Spell name or spell ID"] = "法术名字或者法术ID",
	["The name of the spell, or the spell ID. This is note always the exact spell name, for example Intercept is actually Intercept Stun."] = "法术名字或者法术ID. 这个需要完整的法术名字, 如： 拦截必须设置为拦截昏迷.",
	
	["Disable spell"] = "禁用法术",
	["While disabled, this spell will be completely ignored and no timer will be started for it."] = "当禁用时, 这个法术将完全被忽略并且无任何计时条.",
	
	["Timer"] = "计时条",
	
	["Repeating timer"] = "循环计时条",
	["Sets the timer as repeating, meaning once it hits 0 it'll start back up at the original time until the timer is specifically removed."] = "设置计时条为循环, 这意味着当计时到0时计时器将重新从起点开始计时,直到这个计时条已被明确的移除.",
	
	["Fade early if buff is removed"] = "Fade early if buff is removed",
	["Sets if the spell duration should be removed early, if the buff fades before the time runs out. (Dispelled, clicked off, and so on)"] = "Sets if the spell duration should be removed early, if the buff fades before the time runs out. (Dispelled, clicked off, and so on)",
	["Prevents the timer from ending early due to the spell fading early before the timer runs out."] = "Prevents the timer from ending early due to the spell fading early before the timer runs out.",
	
	["Duration"] = "持续时间",
	["How many seconds this timer should last."] = "这个计时条持续的秒数.",
	
	["Show inside anchor"] = "显示内置锚点",
	["Anchor to display this timer inside, if the anchor is disabled then this timer won't show up."] = "这个计时器内置的锚点显示, 如果锚点被禁用那么将不显示.",
	
	["Link spell to"] = "链接法术到",
	["If you link this spell to another, then it means this spell will not trigger a new timer started while the timer is running for the spell it's linked to."] = "如果你链接这个法术到锚点, 这意味着当计时器被法术链接到时这个法术才触发一个新的计时器.",
	
	["Icon path"] = "图标路径",
	["Icon path to use for display, you do not have to specify this option. As long as you leave it blank or using the question mark icon then will auto-detect and save it."] = "用来显示的图标路径, 你不需要特别的设置这个选项. 你可以留空或者使用问题标记图标将自动检测并保存.",
	
	["Check events to trigger"] = "检测触发器的事件",
	["List of events that should be checked to see if we should trigger this timer."] = "触发这个计时器时用来检测的事件列表.",
	
	["General damage/misses/resists"] = "一般 伤害/未命中/抵抗",
	
	["Group, gained debuff"] = "小队, 获得减益效果",
	["Enemy, gained buff"] = "敌对, 获得增益效果",
	["Enemy, summons object"] = "敌对, 召唤",
	["Enemy, creates object"] = "敌对, 制造",
	["Group, interrupted by enemy"] = "小队, 被敌对打断",
	["Enemy, successfully casts"] = "敌对, 成功施放",
	["Enemy, gained debuff"] = "敌对, 获得减益效果",
	
	["Custom announcements"] = "自定义通报",
	
	["Enable custom messages"] = "启用自定义信息",
	["Allows you to override the per-anchor messages for this specific timer, if the anchor has announcements disabled then this will do nothing."] = "允许你为这个特别的计时条覆盖原有的锚点通报信息, 如果锚点的通报被禁用这个选项将无效",
	
	["Triggered message"] = "触发信息",
	["Custom message to use for when this timer starts, if you leave the message blank and you have custom messages enabled then no message will be given when it's triggered."] = "当开始计时开始时的自定义信息, 如果你留空并且你启用了自定义信息那么当计时触发时将不显示任何信息.",
	
	["Ended message"] = "结束信息",
	["Custom message to use for when this timer ends, if you leave the message blank and you have custom messages enabled then no message will be given when it's ends."] = "当计时结束时的自定义信息, 如果你留空并且你启用了自定义信息那么当计时结束时将不显示任何信息.",
	
	["Cooldown"] = "冷却",
	["Allows you to start a new timer when this one is triggered that has the cooldown left on the ability, use this if you want to track both the timer duration and the timer cooldown."] = "允许你在技能的左边开始一个新的冷却计时器, 在你想要追踪持续时间和冷却的时候使用.",
	
	["How many seconds this cooldown timer should last."] = "这个冷却计时器持续的秒数.",
	
	["Disabled"] = "已禁用",
	["Enabled"] = "已启用",
	
	["Timer disabled"] = "计时器已禁用",
	["Timer enabled"] = "计时器已启用",
	
	["New spell"] = "新的法术",
	["Spell list"] = "法术列表",
	["Edit"] = "编辑",
	["Delete"] = "删除",
	["Enable"] = "启用",
	["Disable"] = "禁用",
	["%s\nAnchor: %s\nDuration: %d\nCooldown: %d (%s)"] = "%s\n锚点: %s\n持续: %d\n冷却: %d (%s)",

	["Enable cooldown"] = "启用冷却",
	["While disabled, no cooldown will be started when this timer is triggered."] = "当禁用时, 当计时条被触发时将不开始冷却计时.",
	["Anchor to display this cooldown timer inside, if the anchor is disabled nothing will be shown."] = "显示这个冷却计时器的锚点, 如果锚点被禁用那么将不显示.",
	
	["Delete"] = "删除",
	["None"] = "无",
	
	["You can delete spells manually added through this, note that spells that are included with Afflicted by default cannot be deleted. All this will do is reset them to the default values."] = "你可以在这里手动删除法术, 需要注意的是Afflicted内置的默认法术不能被删除. 所有的变动将重置他们到默认值.",
	["Are you REALLY sure you want to delete this spell?"] = "你真的想删除这个法术吗?",
	
	-- Profile options
	["Profile Options"] = "配置文件选项",
}, {__index = AfflictedLocals})