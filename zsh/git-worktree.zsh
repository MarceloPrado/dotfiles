# ==========================================================================
# Git worktree helpers
# ==========================================================================

WT_DIR="${WT_DIR:-..}"

wt()      { git worktree add -b "$1" "$WT_DIR/$1" "${2:-main}"; }
wtr()     { git fetch origin "$1" && git worktree add --detach "$WT_DIR/${2:-${1//\//-}}" "origin/$1"; }
wtrm()    { git worktree remove "$WT_DIR/$1" && [ "${2:-}" != "-k" ] && git branch -d "$1" 2>/dev/null; }
wtl()     { git worktree list; }
wtcd()    { cd "$WT_DIR/$1"; }
wtprune() { git worktree prune -v; }
