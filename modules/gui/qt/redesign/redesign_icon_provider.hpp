/*****************************************************************************
 * Copyright (C) 2026 VLC authors and VideoLAN
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * ( at your option ) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/
#ifndef REDESIGN_ICON_PROVIDER_HPP
#define REDESIGN_ICON_PROVIDER_HPP

#include <QQuickImageProvider>

/**
 * Synchronous image provider for the redesign icon set.
 *
 * url: image://redesignicon/<name>?c=<main color>&a=<accent color>
 *
 * Icons use #FF00FF for their main color and #FF8800 for the accent color.
 * The provider is synchronous on purpose: QQuickPixmap runs it in its own
 * reader thread, which keeps the global thread pool free for the raster
 * engine (rendering many SVGs from the global pool can starve it).
 */
class RedesignIconProvider : public QQuickImageProvider
{
public:
    RedesignIconProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
};

#endif // REDESIGN_ICON_PROVIDER_HPP
