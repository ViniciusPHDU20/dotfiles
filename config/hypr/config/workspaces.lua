-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Assign workspaces 1 through NUM_WPM (1..10) to PRIMARY_MONITOR
for w = 1, NUM_WPM do
    hl.workspace_rule({
        workspace = tostring(w),
        monitor = PRIMARY_MONITOR,
        default = (w == 1),
        persistent = true
    })
end
