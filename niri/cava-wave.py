#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p python3Packages.pygobject3 python3Packages.pycairo gtk3 gtk-layer-shell

import os
import select
import threading

import cairo
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import GLib, Gtk, GtkLayerShell

FIFO = "/tmp/cava.fifo"
HEIGHT = 30
SAMPLE_COUNT = 64
COLOR = (0.796, 0.651, 0.969)


class Wave(Gtk.DrawingArea):
    def __init__(self):
        super().__init__()
        self.target = [0.0] * SAMPLE_COUNT
        self.values = [0.0] * SAMPLE_COUNT
        self.lock = threading.Lock()
        self.connect("draw", self.draw_wave)
        GLib.timeout_add(33, self.animate)

    def set_target(self, values):
        with self.lock:
            self.target = values[:SAMPLE_COUNT] + [0.0] * max(0, SAMPLE_COUNT - len(values))

    def animate(self):
        with self.lock:
            target = self.target[:]
        self.values = [
            current + (goal - current) * 0.18
            for current, goal in zip(self.values, target)
        ]
        self.queue_draw()
        return GLib.SOURCE_CONTINUE

    def draw_wave(self, _widget, context):
        width = max(1.0, float(self.get_allocated_width()))
        center = HEIGHT / 2.0
        step = width / (SAMPLE_COUNT - 1)
        points = [
            (index * step, center - min(1.0, value) * (HEIGHT * 0.40))
            for index, value in enumerate(self.values)
        ]

        context.set_operator(cairo.OPERATOR_SOURCE)
        context.set_source_rgba(0.0, 0.0, 0.0, 0.0)
        context.paint()
        context.set_operator(cairo.OPERATOR_OVER)
        context.set_line_cap(cairo.LINE_CAP_ROUND)
        context.set_line_join(cairo.LINE_JOIN_ROUND)

        for line_width, alpha in ((6.0, 0.08), (3.0, 0.18), (1.5, 0.88)):
            context.new_path()
            context.move_to(*points[0])
            for index in range(1, len(points) - 1):
                x1, y1 = points[index]
                x2, y2 = points[index + 1]
                control_x = (x1 + x2) / 2.0
                context.curve_to(control_x, y1, control_x, y2, x2, y2)
            context.set_source_rgba(*COLOR, alpha)
            context.set_line_width(line_width)
            context.stroke()
        return False


def read_cava(wave):
    while True:
        try:
            fd = os.open(FIFO, os.O_RDONLY | os.O_NONBLOCK)
            break
        except FileNotFoundError:
            return

    with os.fdopen(fd, "r", buffering=1) as stream:
        poller = select.poll()
        poller.register(stream, select.POLLIN | select.POLLHUP)
        while True:
            if not poller.poll(1000):
                continue
            line = stream.readline()
            if not line:
                return
            try:
                values = [
                    int(value) / 7.0
                    for value in line.strip().split(";")
                    if value.isdigit()
                ]
            except ValueError:
                continue
            GLib.idle_add(wave.set_target, values)


def main():
    if not os.path.exists(FIFO):
        os.mkfifo(FIFO)

    window = Gtk.Window()
    window.set_decorated(False)
    window.set_app_paintable(True)
    window.set_title("niri-cava-wave")
    window.connect("destroy", Gtk.main_quit)

    visual = window.get_screen().get_rgba_visual()
    if visual is not None:
        window.set_visual(visual)

    GtkLayerShell.init_for_window(window)
    GtkLayerShell.set_layer(window, GtkLayerShell.Layer.BOTTOM)
    GtkLayerShell.set_exclusive_zone(window, 0)
    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.TOP, True)
    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.LEFT, True)
    GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.RIGHT, True)
    GtkLayerShell.set_margin(window, GtkLayerShell.Edge.TOP, 4)
    GtkLayerShell.set_keyboard_interactivity(window, False)

    wave = Wave()
    window.add(wave)
    window.show_all()
    threading.Thread(target=read_cava, args=(wave,), daemon=True).start()
    Gtk.main()


if __name__ == "__main__":
    main()
