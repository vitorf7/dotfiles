local status_ok, nvim_tmux_navigation = pcall(require, "nvim-tmux-navigation")
if not status_ok then
  return
end

nvim_tmux_navigation.setup {
  disable_when_zoomed = true -- defaults to false
}
