-- Look and feel configuration

hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 4,
		border_size = 2,
		extend_border_grab_area = 10,
		resize_on_border = true,
		col = {
			active_border = {
				colors = { ORANGE_ACCENT, ORANGE_MAIN, ORANGE_DARK },
				angle = 45,
			},
			inactive_border = "rgba(40251588)",
		},
	},
	group = {
		col = {
			border_active = ORANGE_MAIN,
			border_inactive = ORANGE_MUTED,
			border_locked_active = ORANGE_DARK,
			border_locked_inactive = ORANGE_MUTED,
		},
		groupbar = {
			col = {
				active = ORANGE_MAIN,
				inactive = ORANGE_MUTED,
				locked_active = ORANGE_DARK,
				locked_inactive = ORANGE_MUTED,
			},
		},
	},
	decoration = {
		dim_special = 0.35,
		rounding = 10,
		active_opacity = 0.96,
		inactive_opacity = 0.88,
		fullscreen_opacity = 1.0,
		shadow = {
			enabled = false,
		},
		blur = {
			enabled = true,
			size = 6,
			passes = 3,
			vibrancy = 0.2,
			new_optimizations = true,
			ignore_opacity = true,
			special = true,
			xray = false,
		},
	},
})
