# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-group

DESCRIPTION="Group for users allowed to control nym-vpnd without a polkit prompt"
# Dynamic allocation: GIDs are not centrally allocated for overlays
ACCT_GROUP_ID=-1
