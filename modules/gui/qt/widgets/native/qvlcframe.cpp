/*****************************************************************************
 * qvlcframe.cpp : A few helpers
 *****************************************************************************
 * Copyright (C) 2006-2007 the VideoLAN team
 *
 * Authors: Clément Stenac <zorglub@videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

#include <QWindow>
#include <QScreen>
#include <QApplication>
#include <QKeyEvent>
#include <QStyle>
#include <QPalette>
#include <QColor>

#include "qvlcframe.hpp"
#include "maininterface/compositor.hpp"

void QVLCTools::saveWidgetPosition(QSettings *settings, QWidget *widget)
{
    settings->setValue("geometry", widget->saveGeometry());
}

void QVLCTools::saveWindowPosition(QSettings *settings, QWindow *window)
{
    //no standard way to do it, mimic what qt is doing internally
    QByteArray array;
    QDataStream serialized(&array, QIODevice::WriteOnly);
    serialized.setVersion(QDataStream::Qt_4_0);

    //we use a different magic number than Qt
    const quint32 magicNumber = 0x1D94200;
    serialized << magicNumber
        << quint8(1) //version major
        << quint8(0) //version minor
        << window->screen()->name()
        << window->screen()->devicePixelRatio()
        << window->screen()->geometry()
        << window->position()
        << window->geometry()
        << quint8(window->windowStates() & Qt::WindowMaximized)
        << quint8(window->windowStates() & Qt::WindowFullScreen);
    settings->setValue("geometry", array);
}

static bool restoreWindowPositionImpl(QSettings *settings, QWindow *window)
{
    //no standard way to do it, mimic what qt is doing internally
    auto raw = settings->value("geometry").toByteArray();

    if (raw.length() < 4)
        return false;

    QDataStream serialized(raw);
    serialized.setVersion(QDataStream::Qt_4_0);
    quint32 magicNumber;
    quint8 versionMajor;
    quint8 versionMinor;

    serialized
        >> magicNumber
        >> versionMajor
        >> versionMinor;

    if (magicNumber != 0x1D94200 || versionMajor != 1)
        return false;

    QString screenName;
    qreal screenDRP;
    QRect screenGeometry;

    QPoint position;
    QRect geometry;
    quint8 maximized;
    quint8 fullscreen;

    serialized
        >> screenName
        >> screenDRP
        >> screenGeometry
        >> position
        >> geometry
        >> maximized
        >> fullscreen;

    if (screenName.isNull() || screenGeometry.isNull())
        return false;

    if (geometry.isNull())
        return false;

    bool screenFound = false;
    for (auto screen: QGuiApplication::screens())
    {
        if (screen->name() == screenName)
        {
            if (screen->geometry() != screenGeometry
                || screen->devicePixelRatio() != screenDRP)
            {
                //same screen but its property has changed, don't restore the position
                break;
            }
            window->setScreen(screen);
            screenFound = true;
            break;
        }
    }
    if (!screenFound)
        return false;

    window->setPosition(position);
    window->setGeometry(geometry);

    if (maximized || fullscreen)
    {
        Qt::WindowStates state = window->windowStates();
        if (maximized)
            state |= Qt::WindowMaximized;
        if (fullscreen)
            state |= Qt::WindowFullScreen;
        window->setWindowStates(state);
    }
    else
    {
        window->setWindowStates(window->windowStates() & ~(Qt::WindowMaximized | Qt::WindowFullScreen));
    }

    return true;
}

void QVLCTools::restoreWindowPosition(QSettings *settings, QWindow *window, QSize defSize, QPoint defPos)
{
    bool ret = restoreWindowPositionImpl(settings, window);
    if (ret)
        return;

    window->resize(defSize);
    if (defPos.isNull())
    {
        window->setGeometry(QStyle::alignedRect(Qt::LeftToRight, Qt::AlignCenter, window->size(), QGuiApplication::primaryScreen()->availableGeometry()));
    }
    else
    {
        window->setPosition(defPos);
    }
}


void QVLCTools::saveWidgetPosition(qt_intf_t *p_intf,
                                   const QString& configName,
                                   QWidget *widget)
{
    getSettings()->beginGroup(configName);
    QVLCTools::saveWidgetPosition(getSettings(), widget);
    getSettings()->endGroup();
}

bool QVLCTools::restoreWidgetPosition(QSettings *settings, QWidget *widget,
                                      QSize defSize, QPoint defPos)
{
    if (!widget->restoreGeometry(settings->value("geometry").toByteArray()))
    {
        widget->move(defPos);
        widget->resize(defSize);

        if (defPos.x() == 0 && defPos.y()==0)
            widget->setGeometry(QStyle::alignedRect(Qt::LeftToRight, Qt::AlignCenter, widget->size(), qApp->primaryScreen()->availableGeometry()));
        return true;
    }
    return false;
}

bool QVLCTools::restoreWidgetPosition(qt_intf_t *p_intf,
                                      const QString& configName,
                                      QWidget *widget, QSize defSize,
                                      QPoint defPos)
{
    getSettings()->beginGroup(configName);
    bool defaultUsed =
        QVLCTools::restoreWidgetPosition(getSettings(), widget, defSize, defPos);
    getSettings()->endGroup();

    return defaultUsed;
}

void QVLCTools::applyJuxtopposedTheme(QWidget *widget)
{
    if (!widget)
        return;

    QPalette juxtPalette = widget->palette();
    juxtPalette.setColor( QPalette::Window, QColor( "#1B1B1B" ) );
    juxtPalette.setColor( QPalette::Base, QColor( "#161616" ) );
    juxtPalette.setColor( QPalette::AlternateBase, QColor( "#1F1F1F" ) );
    juxtPalette.setColor( QPalette::WindowText, QColor( "#D8D8D8" ) );
    juxtPalette.setColor( QPalette::Text, QColor( "#D8D8D8" ) );
    juxtPalette.setColor( QPalette::Button, QColor( "#262626" ) );
    juxtPalette.setColor( QPalette::ButtonText, QColor( "#D8D8D8" ) );
    juxtPalette.setColor( QPalette::Highlight, QColor( "#D37918" ) );
    juxtPalette.setColor( QPalette::HighlightedText, QColor( "#161616" ) );
    widget->setPalette( juxtPalette );

    widget->setStyleSheet( QStringLiteral(
        "QWidget { font-family: Inter, Segoe UI, sans-serif; color: #D8D8D8; }"
        "QDialog, QFrame, QVLCFrame, QVLCDialog { background-color: #1B1B1B; color: #D8D8D8; }"
        "QTabWidget::pane { border: 1px solid #282828; background-color: #161616; border-radius: 10px; padding: 6px; }"
        "QTabBar::tab { background: #1B1B1B; color: #8F8F8F; border: 1px solid #282828; border-bottom: none; border-top-left-radius: 8px; border-top-right-radius: 8px; padding: 6px 14px; margin-right: 2px; }"
        "QTabBar::tab:selected { background: #262626; color: #D8D8D8; border-color: #373737; }"
        "QTabBar::tab:hover:!selected { background: #222222; color: #B0B0B0; }"
        "QGroupBox { background-color: #161616; border: 1px solid #282828; border-radius: 10px; margin-top: 18px; padding: 12px; }"
        "QGroupBox::title { subcontrol-origin: margin; left: 14px; padding: 0 6px; color: #A0A0A0; background-color: transparent; }"
        "QPushButton { background-color: #262626; border: 1px solid #333333; border-radius: 8px; padding: 6px 14px; color: #D8D8D8; font-weight: 500; }"
        "QPushButton:hover { background-color: #303030; border-color: #444444; }"
        "QPushButton:default { background-color: #D37918; border-color: #D37918; color: #161616; font-weight: bold; }"
        "QPushButton:default:hover { background-color: #E08A2E; border-color: #E08A2E; }"
        "QToolButton { background-color: #262626; border: 1px solid #333333; border-radius: 6px; padding: 4px; color: #D8D8D8; }"
        "QToolButton:hover { background-color: #303030; }"
        "QSlider::groove:horizontal { height: 6px; background: #090909; border-radius: 3px; }"
        "QSlider::sub-page:horizontal { background: #D37918; border-radius: 3px; }"
        "QSlider::handle:horizontal { background: #D37918; width: 14px; margin-top: -4px; margin-bottom: -4px; border-radius: 7px; }"
        "QSlider::handle:horizontal:hover { background: #E08A2E; }"
        "QSlider::groove:vertical { width: 6px; background: #090909; border-radius: 3px; }"
        "QSlider::sub-page:vertical { background: #090909; border-radius: 3px; }"
        "QSlider::add-page:vertical { background: #D37918; border-radius: 3px; }"
        "QSlider::handle:vertical { background: #D37918; height: 14px; margin-left: -4px; margin-right: -4px; border-radius: 7px; }"
        "QSlider::handle:vertical:hover { background: #E08A2E; }"
        "QComboBox, QLineEdit, QSpinBox, QDoubleSpinBox, QTimeEdit { background-color: #161616; border: 1px solid #333333; border-radius: 8px; padding: 5px 8px; color: #D8D8D8; selection-background-color: #D37918; selection-color: #161616; }"
        "QComboBox::drop-down { border: none; width: 20px; }"
        "QComboBox QAbstractItemView { background-color: #1B1B1B; border: 1px solid #333333; border-radius: 6px; selection-background-color: #D37918; selection-color: #161616; color: #D8D8D8; }"
        "QTextEdit, QTextBrowser, QPlainTextEdit { background-color: #161616; border: 1px solid #282828; border-radius: 8px; color: #D8D8D8; selection-background-color: #D37918; selection-color: #161616; padding: 6px; }"
        "QTreeWidget, QTreeView, QTableWidget, QTableView, QListView { background-color: #161616; border: 1px solid #282828; border-radius: 8px; color: #D8D8D8; alternate-background-color: #1A1A1A; selection-background-color: #D37918; selection-color: #161616; outline: none; }"
        "QHeaderView::section { background-color: #1F1F1F; color: #969696; border: none; border-bottom: 1px solid #282828; border-right: 1px solid #282828; padding: 5px 8px; font-weight: 600; }"
        "QCheckBox::indicator { width: 16px; height: 16px; border-radius: 5px; border: 1px solid #373737; background: #1B1B1B; }"
        "QCheckBox::indicator:checked { background: #D37918; border-color: #D37918; }"
        "QRadioButton::indicator { width: 14px; height: 14px; border-radius: 7px; border: 1px solid #373737; background: #1B1B1B; }"
        "QRadioButton::indicator:checked { border: 4px solid #D37918; background: #1B1B1B; }"
        "QScrollBar:vertical { background: #161616; width: 8px; margin: 0; border-radius: 4px; }"
        "QScrollBar::handle:vertical { background: #333333; min-height: 20px; border-radius: 4px; }"
        "QScrollBar::handle:vertical:hover { background: #444444; }"
        "QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical { height: 0; }"
        "QScrollBar:horizontal { background: #161616; height: 8px; margin: 0; border-radius: 4px; }"
        "QScrollBar::handle:horizontal { background: #333333; min-width: 20px; border-radius: 4px; }"
        "QScrollBar::handle:horizontal:hover { background: #444444; }"
        "QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal { width: 0; }"
        "QMenu { background-color: #1B1B1B; border: 1px solid #282828; border-radius: 8px; padding: 4px; color: #D8D8D8; font-family: Inter, Segoe UI, sans-serif; }"
        "QMenu::item { background-color: transparent; padding: 6px 20px 6px 12px; border-radius: 5px; color: #D8D8D8; }"
        "QMenu::item:selected { background-color: #D37918; color: #161616; font-weight: 500; }"
        "QMenu::item:disabled { color: #666666; background-color: transparent; }"
        "QMenu::separator { height: 1px; background-color: #282828; margin: 4px 6px; }"
        "QMenu::indicator { width: 14px; height: 14px; left: 4px; }"
        "QMenuBar { background-color: #1B1B1B; color: #D8D8D8; border-bottom: 1px solid #282828; font-family: Inter, Segoe UI, sans-serif; }"
        "QMenuBar::item { background-color: transparent; padding: 4px 10px; border-radius: 4px; color: #D8D8D8; }"
        "QMenuBar::item:selected { background-color: #262626; color: #D37918; }"
    ) );
}

QVLCFrame::QVLCFrame(qt_intf_t *_p_intf) : QWidget( NULL ), p_intf( _p_intf )
{
    assert(_p_intf);

    QVLCTools::applyJuxtopposedTheme(this);

    if (isWindow())
    {
        // If window, set the transient parent:
        QVLCDialog::setWindowTransientParent(this, nullptr, p_intf);
    }
}

void QVLCFrame::keyPressEvent(QKeyEvent *keyEvent)
{
    if (keyEvent->key() == Qt::Key_Escape)
    {
        this->cancel();
    }
    else if (keyEvent->key() == Qt::Key_Return ||
             keyEvent->key() == Qt::Key_Enter)
    {
        this->close();
    }
}

void QVLCDialog::setWindowTransientParent(QWidget* widget, QWindow* parent, qt_intf_t* p_intf)
{
    assert(widget);
    assert(widget->isWindow()); // Do not call this method if widget is not a window.

    if (!parent && p_intf && !p_intf->b_isDialogProvider)
    {
        assert(p_intf->p_compositor);
        parent = p_intf->p_compositor->interfaceMainWindow();
    }
    if (!parent)
        return;

    widget->ensurePolished();
    widget->createWinId();
    QWindow* handle  = widget->windowHandle();
    handle->setTransientParent(parent);
}


QVLCDialog::QVLCDialog(QWindow *parent, qt_intf_t *_p_intf)
    : QDialog(),
      p_intf( _p_intf )
{
    setWindowFlags( Qt::Dialog|Qt::WindowMinMaxButtonsHint|
                    Qt::WindowSystemMenuHint|Qt::WindowCloseButtonHint );

    QVLCTools::applyJuxtopposedTheme(this);

    setWindowTransientParent(this, parent, p_intf);
}
