-- Curves and animations configuration
-- Responsive, smooth physics-inspired movement

-- Custom Beziers
hl.curve("easeOutQuart",   { type = "bezier", points = { {0.25, 1},    {0.5, 1}     } })
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("overshoot",      { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.05}  } })
hl.curve("smoothIn",       { type = "bezier", points = { {0.25, 1},    {0.5, 1}     } })
hl.curve("smoothOut",      { type = "bezier", points = { {0.36, 0},    {0.66, -0.56} } })

-- Springs
hl.curve("snappy",         { type = "spring", mass = 1, stiffness = 300, dampening = 28 })
hl.curve("gentle",         { type = "spring", mass = 1, stiffness = 160, dampening = 20 })

-- Animations
hl.animation({ leaf = "global",              enabled = true, speed = 3, bezier = "easeOutQuart"             })
hl.animation({ leaf = "windows",             enabled = true, speed = 4, bezier = "overshoot",   style = "popin 80%" })
hl.animation({ leaf = "windowsIn",           enabled = true, speed = 3, bezier = "overshoot",   style = "popin 85%" })
hl.animation({ leaf = "windowsOut",          enabled = true, speed = 3, bezier = "easeOutQuart", style = "popin 85%" })
hl.animation({ leaf = "border",              enabled = true, speed = 4, bezier = "easeOutQuint"             })
hl.animation({ leaf = "borderangle",         enabled = true, speed = 30, bezier = "easeInOutCubic", loop = true })
hl.animation({ leaf = "fade",                enabled = true, speed = 3, bezier = "easeOutQuart"             })
hl.animation({ leaf = "workspaces",          enabled = true, speed = 4, bezier = "easeOutQuart", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 3, bezier = "overshoot",   style = "slide top" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 3, bezier = "easeOutQuart", style = "slide bottom" })

