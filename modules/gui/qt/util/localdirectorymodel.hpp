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
#include <QUrl>
#include <QList>
#include <QDateTime>
#include <QVariantList>
#include <QDir>

class LocalDirectoryModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString currentPath READ currentPath WRITE setCurrentPath NOTIFY currentPathChanged)
    Q_PROPERTY(QString parentPath READ parentPath NOTIFY currentPathChanged)
    Q_PROPERTY(QString currentDirName READ currentDirName NOTIFY currentPathChanged)
    Q_PROPERTY(bool canCdUp READ canCdUp NOTIFY currentPathChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QVariantList breadcrumbs READ breadcrumbs NOTIFY currentPathChanged)
    Q_PROPERTY(QString searchPattern READ searchPattern WRITE setSearchPattern NOTIFY searchPatternChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        PathRole,
        UrlRole,
        IsFolderRole,
        FileSizeRole,
        FileDateRole
    };

    explicit LocalDirectoryModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString currentPath() const;
    void setCurrentPath(const QString &path);

    QString parentPath() const;
    QString currentDirName() const;
    bool canCdUp() const;
    QVariantList breadcrumbs() const;

    QString searchPattern() const;
    void setSearchPattern(const QString &pattern);

    Q_INVOKABLE void cd(const QString &subDirName);
    Q_INVOKABLE void cdUp();
    Q_INVOKABLE void syncToUrl(const QUrl &url);
    Q_INVOKABLE void refresh();

signals:
    void currentPathChanged();
    void countChanged();
    void searchPatternChanged();

private:
    void populate();

    struct DirectoryItem {
        QString name;
        QString path;
        QString url;
        bool isFolder = false;
        qint64 size = 0;
        QDateTime mtime;
    };

    QString m_currentPath;
    QString m_searchPattern;
    QList<DirectoryItem> m_allItems;
    QList<DirectoryItem> m_filteredItems;
};

#endif // LOCALDIRECTORYMODEL_HPP
