#!/usr/bin/env bash
# Update script adapted for NixOS

usage() {
	cat <<-EOF
		USAGE: ${0##*/} [option]

		Update / nixos-rebuild helper

		OPTIONS:
		  module    Output Waybar module
		  <none>    Launch the CLI
	EOF
}

output_module() {
	icon='󱄅'
	tooltip="<b>NixOS</b>: System Ready\nClick to rebuild/switch"
	echo "{\"text\": \"$icon\", \"tooltip\": \"$tooltip\"}"
}

update_packages() {
	echo -e "\e[34mRunning nixos-rebuild switch...\e[39m\n"
	sudo nixos-rebuild switch
	notify-send "NixOS Update" "Rebuild finished" -i "system-software-update" 2>/dev/null || true
	echo -e "\n\e[32mFinished!\e[39m\n"
	read -rsn 1 -p "Press any key to exit..."
}

main() {
	case $1 in
		module)
			output_module
			;;
		'')
			trap "pkill -RTMIN+1 waybar 2>/dev/null" EXIT
			update_packages
			;;
		*)
			usage >&2
			return 1
			;;
	esac
}

main "$@"
