-- Look and feel configuration

hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 5,
		border_size = 2,
		extend_border_grab_area = 10,
		resize_on_border = true,
		col = {
			active_border = {
				colors = { ORANGE_ACCENT, ORANGE_MAIN },
				angle = 45,
			},
			inactive_border = ORANGE_MUTED,
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
		dim_special = 0.3,
		rounding = 0,
		active_opacity = 0.95,
		inactive_opacity = 0.85,
		fullscreen_opacity = 1,
		shadow = {
			enabled = false,
			range = 10,
			render_power = 3,
			color = "rgba(ff6b002a)",
		},
		blur = {
			size = 2,
			passes = 2,
			special = true,
		},
	},
})
