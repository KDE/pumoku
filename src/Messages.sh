#! /bin/sh
#SPDX-FileCopyrightText: 2025 Anders Lund <anders@alweb.dk>
#SPDX-License-Identifier: LGPL-2.1-or-later
$XGETTEXT `find . -name \*.cpp -o -name \*.h -o -name \*.qml` -o $podir/koko.pot
