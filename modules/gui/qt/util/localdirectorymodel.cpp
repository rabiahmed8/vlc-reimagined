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

#include "localdirectorymodel.hpp"

#include <QCryptographicHash>
#include <QFileInfo>
#include <QImage>
#include <QPointer>
#include <QRunnable>
#include <QStandardPaths>
#include <QThreadPool>
#include <QVariantMap>

#ifdef Q_OS_WIN
# ifndef NOMINMAX
#  define NOMINMAX
# endif
# include <windows.h>
# include <objbase.h>
# include <shobjidl.h>
#endif

namespace
{

const QStringList &audioExtensions()
{
    static const QStringList extensions = {
        "aac", "ac3", "aif", "aiff", "alac", "amr", "ape", "dts", "flac",
        "m4a", "mka", "mp2", "mp3", "oga", "ogg", "opus", "wav", "wma", "wv"
    };
    return extensions;
}

const QStringList &mediaExtensions()
{
    static const QStringList extensions = audioExtensions() + QStringList{
        "3g2", "3gp", "asf", "avi", "divx", "dv", "f4v", "flv", "iso", "m1v",
        "m2ts", "m2v", "m4v", "mkv", "mov", "mp4", "mpe", "mpeg", "mpg", "mts",
        "mxf", "ogm", "ogv", "rm", "rmvb", "ts", "vob", "webm", "wmv"
    };
    return extensions;
}

bool isAudioFile(const QFileInfo &file)
{
    return audioExtensions().contains(file.suffix().toLower());
}

bool isMediaFile(const QFileInfo &file)
{
    return mediaExtensions().contains(file.suffix().toLower());
}

QString thumbnailCacheFile(const QString &path, qint64 size, const QDateTime &mtime)
{
    const QByteArray key = QCryptographicHash::hash(
                (path + '|' + QString::number(size) + '|'
                 + QString::number(mtime.toMSecsSinceEpoch())).toUtf8(),
                QCryptographicHash::Sha1).toHex();
    return QStandardPaths::writableLocation(QStandardPaths::CacheLocation)
            + QStringLiteral("/folder-thumbnails/") + QString::fromLatin1(key)
            + QStringLiteral(".png");
}

#ifdef Q_OS_WIN
// Asks the Windows shell (same source as Explorer) for the video thumbnail and
// stores it as a PNG in the cache. Returns true when a file was written.
bool saveShellThumbnail(const QString &filePath, const QString &cacheFile)
{
    const HRESULT hrInit = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    if (FAILED(hrInit) && hrInit != RPC_E_CHANGED_MODE)
        return false;

    bool saved = false;
    IShellItemImageFactory *factory = nullptr;
    const QString nativePath = QDir::toNativeSeparators(filePath);
    if (SUCCEEDED(SHCreateItemFromParsingName(reinterpret_cast<PCWSTR>(nativePath.utf16()),
                                              nullptr, IID_PPV_ARGS(&factory)))
            && factory != nullptr) {
        SIZE size = { 512, 288 };
        HBITMAP bitmap = nullptr;
        const HRESULT hr = factory->GetImage(size, SIIGBF_THUMBNAILONLY | SIIGBF_BIGGERSIZEOK,
                                             &bitmap);
        if (SUCCEEDED(hr) && bitmap != nullptr) {
            BITMAP info = {};
            if (GetObject(bitmap, sizeof(info), &info) && info.bmWidth > 0 && info.bmHeight > 0) {
                QImage image;
                if (info.bmBits != nullptr && info.bmBitsPixel == 32) {
                    const QImage view(static_cast<const uchar *>(info.bmBits), info.bmWidth,
                                      info.bmHeight, info.bmWidthBytes, QImage::Format_RGB32);
                    image = view.copy();
                } else {
                    BITMAPINFO dib = {};
                    dib.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
                    dib.bmiHeader.biWidth = info.bmWidth;
                    dib.bmiHeader.biHeight = -info.bmHeight;
                    dib.bmiHeader.biPlanes = 1;
                    dib.bmiHeader.biBitCount = 32;
                    dib.bmiHeader.biCompression = BI_RGB;
                    HDC dc = CreateCompatibleDC(nullptr);
                    if (dc != nullptr) {
                        image = QImage(info.bmWidth, info.bmHeight, QImage::Format_RGB32);
                        if (!GetDIBits(dc, bitmap, 0, info.bmHeight, image.bits(), &dib,
                                       DIB_RGB_COLORS))
                            image = QImage();
                        DeleteDC(dc);
                    }
                }
                if (!image.isNull()) {
                    if (image.width() > 512)
                        image = image.scaled(512, 288, Qt::KeepAspectRatio,
                                             Qt::SmoothTransformation);
                    QDir().mkpath(QFileInfo(cacheFile).absolutePath());
                    saved = image.save(cacheFile, "PNG");
                }
            }
            DeleteObject(bitmap);
        }
        factory->Release();
    }

    if (SUCCEEDED(hrInit))
        CoUninitialize();
    return saved;
}
#else
bool saveShellThumbnail(const QString &, const QString &)
{
    return false;
}
#endif

}

