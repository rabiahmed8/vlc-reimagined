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
#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include "redesign_icon_provider.hpp"
#include "util/imagehelper.hpp"

#include <QBuffer>
#include <QColor>
#include <QFile>
#include <QImageIOHandler>
#include <QScopedPointer>
#include <QUrlQuery>

RedesignIconProvider::RedesignIconProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

static QString colorArg(const QUrlQuery &query, const char *key, const char *fallback)
{
    const QString value = query.queryItemValue(QLatin1String(key), QUrl::FullyDecoded);
    const QColor color(value);
    if (!color.isValid())
        return QLatin1String(fallback);
    // SVG does not understand #AARRGGBB, opacity is handled by the item
    return color.name(QColor::HexRgb);
}

QImage RedesignIconProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    const int sep = id.indexOf(QLatin1Char('?'));
    const QString name = sep < 0 ? id : id.left(sep);
    const QUrlQuery query(sep < 0 ? QString() : id.mid(sep + 1));

    // only plain icon names are accepted
    for (const QChar c : name)
        if (!(c.isLetterOrNumber() || c == QLatin1Char('_') || c == QLatin1Char('-')))
            return {};

    QFile file(QStringLiteral(":/redesign/icons/%1.svg").arg(name));
    if (!file.open(QIODevice::ReadOnly))
        return {};

    QString svg = QString::fromUtf8(file.readAll());
    svg.replace(QLatin1String("#FF00FF"), colorArg(query, "c", "#8F8F8F"), Qt::CaseInsensitive);
    svg.replace(QLatin1String("#FF8800"), colorArg(query, "a", "#D37918"), Qt::CaseInsensitive);

    QScopedPointer<QImageIOHandler> handler(ImageHelper::createSvgImageIOHandler());
    if (!handler)
        return {};

    QBuffer buffer;
    buffer.setData(svg.toUtf8());
    if (!buffer.open(QIODevice::ReadOnly))
        return {};
    handler->setDevice(&buffer);
    if (!handler->canRead())
        return {};

    const QSize natural = handler->option(QImageIOHandler::Size).toSize();
    QSize target = requestedSize;
    if (target.width() <= 0 && target.height() <= 0)
        target = natural;
    else if (target.width() <= 0 && natural.height() > 0)
        target.setWidth(target.height() * natural.width() / natural.height());
    else if (target.height() <= 0 && natural.width() > 0)
        target.setHeight(target.width() * natural.height() / natural.width());

    if (target.isValid() && target != natural)
        handler->setOption(QImageIOHandler::ScaledSize, target);

    QImage image;
    if (!handler->read(&image))
        return {};

    if (size)
        *size = image.size();
    return image;
}
