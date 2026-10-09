#!/usr/bin/env bash
# Post-hook de matugen: recarga configs y repinta bordes.
# Nota: mango 0.17.5 no repinta los bordes de ventanas ya abiertas tras un
# reload, solo en cambios de foco. Por eso, tras reload_config, se enfoca
# cada ventana visible (repintando su borde) y se restaura el foco original.
set -u

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Localizar el socket de mango
if [ -n "${MANGO_INSTANCE_SIGNATURE:-}" ]; then
    sock="$MANGO_INSTANCE_SIGNATURE"
else
    sock=""
    for s in "$runtime_dir"/mango-*.sock; do
        [ -S "$s" ] || continue
        sock="$s"
        break
    done
fi

if [ -n "$sock" ]; then
    MANGO_INSTANCE_SIGNATURE="$sock" \
        mmsg dispatch reload_config >/dev/null 2>&1 || true

    # Repintar bordes de las ventanas visibles y restaurar el foco
    focused=$(MANGO_INSTANCE_SIGNATURE="$sock" mmsg get focusing-client 2>/dev/null \
        | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("id",0))' 2>/dev/null || true)
    clients=$(MANGO_INSTANCE_SIGNATURE="$sock" mmsg get all-clients 2>/dev/null \
        | python3 -c 'import json,sys; print(" ".join(str(c["id"]) for c in json.load(sys.stdin)["clients"] if c.get("is_visible")))' 2>/dev/null || true)

    for id in $clients; do
        [ "$id" = "$focused" ] && continue
        MANGO_INSTANCE_SIGNATURE="$sock" mmsg dispatch focusid client,$id >/dev/null 2>&1 || true
    done
    if [ -n "$focused" ] && [ "$focused" != "0" ]; then
        MANGO_INSTANCE_SIGNATURE="$sock" mmsg dispatch focusid client,$focused >/dev/null 2>&1 || true
    fi
fi

if pgrep -x waybar >/dev/null 2>&1; then
    for pid in $(pgrep -x waybar); do
        kill -USR2 "$pid" 2>/dev/null || true
    done
fi

makoctl reload >/dev/null 2>&1 || true

for pid in $(pgrep -x kitty 2>/dev/null || true); do
    kill -USR1 "$pid" 2>/dev/null || true
done