LocalDirectoryModel::LocalDirectoryModel(QObject *parent)
    : QAbstractListModel(parent)
{
    populate();
}

int LocalDirectoryModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_filteredItems.size();
}

QVariant LocalDirectoryModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_filteredItems.size())
        return QVariant();

    const DirectoryItem &item = m_filteredItems.at(index.row());

    switch (role) {
    case NameRole:
    case Qt::DisplayRole:
        return item.name;
    case PathRole:
        return item.path;
    case UrlRole:
        return item.url;
    case IsFolderRole:
        return item.isFolder;
    case IsAudioRole:
        return item.isAudio;
    case FileSizeRole: {
        if (item.isFolder)
            return QString();
        if (item.size < 1024)
            return QString("%1 B").arg(item.size);
        if (item.size < 1024 * 1024)
            return QString("%1 KB").arg(item.size / 1024);
        if (item.size < 1024 * 1024 * 1024)
            return QString("%1 MB").arg(item.size / (1024 * 1024));
        return QString("%1 GB").arg(double(item.size) / (1024.0 * 1024.0 * 1024.0), 0, 'f', 1);
    }
    case FileDateRole:
        return item.mtime;
    case ThumbnailRole: {
        if (!m_thumbnailsEnabled || item.isFolder || item.isAudio)
            return QString();
        const auto cached = m_thumbFiles.constFind(item.path);
        if (cached != m_thumbFiles.constEnd())
            return QUrl::fromLocalFile(*cached).toString();
        const QString cacheFile = thumbnailCacheFile(item.path, item.size, item.mtime);
        if (QFileInfo::exists(cacheFile)) {
            m_thumbFiles.insert(item.path, cacheFile);
            return QUrl::fromLocalFile(cacheFile).toString();
        }
        const_cast<LocalDirectoryModel *>(this)->requestThumbnail(item.path, item.size, item.mtime);
        return QString();
    }
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> LocalDirectoryModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[PathRole] = "path";
    roles[UrlRole] = "url";
    roles[IsFolderRole] = "isFolder";
    roles[IsAudioRole] = "isAudio";
    roles[FileSizeRole] = "fileSize";
    roles[FileDateRole] = "fileDate";
    roles[ThumbnailRole] = "thumbnail";
    return roles;
}

QString LocalDirectoryModel::currentPath() const
{
    return m_currentPath;
}

void LocalDirectoryModel::setCurrentPath(const QString &path)
{
    QString normalized = path.trimmed();

    // Accept both local paths and file:// URLs (the folder of a media, for example).
    if (normalized.startsWith("file:", Qt::CaseInsensitive)) {
        const QUrl url(normalized);
        normalized = url.isLocalFile() ? url.toLocalFile() : QString();
    }

    if (!normalized.isEmpty())
        normalized = QDir::cleanPath(QFileInfo(normalized).absoluteFilePath());

    if (m_currentPath == normalized)
        return;

    m_currentPath = normalized;
    populate();
    emit currentPathChanged();
}

QString LocalDirectoryModel::parentPath() const
{
    if (m_currentPath.isEmpty())
        return QString();

    QDir d(m_currentPath);
    if (d.isRoot())
        return QString();

    QDir parentDir = d;
    if (parentDir.cdUp())
        return parentDir.absolutePath();

    return QString();
}

