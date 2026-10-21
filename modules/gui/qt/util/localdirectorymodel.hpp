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

#ifndef LOCALDIRECTORYMODEL_HPP
#define LOCALDIRECTORYMODEL_HPP

#include <QAbstractListModel>
#include <QString>
#include <QStringList>
#include <QUrl>
#include <QList>
#include <QDateTime>
#include <QVariantList>
#include <QDir>
#include <QHash>
#include <QSet>

class LocalDirectoryModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString currentPath READ currentPath WRITE setCurrentPath NOTIFY currentPathChanged)
    Q_PROPERTY(QString parentPath READ parentPath NOTIFY currentPathChanged)
    Q_PROPERTY(QString currentDirName READ currentDirName NOTIFY currentPathChanged)
    Q_PROPERTY(bool canCdUp READ canCdUp NOTIFY currentPathChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(int mediaCount READ mediaCount NOTIFY countChanged)
    Q_PROPERTY(QString currentUrl READ currentUrl NOTIFY currentPathChanged)
    Q_PROPERTY(QVariantList breadcrumbs READ breadcrumbs NOTIFY currentPathChanged)
    Q_PROPERTY(QString searchPattern READ searchPattern WRITE setSearchPattern NOTIFY searchPatternChanged)
    Q_PROPERTY(bool thumbnailsEnabled READ thumbnailsEnabled WRITE setThumbnailsEnabled NOTIFY thumbnailsEnabledChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        PathRole,
        UrlRole,
        IsFolderRole,
        IsAudioRole,
        FileSizeRole,
        FileDateRole,
        ThumbnailRole
    };

    explicit LocalDirectoryModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString currentPath() const;
    void setCurrentPath(const QString &path);

    QString parentPath() const;
    QString currentDirName() const;
    QString currentUrl() const;
    bool canCdUp() const;
    int mediaCount() const;
    QVariantList breadcrumbs() const;

    QString searchPattern() const;
    void setSearchPattern(const QString &pattern);

    bool thumbnailsEnabled() const;
    void setThumbnailsEnabled(bool enabled);

    Q_INVOKABLE void cd(const QString &subDirName);
    Q_INVOKABLE void cdUp();
    Q_INVOKABLE void syncToUrl(const QUrl &url);
    Q_INVOKABLE void refresh();
    // URLs of the media files of the current folder (not the subfolders)
    Q_INVOKABLE QVariantList mediaUrls() const;

signals:
    void currentPathChanged();
    void countChanged();
    void searchPatternChanged();
    void thumbnailsEnabledChanged();

private:
    void populate();
    void requestThumbnail(const QString &path, qint64 size, const QDateTime &mtime);
    void thumbnailReady(const QString &path, const QString &cacheFile);

    struct DirectoryItem {
        QString name;
        QString path;
        QString url;
        bool isFolder = false;
        bool isAudio = false;
        qint64 size = 0;
        QDateTime mtime;
    };

    QString m_currentPath;
    QString m_searchPattern;
    bool m_thumbnailsEnabled = false;
    QList<DirectoryItem> m_allItems;
    QList<DirectoryItem> m_filteredItems;
    mutable QHash<QString, QString> m_thumbFiles;
    QSet<QString> m_thumbPending;
};

#endif // LOCALDIRECTORYMODEL_HPP
