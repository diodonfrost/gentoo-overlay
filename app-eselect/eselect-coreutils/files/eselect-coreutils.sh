# Installed by app-eselect/eselect-coreutils.
# Prepends the dispatch directory managed by `eselect coreutils set`
# so the active provider shadows /usr/bin for login shells without
# requiring per-user PATH edits. Remove this file to revert to a
# vanilla PATH.
case ":${PATH}:" in
	*:/usr/local/lib/eselect-coreutils/bin:*) ;;
	*) export PATH="/usr/local/lib/eselect-coreutils/bin:${PATH}" ;;
esac