QString LocalDirectoryModel::currentDirName() const
{
    if (m_currentPath.isEmpty())
        return tr("This PC");

    QDir d(m_currentPath);
    QString name = d.dirName();
    if (name.isEmpty() || d.isRoot())
        return m_currentPath;

    return name;
}

QString LocalDirectoryModel::currentUrl() const
{
    if (m_currentPath.isEmpty())
        return QString();
    return QUrl::fromLocalFile(m_currentPath).toString();
}

bool LocalDirectoryModel::canCdUp() const
{
    return !m_currentPath.isEmpty();
}

int LocalDirectoryModel::mediaCount() const
{
    int count = 0;
    for (const DirectoryItem &item : m_filteredItems) {
        if (!item.isFolder)
            ++count;
    }
    return count;
}

QVariantList LocalDirectoryModel::breadcrumbs() const
{
    QVariantList list;

    QVariantMap rootEntry;
    rootEntry["name"] = tr("This PC");
    rootEntry["path"] = "";
    list.append(rootEntry);

    if (m_currentPath.isEmpty())
        return list;

    QString clean = QDir::cleanPath(m_currentPath);
    QStringList parts = clean.split('/', Qt::SkipEmptyParts);

    QString accum;
#ifdef Q_OS_WIN
    // On Windows, the first part is often "C:" or similar
    if (!parts.isEmpty() && parts.first().endsWith(':')) {
        accum = parts.first() + "/";
        QVariantMap driveEntry;
        driveEntry["name"] = parts.first();
        driveEntry["path"] = accum;
        list.append(driveEntry);
        parts.removeFirst();
    }
#else
    accum = "/";
#endif

    for (const QString &part : parts) {
        if (accum.endsWith('/'))
            accum += part;
        else
            accum += "/" + part;

        QVariantMap entry;
        entry["name"] = part;
        entry["path"] = accum;
        list.append(entry);
    }

    return list;
}

QString LocalDirectoryModel::searchPattern() const
{
    return m_searchPattern;
}

void LocalDirectoryModel::setSearchPattern(const QString &pattern)
{
    if (m_searchPattern == pattern)
        return;

    m_searchPattern = pattern;

    beginResetModel();
    m_filteredItems.clear();
    for (const DirectoryItem &item : m_allItems) {
        if (m_searchPattern.isEmpty() || item.name.contains(m_searchPattern, Qt::CaseInsensitive))
            m_filteredItems.append(item);
    }
    endResetModel();

    emit searchPatternChanged();
    emit countChanged();
}

bool LocalDirectoryModel::thumbnailsEnabled() const
{
    return m_thumbnailsEnabled;
}

void LocalDirectoryModel::setThumbnailsEnabled(bool enabled)
{
    if (m_thumbnailsEnabled == enabled)
        return;

    m_thumbnailsEnabled = enabled;
    emit thumbnailsEnabledChanged();

    if (enabled && !m_filteredItems.isEmpty())
        emit dataChanged(index(0), index(int(m_filteredItems.size()) - 1), { ThumbnailRole });
}

void LocalDirectoryModel::requestThumbnail(const QString &path, qint64 size, const QDateTime &mtime)
{
    if (!m_thumbnailsEnabled || m_thumbPending.contains(path))
        return;

    const QString cacheFile = thumbnailCacheFile(path, size, mtime);
    m_thumbPending.insert(path);

    QPointer<LocalDirectoryModel> self(this);
    QThreadPool::globalInstance()->start(QRunnable::create(
        [self, filePath = path, cacheFile]() {
            const bool saved = saveShellThumbnail(filePath, cacheFile);
            if (!self)
                return;
            QMetaObject::invokeMethod(self, [self, filePath, cacheFile, saved]() {
                if (self)
                    self->thumbnailReady(filePath, saved ? cacheFile : QString());
            }, Qt::QueuedConnection);
        }));
}

void LocalDirectoryModel::thumbnailReady(const QString &path, const QString &cacheFile)
{
    m_thumbPending.remove(path);
    if (cacheFile.isEmpty())
        return;

    m_thumbFiles.insert(path, cacheFile);

    for (int row = 0; row < m_filteredItems.size(); ++row) {
        if (m_filteredItems.at(row).path != path)
            continue;
        const QModelIndex modelIndex = index(row);
        emit dataChanged(modelIndex, modelIndex, { ThumbnailRole });
        break;
    }
}

void LocalDirectoryModel::cd(const QString &subDirName)
{
    if (m_currentPath.isEmpty()) {
        setCurrentPath(subDirName);
        return;
    }

    QDir d(m_currentPath);
    setCurrentPath(d.filePath(subDirName));
}

void LocalDirectoryModel::cdUp()
{
    if (m_currentPath.isEmpty())
        return;

    QDir d(m_currentPath);
    if (d.isRoot()) {
        setCurrentPath("");
        return;
    }

    QDir parentDir = d;
    if (parentDir.cdUp())
        setCurrentPath(parentDir.absolutePath());
    else
        setCurrentPath("");
}

void LocalDirectoryModel::syncToUrl(const QUrl &url)
{
    if (!url.isValid())
        return;

    QString localPath = url.toLocalFile();
    if (localPath.isEmpty())
        return;

    QFileInfo fi(localPath);
    if (fi.exists()) {
        if (fi.isDir())
            setCurrentPath(fi.absoluteFilePath());
        else
            setCurrentPath(fi.dir().absolutePath());
    }
}

void LocalDirectoryModel::refresh()
{
    populate();
}

QVariantList LocalDirectoryModel::mediaUrls() const
{
    QVariantList urls;
    for (const DirectoryItem &item : m_filteredItems) {
        if (!item.isFolder)
            urls.append(item.url);
    }
    return urls;
}

void LocalDirectoryModel::populate()
{
    beginResetModel();
    m_allItems.clear();
    m_filteredItems.clear();

    if (m_currentPath.isEmpty()) {
        // Root / Drives View
        QFileInfoList drives = QDir::drives();
        for (const QFileInfo &drive : drives) {
            DirectoryItem item;
            item.name = drive.path();
            item.path = drive.absoluteFilePath();
            item.url = QUrl::fromLocalFile(item.path).toString();
            item.isFolder = true;
            item.size = 0;
            m_allItems.append(item);
        }

        auto addStdFolder = [this](QStandardPaths::StandardLocation loc, const QString &label) {
            QString path = QStandardPaths::writableLocation(loc);
            if (!path.isEmpty() && QDir(path).exists()) {
                DirectoryItem item;
                item.name = label;
                item.path = QDir::cleanPath(path);
                item.url = QUrl::fromLocalFile(item.path).toString();
                item.isFolder = true;
                item.size = 0;
                m_allItems.append(item);
            }
        };

        addStdFolder(QStandardPaths::MoviesLocation, tr("Videos"));
        addStdFolder(QStandardPaths::DownloadLocation, tr("Downloads"));
        addStdFolder(QStandardPaths::DesktopLocation, tr("Desktop"));
        addStdFolder(QStandardPaths::DocumentsLocation, tr("Documents"));
    } else {
        QDir dir(m_currentPath);
        if (dir.exists()) {
            // Subdirectories
            QFileInfoList dirList = dir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot | QDir::Readable,
                                                     QDir::Name | QDir::IgnoreCase);
            for (const QFileInfo &fi : dirList) {
                DirectoryItem item;
                item.name = fi.fileName();
                item.path = fi.absoluteFilePath();
                item.url = QUrl::fromLocalFile(item.path).toString();
                item.isFolder = true;
                item.size = 0;
                item.mtime = fi.lastModified();
                m_allItems.append(item);
            }

            // Media files
            const QFileInfoList fileList = dir.entryInfoList(QDir::Files | QDir::Readable,
                                                            QDir::Name | QDir::IgnoreCase);
            for (const QFileInfo &fi : fileList) {
                if (!isMediaFile(fi))
                    continue;

                DirectoryItem item;
                item.name = fi.fileName();
                item.path = fi.absoluteFilePath();
                item.url = QUrl::fromLocalFile(item.path).toString();
                item.isFolder = false;
                item.isAudio = isAudioFile(fi);
                item.size = fi.size();
                item.mtime = fi.lastModified();
                m_allItems.append(item);
            }
        }
    }

    for (const DirectoryItem &item : m_allItems) {
        if (m_searchPattern.isEmpty() || item.name.contains(m_searchPattern, Qt::CaseInsensitive))
            m_filteredItems.append(item);
    }

    endResetModel();
    emit countChanged();
}
